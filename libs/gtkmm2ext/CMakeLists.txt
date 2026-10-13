# Port of libs/gtkmm2ext/wscript.

ardour_add_library(gtkmm2ext SHARED)

target_sources(gtkmm2ext PRIVATE
        actions.cc
        action_model.cc
        application.cc
        bindings.cc
        cairo_packer.cc
        cairo_theme.cc
        cairo_widget.cc
        cell_renderer_button.cc
        cell_renderer_color_selector.cc
        cell_renderer_pixbuf_multi.cc
        cell_renderer_pixbuf_toggle.cc
        colors.cc
        colorspace.cc
        cursors.cc
        debug.cc
        dndtreeview.cc
        emscale.cc
        gtk_ui.cc
        gtkapplication.c
        keyboard.cc
        menu_elems.cc
        persistent_tooltip.cc
        string_completion.cc
        textviewer.cc
        treeutils.cc
        ui_config.cc
        utils.cc
        visibility_tracker.cc
        window_proxy.cc
        window_title.cc)

ardour_includes(gtkmm2ext PUBLIC .)
ardour_uselib(gtkmm2ext XML CAIROMM PANGOMM GLIBMM GIOMM)
ardour_use(gtkmm2ext pbd ydk ydkmm ytkmm)
target_compile_definitions(gtkmm2ext PRIVATE
        LIBGTKMM2EXT_DLL_EXPORTS
        ABSTRACT_UI_EXPORTS
        "PACKAGE=\"gtkmm2ext3\""
        "LOCALEDIR=\"${ARDOUR_LOCALEDIR}\"")

if (APPLE)
    target_sources(gtkmm2ext PRIVATE gtkapplication_quartz.mm nsglview.mm)
    ardour_uselib(gtkmm2ext OSX)
else ()
    target_sources(gtkmm2ext PRIVATE gtkapplication_x11.c)
endif ()
