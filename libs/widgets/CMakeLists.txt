# Port of libs/widgets/wscript.

ardour_add_library(widgets SHARED)

target_sources(widgets PRIVATE
        ardour_ctrl_base.cc
        ardour_button.cc
        ardour_display.cc
        ardour_dropdown.cc
        ardour_fader.cc
        ardour_icon.cc
        ardour_knob.cc
        ardour_spacer.cc
        ardour_spinner.cc
        barcontroller.cc
        binding_proxy.cc
        bracelet.cc
        eventboxext.cc
        choice.cc
        fader_widget.cc
        fastmeter.cc
        frame.cc
        focus_entry.cc
        metabutton.cc
        pane.cc
        paths_dialog.cc
        popup.cc
        prompter.cc
        searchbar.cc
        slider_controller.cc
        stateful_button.cc
        tabbable.cc
        tearoff.cc
        tooltips.cc)

ardour_includes(widgets PUBLIC .)
# obj.includes = ['.'] + bld.env['INCLUDES_GLIB']
target_include_directories(widgets PRIVATE
        "$<TARGET_PROPERTY:PkgConfig::ARDOUR_PKG_GLIB,INTERFACE_INCLUDE_DIRECTORIES>")
ardour_uselib(widgets SIGCPP CAIROMM BOOST XML OSX GLIBMM GIOMM PANGOMM)
ardour_use(widgets pbd gtkmm2ext ytkmm)
target_compile_definitions(widgets PRIVATE
        LIBWIDGETS_DLL_EXPORTS=1
        "PACKAGE=\"libwidgets\"")
