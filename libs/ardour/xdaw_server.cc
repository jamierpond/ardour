/*
 * Copyright (C) 2025 XDAW Contributors
 *
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation; either version 2 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License along
 * with this program; if not, write to the Free Software Foundation, Inc.,
 * 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA.
 */

#include "ardour/xdaw_server.h"

#include <xdaw/server.h>
#include <xdaw/types.h>

#include <chrono>
#include <fstream>

#include <glibmm/miscutils.h>

#include "ardour/audio_track.h"
#include "ardour/audioregion.h"
#include "ardour/export_channel_configuration.h"
#include "ardour/export_filename.h"
#include "ardour/export_format_specification.h"
#include "ardour/export_handler.h"
#include "ardour/export_status.h"
#include "ardour/export_timespan.h"
#include "ardour/gain_control.h"
#include "ardour/midi_track.h"
#include "ardour/panner_shell.h"
#include "ardour/playlist.h"
#include "ardour/region.h"
#include "ardour/region_factory.h"
#include "ardour/route.h"
#include "ardour/session.h"
#include "ardour/session_directory.h"
#include "ardour/sndfilesource.h"
#include "ardour/source_factory.h"
#include "ardour/track.h"
#include "ardour/types.h"

#include "pbd/id.h"

#include "temporal/beats.h"
#include "temporal/tempo.h"

