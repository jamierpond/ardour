# Port of gtk2_ardour/wscript: the GUI executable and the generated files it
# reads at run time. gtk2ardour-config.h is written by FindArdourDeps at the
# point this wscript's configure() writes it.

set(ARDOUR_EXECUTABLE_NAME "ardour-${ARDOUR_VERSION}")

ardour_add_executable(ardour-gui OUTPUT_NAME "${ARDOUR_EXECUTABLE_NAME}")

target_sources(ardour-gui PRIVATE
        about.cc
        actions.cc
        add_route_dialog.cc
        ambiguous_file_dialog.cc
        analysis_window.cc
        application_bar.cc
        ardour_color_dialog.cc
        ardour_dialog.cc
        ardour_http.cc
        ardour_message.cc
        ardour_ui.cc
        ardour_ui2.cc
        ardour_ui3.cc
        ardour_ui_aaf.cc
        ardour_ui_access_web.cc
        ardour_ui_dependents.cc
        ardour_ui_dialogs.cc
        ardour_ui_ed.cc
        ardour_ui_engine.cc
        ardour_ui_keys.cc
        ardour_ui_mixer.cc
        ardour_ui_options.cc
        ardour_ui_session.cc
        ardour_ui_startup.cc
        ardour_ui_video.cc
        ardour_window.cc
        audio_clock.cc
        audio_clip_editor.cc
        audio_region_editor.cc
        audio_region_view.cc
        audio_trigger_properties_box.cc
        audio_streamview.cc
        audio_time_axis.cc
        automation_controller.cc
        automation_line.cc
        automation_region_view.cc
        automation_streamview.cc
        automation_text_entry.cc
        automation_time_axis.cc
        axis_view.cc
        bbt_marker_dialog.cc
        big_clock_window.cc
        big_transport_window.cc
        boundary.cc
        bundle_manager.cc
        canvas_icon.cc
        chord_box.cc
        chord_dialog.cc
        chord_editor.cc
        clock_group.cc
        color_theme_manager.cc
        configinfo.cc
        control_point.cc
        control_point_dialog.cc
        control_slave_ui.cc
        cross_cursor.cc
        cuebox_ui.cc
        cue_editor.cc
        curvetest.cc
        debug.cc
        dsp_stats_ui.cc
        dsp_stats_window.cc
        duplicate_routes_dialog.cc
        edit_note_dialog.cc
        editing.cc
        editing_context.cc
        editor.cc
        editor_actions.cc
        editor_automation_line.cc
        editor_audio_import.cc
        editor_pt_import.cc
        editor_audiotrack.cc
        editor_canvas.cc
        editor_canvas_events.cc
        editor_component.cc
        editor_cursors.cc
        editor_drag.cc
        editor_route_groups.cc
        editor_section_box.cc
        editor_export_audio.cc
        editor_group_tabs.cc
        editor_keys.cc
        editor_locations.cc
        editor_markers.cc
        editor_mixer.cc
        editor_mouse.cc
        editor_ops.cc
        editor_regions.cc
        editor_routes.cc
        editor_rulers.cc
        editor_sections.cc
        editor_selection.cc
        editor_snapshots.cc
        editor_sources.cc
        editor_summary.cc
        editor_tempodisplay.cc
        editor_timefx.cc
        editor_vsummary.cc
        engine_dialog.cc
        enums.cc
        export_analysis_graphs.cc
        export_channel_selector.cc
        export_dialog.cc
        export_file_notebook.cc
        export_filename_selector.cc
        export_format_dialog.cc
        export_format_selector.cc
        export_preset_selector.cc
        export_report.cc
        export_timespan_selector.cc
        fitted_canvas_widget.cc
        fft.cc
        fft_graph.cc
        fft_result.cc
        floating_text_entry.cc
        foldback_strip.cc
        sfdb_freesound_mootcher.cc
        gain_meter.cc
        generic_pluginui.cc
        ghost_event.cc
        ghostregion.cc
        global_port_matrix.cc
        group_tabs.cc
        gui_object.cc
        idleometer.cc
        input_port_monitor.cc
        insert_remove_time_dialog.cc
        instrument_selector.cc
        interthread_progress_window.cc
        io_button.cc
        io_plugin_window.cc
        io_selector.cc
        hit.cc
        keyboard.cc
        keyeditor.cc
        led.cc
        level_meter.cc
        library_download_dialog.cc
        location_ui.cc
        loudness_dialog.cc
        loudness_settings.cc
        lua_script_manager.cc
        luadialog.cc
        luainstance.cc
        luawindow.cc
        main.cc
        main_clock.cc
        marker.cc
        mergeable_line.cc
        midi_automation_line.cc
        midi_channel_dialog.cc
        midi_channel_selector.cc
        midi_cut_buffer.cc
        midi_export_dialog.cc
        midi_inspector.cc
        midi_list_editor.cc
        midi_region_view.cc
        midi_trigger_properties_box.cc
        midi_selection.cc
        midi_streamview.cc
        midi_time_axis.cc
        midi_tracer.cc
        midi_util.cc
        midi_velocity_dialog.cc
        midi_view.cc
        midi_view_background.cc
        mini_timeline.cc
        missing_file_dialog.cc
        missing_filesource_dialog.cc
        missing_plugin_dialog.cc
        mixer_group_tabs.cc
        mixer_strip.cc
        mixer_ui.cc
        meterbridge.cc
        meter_strip.cc
        meter_patterns.cc
        monitor_section.cc
        mono_panner.cc
        mono_panner_editor.cc
        mouse_cursors.cc
        nag.cc
        new_plugin_preset_dialog.cc
        new_user_wizard.cc
        normalize_dialog.cc
        note.cc
        note_base.cc
        note_player.cc
        note_select_dialog.cc
        nsm.cc
        nsmclient.cc
        option_editor.cc
        opts.cc
        panner2d.cc
        panner_editor.cc
        panner_interface.cc
        panner_ui.cc
        patch_change.cc
        patch_change_widget.cc
        pianokeyboard.cc
        piano_key_bindings.cc
        piano_roll_header.cc
        pianoroll.cc
        pianoroll_automation_line.cc
        pianoroll_background.cc
        pianoroll_velocity.cc
        pianoroll_midi_view.cc
        pianoroll_window.cc
        pingback.cc
        pitch_color_dialog.cc
        playlist_selector.cc
        plugin_display.cc
        plugin_eq_gui.cc
        plugin_manager_ui.cc
        plugin_pin_dialog.cc
        plugin_presets_ui.cc
        plugin_scan_dialog.cc
        plugin_setup_dialog.cc
        plugin_selector.cc
        plugin_ui.cc
        plugin_dspload_ui.cc
        plugin_dspload_window.cc
        plugin_window_proxy.cc
        port_group.cc
        port_insert_ui.cc
        port_matrix.cc
        port_matrix_body.cc
        port_matrix_column_labels.cc
        port_matrix_component.cc
        port_matrix_grid.cc
        port_matrix_labels.cc
        port_matrix_row_labels.cc
        prh.cc
        prh_base.cc
        processor_box.cc
        processor_selection.cc
        patch_change_dialog.cc
        progress_reporter.cc
        pt_import_selector.cc
        public_editor.cc
        quantize_dialog.cc
        rc_option_editor.cc
        rec_info_box.cc
        recorder_group_tabs.cc
        recorder_ui.cc
        region_editor.cc
        region_editor_window.cc
        region_fx_line.cc
        region_fx_properties_box.cc
        region_gain_line.cc
        region_layering_order_editor.cc
        region_list_base.cc
        region_peak_cursor.cc
        region_selection.cc
        region_ui_settings.cc
        region_view.cc
        return_ui.cc
        rhythm_ferret.cc
        route_comment_editor.cc
        route_group_dialog.cc
        route_group_menu.cc
        route_list_base.cc
        route_params_ui.cc
        route_properties_box.cc
        route_processor_selection.cc
        route_time_axis.cc
        route_ui.cc
        rta_manager.cc
        rta_window.cc
        ruler_dialog.cc
        save_as_dialog.cc
        save_template_dialog.cc
        search_path_option.cc
        screensaver.cc
        script_selector.cc
        selection.cc
        selection_properties_box.cc
        selection_memento.cc
        send_ui.cc
        session_archive_dialog.cc
        session_dialog.cc
        session_metadata_dialog.cc
        session_option_editor.cc
        scale_dialog.cc
        sfdb_ui.cc
        shuttle_control.cc
        simple_export_dialog.cc
        slot_properties_box.cc
        source_list_base.cc
        soundcloud_export_selector.cc
        splash.cc
        speaker_dialog.cc
        startup_fsm.cc
        step_editor.cc
        step_entry.cc
        stereo_panner.cc
        stereo_panner_editor.cc
        streamview.cc
        strip_export_dialog.cc
        strip_import_dialog.cc
        strip_silence_dialog.cc
        stripable_colorpicker.cc
        stripable_time_axis.cc
        surround_strip.cc
        sys_ex.cc
        template_dialog.cc
        tempo_curve.cc
        tempo_dialog.cc
        grid_lines.cc
        tempo_map_change.cc
        time_axis_view.cc
        time_axis_view_item.cc
        time_fx_dialog.cc
        time_info_box.cc
        time_selection.cc
        timectl_gui.cc
        timers.cc
        track_record_axis.cc
        track_selection.cc
        track_view_list.cc
        transform_dialog.cc
        transport_control.cc
        transport_control_ui.cc
        transport_masters_dialog.cc
        transpose_dialog.cc
        trigger_clip_picker.cc
        trigger_jump_dialog.cc
        trigger_page.cc
        trigger_region_list.cc
        trigger_route_list.cc
        trigger_source_list.cc
        trigger_strip.cc
        trigger_master.cc
        trigger_ui.cc
        triggerbox_ui.cc
        ui_config.cc
        utils.cc
        varispeed_dialog.cc
        vca_master_strip.cc
        verbose_cursor.cc
        virtual_keyboard_window.cc
        visibility_group.cc
        window_manager.cc
        video_image_frame.cc
        add_video_dialog.cc
        editor_videotimeline.cc
        vca_time_axis.cc
        video_timeline.cc
        video_monitor.cc
        view_background.cc
        transcode_ffmpeg.cc
        transcode_video_dialog.cc
        velocity_display.cc
        velocity_ghost_region.cc
        video_server_dialog.cc
        utils_videotl.cc
        export_video_dialog.cc)

