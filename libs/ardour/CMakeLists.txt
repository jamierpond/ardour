# Port of libs/ardour/wscript.

ardour_add_library(ardour SHARED)

# revision.cc and config_text.cc are generated (see below); waf writes them
# into the source tree, CMake into the build tree.
set(_ardour_generated revision.cc config_text.cc)

set(_libardour_sources
        amp.cc
        analyser.cc
        analysis_graph.cc
        async_midi_port.cc
        audio_backend.cc
        audio_buffer.cc
        audio_library.cc
        audio_playlist.cc
        audio_playlist_source.cc
        audio_port.cc
        audio_track.cc
        audioanalyser.cc
        audioengine.cc
        audiofile_tagger.cc
        audiofilesource.cc
        audioregion.cc
        audiorom.cc
        audiosource.cc
        auditioner.cc
        automatable.cc
        automation.cc
        automation_control.cc
        automation_list.cc
        automation_watch.cc
        broadcast_info.cc
        buffer.cc
        buffer_manager.cc
        buffer_set.cc
        bundle.cc
        butler.cc
        capturing_processor.cc
        chan_count.cc
        chan_mapping.cc
        chord_provider.cc
        circular_buffer.cc
        clip_library.cc
        config_text.cc
        control_group.cc
        control_protocol_manager.cc
        convolver.cc
        data_type.cc
        default_click.cc
        debug.cc
        delayline.cc
        delivery.cc
        demo_sessions.cc
        directory_names.cc
        disk_io.cc
        disk_reader.cc
        disk_writer.cc
        dsp_filter.cc
        ebur128_analysis.cc
        element_import_handler.cc
        engine_slave.cc
        enums.cc
        event_type_map.cc
        export_channel.cc
        export_channel_configuration.cc
        export_failed.cc
        export_filename.cc
        export_format_base.cc
        export_format_manager.cc
        export_format_specification.cc
        export_formats.cc
        export_graph_builder.cc
        export_handler.cc
        export_preset.cc
        export_profile_manager.cc
        export_smf_writer.cc
        export_status.cc
        export_timespan.cc
        ffmpegfileimportable.cc
        ffmpegfilesource.cc
        file_source.cc
        filename_extensions.cc
        filesystem_paths.cc
        filter.cc
        find_session.cc
        fixed_delay.cc
        fluid_synth.cc
        gain_control.cc
        globals.cc
        graph.cc
        graphnode.cc
        graph_edges.cc
        iec1ppmdsp.cc
        iec2ppmdsp.cc
        import.cc
        import_pt.cc
        instrument_info.cc
        internal_return.cc
        internal_send.cc
        io.cc
        io_plug.cc
        io_processor.cc
        io_tasklist.cc
        kmeterdsp.cc
        ladspa_plugin.cc
        latent.cc
        legatize.cc
        library.cc
        location.cc
        ltc_file_reader.cc
        ltc_slave.cc
        lua_api.cc
        luaproc.cc
        luascripting.cc
        lufs_meter.cc
        lv2_evbuf.cc
        uri_map.cc
        lv2_plugin.cc
        meter.cc
        midi_automation_list_binder.cc
        midi_buffer.cc
        midi_channel_filter.cc
        midi_clock_slave.cc
        midi_model.cc
        midi_patch_manager.cc
        midi_playlist.cc
        midi_port.cc
        midi_region.cc
        midi_ring_buffer.cc
        midi_scene_change.cc
        midi_scene_changer.cc
        midi_source.cc
        midi_state_tracker.cc
        midi_stretch.cc
        midi_track.cc
        midi_ui.cc
        mididm.cc
        midiport_manager.cc
        minibpm.cc
        mix.cc
        mixer_scene.cc
        monitor_control.cc
        monitor_port.cc
        monitor_processor.cc
        monitor_return.cc
        mp3fileimportable.cc
        mp3filesource.cc
        mtc_slave.cc
        mtdm.cc
        muteable.cc
        mute_control.cc
        mute_master.cc
        onset_detector.cc
        operations.cc
        pan_controllable.cc
        pannable.cc
        panner.cc
        panner_manager.cc
        panner_shell.cc
        parameter_descriptor.cc
        phase_control.cc
        playlist.cc
        playlist_factory.cc
        playlist_source.cc
        plug_insert_base.cc
        plugin.cc
        plugin_insert.cc
        plugin_manager.cc
        plugin_scan_result.cc
        polarity_processor.cc
        port.cc
        port_engine_shared.cc
        port_insert.cc
        port_manager.cc
        port_set.cc
        presentation_info.cc
        process_thread.cc
        processor.cc
        quantize.cc
        rc_configuration.cc
        readable.cc
        readonly_control.cc
        raw_midi_parser.cc
        recent_sessions.cc
        record_enable_control.cc
        record_safe_control.cc
        region_factory.cc
        region_fx_plugin.cc
        resampled_source.cc
        region.cc
        return.cc
        reverse.cc
        route.cc
        route_group.cc
        route_group_member.cc
        rb_effect.cc
        rt_task.cc
        rt_tasklist.cc
        scala_kbm.cc
        scala_scl.cc
        scale.cc
        scale_provider.cc
        scene_change.cc
        search_paths.cc
        segment_descriptor.cc
        selection.cc
        send.cc
        session.cc
        session_bundles.cc
        session_butler.cc
        session_click.cc
        session_command.cc
        session_configuration.cc
        session_directory.cc
        session_events.cc
        session_export.cc
        session_handle.cc
        session_ltc.cc
        session_metadata.cc
        session_midi.cc
        session_object.cc
        session_playlists.cc
        session_process.cc
        session_rtevents.cc
        session_state.cc
        session_state_utils.cc
        session_time.cc
        session_transport.cc
        sidechain.cc
        simple_export.cc
        slavable.cc
        slavable_automation_control.cc
        smf_source.cc
        sndfile_helpers.cc
        sndfileimportable.cc
        sndfilesource.cc
        solo_control.cc
        solo_isolate_control.cc
        solo_mute_release.cc
        solo_safe_control.cc
        soundcloud_upload.cc
        source.cc
        source_factory.cc
        sp_stretch.cc
        speakers.cc
        srcfilesource.cc
        stripable.cc
        strip_silence.cc
        strum.cc
        surround_pannable.cc
        surround_return.cc
        surround_send.cc
        system_exec.cc
        revision.cc
        rt_midibuffer.cc
        tailtime.cc
        template_utils.cc
        thawlist.cc
        thread_buffers.cc
        ticker.cc
        track.cc
        transient_detector.cc
        transform.cc
        transport_fsm.cc
        transport_master.cc
        transport_master_manager.cc
        transpose.cc
        triggerbox.cc
        unknown_processor.cc
        user_bundle.cc
        utils.cc
        vca.cc
        vca_manager.cc
        velocity_control.cc
        video_tools_paths.cc
        vumeterdsp.cc
        wallclock_transport.cc
        worker.cc
        zeroconf.cc)