namespace ARDOUR {

XDAWServer::XDAWServer(std::int32_t port)
    : port_(port),
      server_(std::make_unique<xdaw::Server>(xdaw::Server::Config{
          .port = port,
          .daw_name = "Ardour",
          .daw_version = "8.0",  // TODO: Use actual version
          .supports_offline_render = true,
          .supports_realtime_monitor = false,
          .supports_browser = false,
          .supports_analysis = false,
      })) {
  setup_handlers();
}

XDAWServer::~XDAWServer() { stop(); }

auto XDAWServer::set_session(Session* s) -> void {
  SessionHandlePtr::set_session(s);
}

auto XDAWServer::setup_handlers() -> void {
  server_->set_session_state_provider(
      [this](const xdaw::SessionRequest& req) { return build_session_state(req); });

  server_->set_transport_state_provider(
      [this]() { return build_transport_state(); });

  server_->set_track_detail_provider(
      [this](const std::string& track_id) { return get_track_detail(track_id); });

  server_->set_edit_handler(
      [this](const xdaw::EditBatch& batch) { return apply_edits(batch); });

  server_->set_render_handler(
      [this](const xdaw::RenderRequest& req) { return start_render(req); });

  server_->set_notification_handler([this]() {
    tasks_pending_.store(true, std::memory_order_release);
  });
}

auto XDAWServer::start() -> void { server_->start(); }

auto XDAWServer::stop() -> void { server_->stop(); }

auto XDAWServer::is_running() const -> bool { return server_->is_running(); }

auto XDAWServer::process_pending_tasks() -> void {
  server_->process_pending_tasks();
  check_pending_renders();
}

auto XDAWServer::has_pending_tasks() -> bool {
  // Return true if gRPC tasks are pending OR if we have renders to poll
  return tasks_pending_.exchange(false, std::memory_order_acq_rel) ||
         !pending_renders_.empty();
}

// Helper to convert Ardour track type to XDAW
static auto ardour_to_xdaw_track_type(std::shared_ptr<Route> route)
    -> xdaw::TrackType {
  if (route->is_master()) {
    return xdaw::TrackType::Master;
  }
  if (std::dynamic_pointer_cast<AudioTrack>(route)) {
    return xdaw::TrackType::Audio;
  }
  if (std::dynamic_pointer_cast<MidiTrack>(route)) {
    return xdaw::TrackType::Midi;
  }
  return xdaw::TrackType::Return;  // Busses
}

auto XDAWServer::build_session_state(const xdaw::SessionRequest& /* req */)
    -> xdaw::SessionState {
  auto state = xdaw::SessionState{};

  if (!_session) {
    return state;
  }

  // Get tempo from tempo map
  auto tmap = Temporal::TempoMap::use();
  if (tmap) {
    auto tempo = tmap->tempo_at(Temporal::timepos_t());
    state.tempo = tempo.note_types_per_minute();

    auto meter = tmap->meter_at(Temporal::timepos_t());
    state.time_signature.numerator = static_cast<std::int32_t>(meter.divisions_per_bar());
    state.time_signature.denominator = static_cast<std::int32_t>(meter.note_value());
  }

  state.transport = build_transport_state();

  // Iterate tracks
  auto routes = _session->get_routes();
  for (const auto& route : *routes) {
    if (route->is_auditioner() || route->is_monitor()) {
      continue;
    }

    auto track = xdaw::Track{};
    track.id = route->id().to_s();
    track.name = route->name();
    track.muted = route->muted();
    track.soloed = route->soloed();
    track.type = ardour_to_xdaw_track_type(route);

    // Get gain (volume in dB)
    if (auto gain_ctrl = route->gain_control()) {
      // Convert from coefficient to dB
      auto coef = static_cast<float>(gain_ctrl->get_value());
      if (coef > 0.0f) {
        track.volume = 20.0 * std::log10(coef);
      } else {
        track.volume = -std::numeric_limits<double>::infinity();
      }
    }

    // Get pan (azimuth: 0=left, 0.5=center, 1=right -> XDAW: -1 to +1)
    if (auto pan_ctrl = route->pan_azimuth_control()) {
      auto azimuth = pan_ctrl->get_value();  // 0 to 1
      track.pan = (azimuth - 0.5) * 2.0;     // -1 to +1
    }

    // Get regions (clips) from track's playlist
    if (auto ardour_track = std::dynamic_pointer_cast<Track>(route)) {
      if (auto playlist = ardour_track->playlist()) {
        auto region_list = playlist->region_list();
        for (const auto& region : *region_list) {
          auto clip = xdaw::Clip{};
          clip.id = region->id().to_s();
          clip.name = region->name();

          // Convert position/length to beats
          if (tmap) {
            auto pos_beats = tmap->quarters_at(region->position());
            auto end_beats = tmap->quarters_at(region->end());
            clip.start_beat = Temporal::DoubleableBeats(pos_beats).to_double();
            clip.length_beats = Temporal::DoubleableBeats(end_beats - pos_beats).to_double();
          }

          track.clips.push_back(clip);
        }
      }

      // Check if track is armed for recording
      track.armed = ardour_track->rec_enable_control() &&
                    ardour_track->rec_enable_control()->get_value();
    }

    // Handle master track separately
    if (route->is_master()) {
      auto master = xdaw::MasterTrack{};
      master.id = route->id().to_s();
      if (auto gain_ctrl = route->gain_control()) {
        auto coef = static_cast<float>(gain_ctrl->get_value());
        if (coef > 0.0f) {
          master.volume = 20.0 * std::log10(coef);
        }
      }
      state.master_track = master;
    } else {
      state.tracks.push_back(track);
    }
  }

  state.summary.track_count = static_cast<std::int32_t>(state.tracks.size());
  return state;
}

auto XDAWServer::build_transport_state() -> xdaw::TransportState {
  auto state = xdaw::TransportState{};

  if (!_session) {
    return state;
  }

  state.is_playing = _session->transport_rolling();
  state.is_recording = _session->actively_recording();
  state.loop_enabled = _session->get_play_loop();

  // Get playhead position in beats
  auto tmap = Temporal::TempoMap::use();
  if (tmap) {
    auto pos = _session->transport_sample();
    auto beats = tmap->quarters_at(Temporal::timepos_t(pos));
    state.position_beats = Temporal::DoubleableBeats(beats).to_double();

    auto tempo = tmap->tempo_at(Temporal::timepos_t());
    state.tempo = tempo.note_types_per_minute();
  }

  // Get loop region if looping
  if (state.loop_enabled) {
    auto loop_loc = _session->locations()->auto_loop_location();
    if (loop_loc && tmap) {
      auto loop_region = xdaw::LoopRegion{};
      auto start_beats = tmap->quarters_at(loop_loc->start());
      auto end_beats = tmap->quarters_at(loop_loc->end());
      loop_region.start_beat = Temporal::DoubleableBeats(start_beats).to_double();
      loop_region.length_beats = Temporal::DoubleableBeats(end_beats - start_beats).to_double();
      state.loop_region = loop_region;
    }
  }

  return state;
}

auto XDAWServer::get_track_detail(const std::string& track_id) -> xdaw::Track {
  auto track = xdaw::Track{};

  if (!_session) {
    return track;
  }

  auto route = _session->route_by_id(PBD::ID(track_id));
  if (!route) {
    return track;
  }

  track.id = route->id().to_s();
  track.name = route->name();
  track.muted = route->muted();
  track.soloed = route->soloed();
  track.type = ardour_to_xdaw_track_type(route);

  if (auto gain_ctrl = route->gain_control()) {
    auto coef = static_cast<float>(gain_ctrl->get_value());
    if (coef > 0.0f) {
      track.volume = 20.0 * std::log10(coef);
    }
  }

  // Get pan (azimuth: 0=left, 0.5=center, 1=right -> XDAW: -1 to +1)
  if (auto pan_ctrl = route->pan_azimuth_control()) {
    auto azimuth = pan_ctrl->get_value();
    track.pan = (azimuth - 0.5) * 2.0;
  }

  // Get clips
  auto tmap = Temporal::TempoMap::use();
  if (auto ardour_track = std::dynamic_pointer_cast<Track>(route)) {
    if (auto playlist = ardour_track->playlist()) {
      auto region_list = playlist->region_list();
      for (const auto& region : *region_list) {
        auto clip = xdaw::Clip{};
        clip.id = region->id().to_s();
        clip.name = region->name();

        if (tmap) {
          auto pos_beats = tmap->quarters_at(region->position());
          auto end_beats = tmap->quarters_at(region->end());
          clip.start_beat = Temporal::DoubleableBeats(pos_beats).to_double();
          clip.length_beats = Temporal::DoubleableBeats(end_beats - pos_beats).to_double();
        }

        track.clips.push_back(clip);
      }

      track.armed = ardour_track->rec_enable_control() &&
                    ardour_track->rec_enable_control()->get_value();
    }
  }

  return track;
}

auto XDAWServer::apply_edits(const xdaw::EditBatch& batch) -> xdaw::EditResponse {
  auto response = xdaw::EditResponse{};

  if (!_session) {
    response.error_message = "No session";
    return response;
  }

  for (const auto& op : batch.operations) {
    switch (op.type) {
      case xdaw::EditOperationType::CreateTrack: {
        // Create audio or MIDI track
        const auto& cmd = op.create_track;
        if (cmd.type == xdaw::TrackType::Audio) {
          std::cerr << "[XDAW] Creating audio track: " << cmd.name << std::endl;
          auto tracks = _session->new_audio_track(
              1,       // input channels
              2,       // output channels
              nullptr, // route group
              1,       // how many
              cmd.name.empty() ? "Audio" : cmd.name,
              PresentationInfo::max_order,
              Normal);
          std::cerr << "[XDAW] new_audio_track returned " << tracks.size() << " tracks" << std::endl;
          for (const auto& t : tracks) {
            std::cerr << "[XDAW] Created track ID: " << t->id().to_s() << std::endl;
            response.created_ids.push_back(t->id().to_s());
          }
        } else if (cmd.type == xdaw::TrackType::Midi) {
          auto tracks = _session->new_midi_track(
              ChanCount(DataType::MIDI, 1),
              ChanCount(DataType::MIDI, 1),
              true,    // strict_io
              nullptr, // instrument plugin
              nullptr, // preset
              nullptr, // route group
              1,       // how many
              cmd.name.empty() ? "MIDI" : cmd.name,
              PresentationInfo::max_order,
              Normal,
              true); // input_auto_connect
          for (const auto& t : tracks) {
            response.created_ids.push_back(t->id().to_s());
          }
        } else {
          response.error_message = "Unsupported track type";
          return response;
        }
        break;
      }

      case xdaw::EditOperationType::DeleteTrack: {
        const auto& cmd = op.delete_track;
        auto route = _session->route_by_id(PBD::ID(cmd.track_id));
        if (route) {
          _session->remove_route(route);
        }
        break;
      }

      case xdaw::EditOperationType::RenameTrack: {
        const auto& cmd = op.rename_track;
        auto route = _session->route_by_id(PBD::ID(cmd.track_id));
        if (route) {
          route->set_name(cmd.new_name);
        }
        break;
      }

      case xdaw::EditOperationType::SetMixerState: {
        const auto& cmd = op.set_mixer_state;
        for (const auto& track_id : cmd.track_ids) {
          auto route = _session->route_by_id(PBD::ID(track_id));
          if (route) {
            if (cmd.muted.has_value()) {
              if (auto ctrl = route->mute_control()) {
                ctrl->set_value(*cmd.muted ? 1.0 : 0.0, PBD::Controllable::NoGroup);
              }
            }
            if (cmd.soloed.has_value()) {
              if (auto ctrl = route->solo_control()) {
                ctrl->set_value(*cmd.soloed ? 1.0 : 0.0, PBD::Controllable::NoGroup);
              }
            }
            if (cmd.volume.has_value()) {
              if (auto gain_ctrl = route->gain_control()) {
                // Convert dB to coefficient
                auto db = static_cast<float>(*cmd.volume);
                auto coef = std::pow(10.0f, db / 20.0f);
                gain_ctrl->set_value(coef, PBD::Controllable::NoGroup);
              }
            }
            if (cmd.pan.has_value()) {
              if (auto pan_ctrl = route->pan_azimuth_control()) {
                // Convert XDAW pan (-1 to +1) to Ardour azimuth (0 to 1)
                auto azimuth = (*cmd.pan + 1.0) / 2.0;
                pan_ctrl->set_value(azimuth, PBD::Controllable::NoGroup);
              }
            }
            if (cmd.armed.has_value()) {
              if (auto ardour_track = std::dynamic_pointer_cast<Track>(route)) {
                if (auto rec_ctrl = ardour_track->rec_enable_control()) {
                  rec_ctrl->set_value(*cmd.armed ? 1.0 : 0.0, PBD::Controllable::NoGroup);
                }
              }
            }
          }
        }
        break;
      }

      case xdaw::EditOperationType::Transport: {
        const auto& action = op.transport;
        switch (action.type) {
          case xdaw::TransportActionType::Play:
            if (action.bool_value) {
              _session->request_roll();
            } else {
              _session->request_stop();
            }
            break;
          case xdaw::TransportActionType::Stop:
            _session->request_stop();
            break;
          case xdaw::TransportActionType::Record:
            // Toggle record enable
            // TODO: Implement record arm
            break;
          case xdaw::TransportActionType::JumpToBeat: {
            auto tmap = Temporal::TempoMap::use();
            if (tmap) {
              auto beats = Temporal::Beats::from_double(action.double_value);
              auto samples = tmap->sample_at(beats);
              _session->request_locate(samples);
            }
            break;
          }
          case xdaw::TransportActionType::SetLoopActive:
            _session->request_play_loop(action.bool_value);
            break;
          case xdaw::TransportActionType::SetTempo: {
            auto bpm = std::max(0.01, action.double_value);
            auto tmap = Temporal::TempoMap::write_copy();
            auto note_type = tmap->metric_at(Temporal::timepos_t(0)).tempo().note_type();
            auto new_tempo = Temporal::Tempo(bpm, note_type);
            tmap->set_tempo(new_tempo, Temporal::timepos_t());
            Temporal::TempoMap::update(tmap);
            break;
          }
          default:
            break;
        }
        break;
      }

      case xdaw::EditOperationType::CreateClip: {
        const auto& cmd = op.create_clip;
        std::cerr << "[XDAW] CreateClip: track_id=" << cmd.track_id
                  << " file=" << cmd.content.audio_file_path << std::endl;

        // Validate we have audio content
        if (!cmd.content.is_audio_file()) {
          response.error_message = "Only audio file clips are supported";
          return response;
        }

        // Get the target track
        std::cerr << "[XDAW] Looking up route by ID: " << cmd.track_id << std::endl;
        auto route = _session->route_by_id(PBD::ID(cmd.track_id));
        if (!route) {
          std::cerr << "[XDAW] ERROR: Track not found!" << std::endl;
          response.error_message = "Track not found: " + cmd.track_id;
          return response;
        }
        std::cerr << "[XDAW] Found route: " << route->name() << std::endl;

        auto track = std::dynamic_pointer_cast<Track>(route);
        if (!track) {
          std::cerr << "[XDAW] ERROR: Route is not a track!" << std::endl;
          response.error_message = "Route is not a track";
          return response;
        }

        auto playlist = track->playlist();
        if (!playlist) {
          std::cerr << "[XDAW] ERROR: Track has no playlist!" << std::endl;
          response.error_message = "Track has no playlist";
          return response;
        }
        std::cerr << "[XDAW] Got playlist: " << playlist->name() << std::endl;

        // Create source(s) from the audio file
        // Multi-channel files need one source per channel
        std::cerr << "[XDAW] Creating sources from: " << cmd.content.audio_file_path << std::endl;
        SourceList sources;
        try {
          // Get channel count from file
          SoundFileInfo sf_info;
          std::string error_msg;
          if (!SndFileSource::get_soundfile_info(
                  cmd.content.audio_file_path, sf_info, error_msg)) {
            std::cerr << "[XDAW] ERROR: Cannot read audio file: " << error_msg << std::endl;
            response.error_message = "Cannot read audio file: " + error_msg;
            return response;
          }
          std::cerr << "[XDAW] File has " << sf_info.channels << " channels, "
                    << sf_info.samplerate << " Hz" << std::endl;

          for (uint32_t chn = 0; chn < sf_info.channels; ++chn) {
            std::cerr << "[XDAW] Creating source for channel " << chn << std::endl;
            auto source = SourceFactory::createExternal(
                DataType::AUDIO, *_session, cmd.content.audio_file_path,
                static_cast<int>(chn), Source::Flag(0), true);
            if (!source) {
              std::cerr << "[XDAW] ERROR: Failed to create source for channel " << chn << std::endl;
              response.error_message = "Failed to create source for channel " +
                                       std::to_string(chn);
              return response;
            }
            std::cerr << "[XDAW] Created source: " << source->name() << std::endl;
            sources.push_back(source);
          }
        } catch (const std::exception& e) {
          std::cerr << "[XDAW] EXCEPTION in source creation: " << e.what() << std::endl;
          response.error_message =
              std::string("Source creation failed: ") + e.what();
          return response;
        }

        if (sources.empty()) {
          std::cerr << "[XDAW] ERROR: No sources created" << std::endl;
          response.error_message = "No sources created from file";
          return response;
        }
        std::cerr << "[XDAW] Created " << sources.size() << " sources" << std::endl;

        // Convert beat position to samples
        auto tmap = Temporal::TempoMap::use();
        if (!tmap) {
          response.error_message = "No tempo map available";
          return response;
        }

        auto start_beats = Temporal::Beats::from_double(cmd.start_beat);
        auto start_samples = tmap->sample_at(start_beats);

        // Create a "whole file" region from the sources
        // Must set start, length, and other properties for the region to have audio
        std::cerr << "[XDAW] Creating whole_file region..." << std::endl;
        std::cerr << "[XDAW] Source length: " << sources[0]->length().samples() << " samples" << std::endl;

        auto plist = PBD::PropertyList{};
        plist.add(ARDOUR::Properties::start, Temporal::timecnt_t(Temporal::AudioTime));
        plist.add(ARDOUR::Properties::length, sources[0]->length());
        plist.add(ARDOUR::Properties::name, cmd.name.empty() ? sources[0]->name() : cmd.name);
        plist.add(ARDOUR::Properties::layer, 0);
        plist.add(ARDOUR::Properties::whole_file, true);
        plist.add(ARDOUR::Properties::external, true);
        plist.add(ARDOUR::Properties::opaque, true);

        std::shared_ptr<Region> region;
        try {
          region = RegionFactory::create(sources, plist, true, nullptr);
          if (!region) {
            std::cerr << "[XDAW] ERROR: RegionFactory::create returned null" << std::endl;
            response.error_message = "Failed to create region";
            return response;
          }
          std::cerr << "[XDAW] Created region: " << region->name()
                    << " length=" << region->length().samples() << " samples" << std::endl;
        } catch (const std::exception& e) {
          std::cerr << "[XDAW] EXCEPTION in region creation: " << e.what() << std::endl;
          response.error_message =
              std::string("Region creation failed: ") + e.what();
          return response;
        }

        // Add region to playlist at the specified position
        std::cerr << "[XDAW] Adding region to playlist at sample " << start_samples << std::endl;
        try {
          auto position = Temporal::timepos_t(start_samples);
          playlist->add_region(region, position, 1.0f, false);
          std::cerr << "[XDAW] SUCCESS! Region added, ID: " << region->id().to_s() << std::endl;
          response.created_ids.push_back(region->id().to_s());
        } catch (const std::exception& e) {
          std::cerr << "[XDAW] EXCEPTION adding to playlist: " << e.what() << std::endl;
          response.error_message =
              std::string("Failed to add region to playlist: ") + e.what();
          return response;
        }

        break;
      }

      case xdaw::EditOperationType::DeleteClip: {
        const auto& cmd = op.delete_clip;
        auto region = RegionFactory::region_by_id(PBD::ID(cmd.clip_id));
        if (!region) {
          response.error_message = "Clip not found: " + cmd.clip_id;
          return response;
        }
        auto playlist = region->playlist();
        if (!playlist) {
          response.error_message = "Clip not in any playlist: " + cmd.clip_id;
          return response;
        }
        playlist->remove_region(region);
        break;
      }

      default:
        // Ignore unimplemented operations
        break;
    }
  }

  response.success = true;
  return response;
}

// Helper to get file extension for format type
static auto get_file_extension(xdaw::FileType type) -> std::string {
  switch (type) {
    case xdaw::FileType::Wav:
      return ".wav";
    case xdaw::FileType::Aiff:
      return ".aiff";
    case xdaw::FileType::Flac:
      return ".flac";
    case xdaw::FileType::Ogg:
      return ".ogg";
    case xdaw::FileType::Mp3:
      return ".mp3";
    default:
      return ".wav";
  }
}

// Helper to get encoding format string for export XML
static auto get_encoding_format(xdaw::FileType type)
    -> std::pair<std::string, std::string> {
  switch (type) {
    case xdaw::FileType::Wav:
      return {"F_WAV", "wav"};
    case xdaw::FileType::Aiff:
      return {"F_AIFF", "aiff"};
    case xdaw::FileType::Flac:
      return {"F_FLAC", "flac"};
    case xdaw::FileType::Ogg:
      return {"F_Ogg", "ogg"};
    default:
      return {"F_WAV", "wav"};
  }
}

// Helper to get sample format string
static auto get_sample_format_string(int bit_depth) -> std::string {
  switch (bit_depth) {
    case 16:
      return "SF_16";
    case 24:
      return "SF_24";
    case 32:
      return "SF_32";
    default:
      return "SF_24";
  }
}

auto XDAWServer::start_render(const xdaw::RenderRequest& req)
    -> xdaw::RenderOperation {
  auto result = xdaw::RenderOperation{};

  // Generate unique operation ID
  static std::atomic<uint64_t> op_counter{0};
  result.operation_id =
      "render_" + std::to_string(++op_counter) + "_" +
      std::to_string(std::chrono::steady_clock::now().time_since_epoch().count());

  std::cerr << "[XDAW] start_render called: op_id=" << result.operation_id
            << " start_beat=" << req.start_beat
            << " length_beats=" << req.length_beats << std::endl;

  if (!_session) {
    std::cerr << "[XDAW] ERROR: No session!" << std::endl;
    result.error_message = "No session available";
    return result;
  }

  // Convert beats to samples
  auto tmap = Temporal::TempoMap::use();
  if (!tmap) {
    std::cerr << "[XDAW] ERROR: No tempo map!" << std::endl;
    result.error_message = "No tempo map available";
    return result;
  }

  auto start_beats = Temporal::Beats::from_double(req.start_beat);
  auto end_beats =
      Temporal::Beats::from_double(req.start_beat + req.length_beats);
  auto start_samples = tmap->sample_at(start_beats);
  auto end_samples = tmap->sample_at(end_beats);

  // Add tail if requested
  if (req.tail_length_seconds > 0) {
    auto tail_samples = static_cast<samplepos_t>(req.tail_length_seconds *
                                                  _session->sample_rate());
    end_samples += tail_samples;
  }

  if (start_samples >= end_samples) {
    result.error_message = "Invalid render range";
    return result;
  }

  // Get export handler
  auto handler = _session->get_export_handler();

  // Create timespan
  auto tsp = handler->add_timespan();
  tsp->set_range(start_samples, end_samples);

  // Create channel configuration from master outputs
  auto ccp = handler->add_channel_config();
  auto master_out = _session->master_out();
  if (!master_out) {
    result.error_message = "No master output";
    return result;
  }

  auto output = master_out->output().get();
  if (!output) {
    result.error_message = "No master output port";
    return result;
  }

  for (uint32_t n = 0; n < output->n_ports().n_audio(); ++n) {
    auto* channel = new PortExportChannel();
    channel->add_port(output->audio(n));
    ccp->register_channel(ExportChannelPtr(channel));
  }

  // Determine output path
  auto ext = get_file_extension(req.format.type);
  std::string output_folder;
  std::string output_name;

  if (!req.output_path.empty()) {
    output_folder = Glib::path_get_dirname(req.output_path);
    output_name = Glib::path_get_basename(req.output_path);
    auto dot_pos = output_name.rfind('.');
    if (dot_pos != std::string::npos) {
      output_name = output_name.substr(0, dot_pos);
    }
  } else {
    output_folder = _session->session_directory().export_path();
    output_name = "xdaw_render_" + std::to_string(start_samples);
  }

  g_mkdir_with_parents(output_folder.c_str(), 0755);

  // Create filename
  auto fnp = handler->add_filename();
  fnp->set_folder(output_folder);
  tsp->set_name(output_name);
  fnp->set_timespan(tsp);
  fnp->include_label = false;

  // Build format specification XML
  auto [format_id, format_ext] = get_encoding_format(req.format.type);
  auto sample_format = get_sample_format_string(
      req.format.bit_depth > 0 ? req.format.bit_depth : 24);
  auto sample_rate =
      req.format.sample_rate > 0
          ? std::to_string(req.format.sample_rate)
          : std::to_string(static_cast<int>(_session->sample_rate()));
  auto normalize = req.processing.peak.has_value() ? "true" : "false";

  auto format_xml =
      "<?xml version=\"1.0\" encoding=\"UTF-8\"?>"
      "<ExportFormatSpecification name=\"XDAW-EXPORT\" "
      "id=\"deadbeef-0000-4000-8000-000000000001\">"
      "  <Encoding id=\"" +
      format_id + "\" type=\"T_Sndfile\" extension=\"" + format_ext +
      "\" name=\"XDAW\" has-sample-format=\"true\" channel-limit=\"256\"/>"
      "  <SampleRate rate=\"" +
      sample_rate +
      "\"/>"
      "  <SRCQuality quality=\"SRC_SincBest\"/>"
      "  <EncodingOptions>"
      "    <Option name=\"sample-format\" value=\"" +
      sample_format +
      "\"/>"
      "    <Option name=\"dithering\" value=\"D_None\"/>"
      "    <Option name=\"tag-metadata\" value=\"true\"/>"
      "    <Option name=\"tag-support\" value=\"false\"/>"
      "    <Option name=\"broadcast-info\" value=\"false\"/>"
      "  </EncodingOptions>"
      "  <Processing>"
      "    <Normalize enabled=\"" +
      normalize +
      "\" target=\"0\"/>"
      "    <Silence>"
      "      <Start>"
      "        <Trim enabled=\"false\"/>"
      "        <Add enabled=\"false\">"
      "          <Duration format=\"Timecode\" hours=\"0\" minutes=\"0\" "
      "seconds=\"0\" frames=\"0\"/>"
      "        </Add>"
      "      </Start>"
      "      <End>"
      "        <Trim enabled=\"false\"/>"
      "        <Add enabled=\"false\">"
      "          <Duration format=\"Timecode\" hours=\"0\" minutes=\"0\" "
      "seconds=\"0\" frames=\"0\"/>"
      "        </Add>"
      "      </End>"
      "    </Silence>"
      "  </Processing>"
      "</ExportFormatSpecification>";

  XMLTree tree;
  if (!tree.read_buffer(format_xml.c_str())) {
    result.error_message = "Failed to parse format specification";
    return result;
  }

  auto fmp = handler->add_format(*tree.root());
  fmp->set_soundcloud_upload(false);

  handler->add_export_config(tsp, ccp, fmp, fnp, nullptr);

  auto final_path = Glib::build_filename(output_folder, output_name + ext);
  std::cerr << "[XDAW] Starting async export to: " << final_path << std::endl;

  // Start the export (non-blocking!)
  if (0 != handler->do_export()) {
    result.error_message = "do_export() failed";
    return result;
  }

  // Track this pending render - check_pending_renders will poll for completion
  pending_renders_.push_back(PendingRender{
      .operation_id = result.operation_id,
      .output_path = final_path,
      .stream_response = req.stream_response,
  });

  std::cerr << "[XDAW] Export started, returning operation_id: "
            << result.operation_id << std::endl;

  return result;  // Return immediately, no blocking!
}

auto XDAWServer::check_pending_renders() -> void {
  if (!_session || pending_renders_.empty()) {
    return;
  }

  auto status = _session->get_export_status();

  // If export is still running, nothing to do
  if (status->running()) {
    return;
  }

  // Export finished - process all pending renders
  for (auto& pending : pending_renders_) {
    auto complete = xdaw::RenderComplete{};
    complete.operation_id = pending.operation_id;

    if (status->aborted()) {
      complete.success = false;
      complete.error_message = "Export was aborted";
      std::cerr << "[XDAW] Render " << pending.operation_id << " aborted"
                << std::endl;
    } else {
      complete.success = true;
      complete.output_path = pending.output_path;
      std::cerr << "[XDAW] Render " << pending.operation_id
                << " complete: " << pending.output_path << std::endl;

      // Read audio data if streaming was requested
      if (pending.stream_response) {
        std::ifstream file(pending.output_path, std::ios::binary);
        if (file) {
          complete.audio_data = std::vector<uint8_t>(
              std::istreambuf_iterator<char>(file),
              std::istreambuf_iterator<char>());
        }
      }
    }

    // Push completion notification to all subscribers
    server_->push_notification(
        xdaw::Notification::make_render_complete(complete));
  }

  status->finish(TRS_UI);
  pending_renders_.clear();
}

}  // namespace ARDOUR