ardour_includes(ardour-gui PRIVATE . ../libs ../libs/vst3)

ardour_use(ardour-gui
        pbd
        ardour
        ardourcp
        temporal
        midipp
        gtkmm2ext
        canvas
        waveview
        widgets
        ptformat
        ytk
        ytkmm
        aaf)

# 'SUIL' in the wscript's use list names no task generator or uselib, and
# "obj.use += ' libappleutility'" appends single characters to a list; both
# are no-ops in waf. libsuil and libappleutility still end up linked, through
# libardour, exactly as in the waf build.
ardour_uselib(ardour-gui
        UUID FLAC FONTCONFIG GTHREAD OGG PANGOMM CURL DL CANVAS FFTW3F LO TAGLIB
        XML LILV RUBBERBAND AUBIO LRDF ARCHIVE VAMPSDK VAMPHOSTSDK GLIBMM GIOMM
        PANGOFT2 LIBPNG LIBJPEG)

target_compile_definitions(ardour-gui PRIVATE
        "PACKAGE=\"gtk2_ardour${ARDOUR_VERSION_MAJOR}\""
        "DATA_DIR=\"${ARDOUR_DATADIR}\""
        "CONFIG_DIR=\"${CMAKE_INSTALL_FULL_SYSCONFDIR}\""
        "LOCALEDIR=\"${ARDOUR_LOCALEDIR}\"")