list(REMOVE_ITEM _libardour_sources ${_ardour_generated})
target_sources(ardour PRIVATE
        ${_libardour_sources}
        "${CMAKE_CURRENT_BINARY_DIR}/revision.cc"
        "${CMAKE_CURRENT_BINARY_DIR}/config_text.cc")

ardour_includes(ardour PUBLIC . PRIVATE ../vst3/ ../ctrl-interface/control_protocol ..)

set(_libardour_uselib
        GLIBMM GTHREAD AUBIO SIGCPP XML UUID LO USB
        SNDFILE SAMPLERATE LRDF AUDIOUNITS GIOMM FFTW3F
        LILV SERD SORD SRATOM
        OSX BOOST CURL TAGLIB VAMPSDK VAMPHOSTSDK RUBBERBAND)
if (NOT WIN32)
    list(APPEND _libardour_uselib DL)
endif ()

# 'librubberband' and 'libltc_includes'/'libfluidsynth_includes' in the
# wscript's use list name task generators that are folded into the ltc and
# fluidsynth targets here (or no longer exist).
set(_libardour_use
        pbd midipp evoral
        audiographer
        temporal
        lua
        ptformat
        staffpad
        zita-resampler
        zita-convolver
        ltc
        fluidsynth)

target_compile_definitions(ardour PRIVATE
        LIBARDOUR_DLL_EXPORTS=1
        "PACKAGE=\"ardour${ARDOUR_VERSION_MAJOR}\""
        "DATA_DIR=\"${ARDOUR_DATADIR}\""
        "CONFIG_DIR=\"${CMAKE_INSTALL_FULL_SYSCONFDIR}\""
        "LOCALEDIR=\"${ARDOUR_LOCALEDIR}\""
        "LIBARDOUR=\"${ARDOUR_LWRCASE_DIRNAME}\"")

if (TARGET suil)
    list(APPEND _libardour_use suil)
endif ()

if (WINDOWS_VST_SUPPORT)
    target_sources(ardour PRIVATE windows_vst_plugin.cc)
    target_compile_definitions(ardour PRIVATE WINDOWS_VST_SUPPORT)
    ardour_includes(ardour PRIVATE ../fst)
    list(APPEND _libardour_uselib GDI32)
