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

#include <glibmm/miscutils.h>

#include "ardour/audio_track.h"
#include "ardour/audioregion.h"
#include "ardour/gain_control.h"
#include "ardour/midi_track.h"
#include "ardour/panner_shell.h"
#include "ardour/playlist.h"
#include "ardour/region.h"
#include "ardour/route.h"
#include "ardour/session.h"
#include "ardour/simple_export.h"
#include "ardour/track.h"

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
      [this](const xdaw::RenderRequest& req, auto writer) {
        render_region(req, writer);
      });

  server_->set_notification_handler([this]() {
    tasks_pending_.store(true, std::memory_order_release);
  });
}

auto XDAWServer::start() -> void { server_->start(); }

auto XDAWServer::stop() -> void { server_->stop(); }

auto XDAWServer::is_running() const -> bool { return server_->is_running(); }

auto XDAWServer::process_pending_tasks() -> void {
  server_->process_pending_tasks();
}

auto XDAWServer::has_pending_tasks() -> bool {
  return tasks_pending_.exchange(false, std::memory_order_acq_rel);
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
          auto tracks = _session->new_audio_track(
              1,       // input channels
              2,       // output channels
              nullptr, // route group
              1,       // how many
              cmd.name.empty() ? "Audio" : cmd.name,
              PresentationInfo::max_order,
              Normal);
          for (const auto& t : tracks) {
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
          case xdaw::TransportActionType::SetTempo:
            // TODO: Implement tempo change
            break;
          default:
            break;
        }
        break;
      }

      case xdaw::EditOperationType::CreateClip:
        // TODO: Implement audio file import
        response.error_message = "CreateClip not yet implemented";
        return response;

      case xdaw::EditOperationType::DeleteClip:
        // TODO: Implement region deletion
        response.error_message = "DeleteClip not yet implemented";
        return response;

      default:
        // Ignore unimplemented operations
        break;
    }
  }

  response.success = true;
  return response;
}

auto XDAWServer::render_region(
    const xdaw::RenderRequest& req,
    std::function<void(const std::vector<float>&, bool, const std::string&)>
        writer) -> void {
  if (!_session) {
    writer({}, true, "");
    return;
  }

  auto simple_export = SimpleExport{};
  simple_export.set_session(_session);

  // Convert beats to samples
  auto tmap = Temporal::TempoMap::use();
  if (!tmap) {
    writer({}, true, "");
    return;
  }

  auto start_beats = Temporal::Beats::from_double(req.start_beat);
  auto end_beats = Temporal::Beats::from_double(req.start_beat + req.length_beats);
  auto start_samples = tmap->sample_at(start_beats);
  auto end_samples = tmap->sample_at(end_beats);

  simple_export.set_range(start_samples, end_samples);

  if (!req.output_path.empty()) {
    auto folder = Glib::path_get_dirname(req.output_path);
    auto name = Glib::path_get_basename(req.output_path);
    // Remove extension from name
    auto dot_pos = name.rfind('.');
    if (dot_pos != std::string::npos) {
      name = name.substr(0, dot_pos);
    }
    simple_export.set_folder(folder);
    simple_export.set_name(name);
  }

  auto success = simple_export.run_export();

  if (success) {
    writer({}, true, req.output_path);
  } else {
    writer({}, true, "");
  }
}

}  // namespace ARDOUR