if (TARGET Ardour::USB)
    ardour_uselib(ardour-gui USB)
endif ()

if (APPLE)
    ardour_uselib(ardour-gui AUDIOUNITS OSX)
    target_sources(ardour-gui PRIVATE cocoacarbon.mm bundle_env_cocoa.cc)
elseif (WIN32)
    target_sources(ardour-gui PRIVATE bundle_env_mingw.cc)
else ()
    target_sources(ardour-gui PRIVATE bundle_env_linux.cc)
    ardour_uselib(ardour-gui X11)
endif ()

if (HAVE_SUIL)
    target_sources(ardour-gui PRIVATE lv2_plugin_ui.cc)
endif ()

if (NEED_INTL)
    ardour_link_intl(ardour-gui)
endif ()

if (WINDOWS_VST_SUPPORT)
    target_sources(ardour-gui PRIVATE windows_vst_plugin_ui.cc)
    target_compile_definitions(ardour-gui PRIVATE WINDOWS_VST_SUPPORT)
    ardour_includes(ardour-gui PRIVATE ../libs/fst)
endif ()

if (LXVST_SUPPORT)
    target_sources(ardour-gui PRIVATE linux_vst_gui_support.cc lxvst_plugin_ui.cc)
    target_compile_definitions(ardour-gui PRIVATE LXVST_SUPPORT)