endif ()

if (LXVST_SUPPORT)
    target_sources(ardour PRIVATE lxvst_plugin.cc linux_vst_support.cc)
    target_compile_definitions(ardour PRIVATE LXVST_SUPPORT)
endif ()

if (WINDOWS_VST_SUPPORT OR LXVST_SUPPORT OR MACVST_SUPPORT)
    target_sources(ardour PRIVATE session_vst.cc vst_plugin.cc vst_state.cc vst2_scan.cc)
endif ()

if (MACVST_SUPPORT)
    target_sources(ardour PRIVATE mac_vst_plugin.cc mac_vst_support.cc)
    target_compile_definitions(ardour PRIVATE MACVST_SUPPORT)
endif ()

if (VST3_SUPPORT)
    target_sources(ardour PRIVATE vst3_plugin.cc vst3_module.cc vst3_host.cc vst3_scan.cc)
    target_compile_definitions(ardour PRIVATE VST3_SUPPORT)
endif ()

if (HAVE_COREAUDIO)
    target_sources(ardour PRIVATE coreaudiosource.cc caimportable.cc)
    list(APPEND _libardour_use appleutility)
endif ()

if (AUDIOUNIT_SUPPORT)
    target_sources(ardour PRIVATE audio_unit.cc auv2_scan.cc)
endif ()

# The Lua bindings are one huge translation unit, built as a static library
# with libardour's includes, uselibs and (so far) use list.
ardour_add_library(luabindings STATIC)
target_sources(luabindings PRIVATE luabindings.cc)
ardour_includes(luabindings PRIVATE . ../vst3/ ../ctrl-interface/control_protocol ..)
ardour_uselib(luabindings ${_libardour_uselib})
ardour_use(luabindings ${_libardour_use})

list(APPEND _libardour_use luabindings)

# FPU-specific kernels. Only the x86 and aarch64 Linux targets have any: a
# macOS build (any arch) uses the Accelerate path in BUILD_VECLIB_OPTIMIZATIONS.
if (ARDOUR_FPU_OPTIMIZATION AND NOT APPLE)
    if (CMAKE_SYSTEM_PROCESSOR MATCHES "x86_64|AMD64")
        enable_language(ASM)
        target_sources(ardour PRIVATE sse_functions_xmm.cc sse_functions_64bit.s)
        set(_ardour_avx_sources sse_functions_avx_linux.cc)
    elseif (CMAKE_SYSTEM_PROCESSOR MATCHES "i[3-6]86")
        enable_language(ASM)
        target_sources(ardour PRIVATE sse_functions_xmm.cc sse_functions.s)
        set(_ardour_avx_sources sse_functions_avx_linux.cc)
    elseif (CMAKE_SYSTEM_PROCESSOR MATCHES "aarch64")
        target_sources(ardour PRIVATE aarch64_neon_functions.cc)
        target_compile_definitions(ardour PRIVATE ARM_NEON_SUPPORT)
    endif ()

    if (_ardour_avx_sources)
        ardour_add_library(sse_avx_functions STATIC)
        target_sources(sse_avx_functions PRIVATE ${_ardour_avx_sources})
        target_compile_options(sse_avx_functions PRIVATE -mavx)
        ardour_includes(sse_avx_functions PRIVATE .)
        ardour_use(sse_avx_functions temporal pbd evoral lua)
        ardour_uselib(sse_avx_functions GLIBMM XML)
        list(APPEND _libardour_use sse_avx_functions)
    endif ()
endif ()

ardour_uselib(ardour ${_libardour_uselib})
ardour_use(ardour ${_libardour_use})

# --- generated sources ------------------------------------------------------

# revision.cc: waf's create_stored_revision() runs on every build; so does this
# (the script only rewrites the file when HEAD moved).
add_custom_target(ardour-revision
        COMMAND "${ARDOUR_NODE}" "${PROJECT_SOURCE_DIR}/scripts/ardour-version.mjs"
                --revision-cc "${CMAKE_CURRENT_BINARY_DIR}/revision.cc"
        BYPRODUCTS "${CMAKE_CURRENT_BINARY_DIR}/revision.cc"
        COMMENT "Updating libs/ardour/revision.cc"
        VERBATIM)
add_dependencies(ardour ardour-revision)

# config_text.cc: the build summary shown in the About dialog, written by the
# root wscript's configure().
include(ArdourConfigText)
ardour_write_config_text("${CMAKE_CURRENT_BINARY_DIR}/config_text.cc")