endif ()

if (MACVST_SUPPORT)
    target_sources(ardour-gui PRIVATE mac_vst_plugin_ui.mm)
    target_compile_definitions(ardour-gui PRIVATE MACVST_SUPPORT)
endif ()

if (WINDOWS_VST_SUPPORT OR LXVST_SUPPORT OR MACVST_SUPPORT)
    target_sources(ardour-gui PRIVATE vst_plugin_ui.cc)
endif ()

if (PHONE_HOME)
    target_compile_definitions(ardour-gui PRIVATE PHONE_HOME)
endif ()

if (AUDIOUNIT_SUPPORT)
    target_sources(ardour-gui PRIVATE au_pluginui.mm)
endif ()

if (VST3_SUPPORT)
    target_sources(ardour-gui PRIVATE vst3_plugin_ui.cc)
    if (APPLE)
        target_sources(ardour-gui PRIVATE vst3_nsview_plugin_ui.mm)
    elseif (WIN32)
        target_sources(ardour-gui PRIVATE vst3_hwnd_plugin_ui.cc)
    else ()
        target_sources(ardour-gui PRIVATE vst3_x11_plugin_ui.cc)
    endif ()
endif ()

# --- gtk2ardour-version.h ---------------------------------------------------
# VERSIONSTRING and CODENAME; the codename table lives in the wscript and the
# script reads it from there.
add_custom_command(
        OUTPUT "${CMAKE_CURRENT_BINARY_DIR}/gtk2ardour-version.h"
        COMMAND Python3::Interpreter "${PROJECT_SOURCE_DIR}/scripts/gen-gtk2ardour-version.py"
                "${CMAKE_CURRENT_SOURCE_DIR}/wscript"
                "${ARDOUR_VERSION}" "${ARDOUR_VERSION_MAJOR}" "${ARDOUR_VERSION_MINOR}"
                "${CMAKE_CURRENT_BINARY_DIR}/gtk2ardour-version.h"
        DEPENDS "${PROJECT_SOURCE_DIR}/scripts/gen-gtk2ardour-version.py"
                "${CMAKE_CURRENT_SOURCE_DIR}/wscript"
        VERBATIM)
target_sources(ardour-gui PRIVATE "${CMAKE_CURRENT_BINARY_DIR}/gtk2ardour-version.h")

include(ArdourGtkResources)
