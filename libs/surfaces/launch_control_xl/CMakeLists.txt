# Port of libs/surfaces/launch_control_xl/wscript.

ardour_add_library(ardour_launch_control_xl SHARED)
target_sources(ardour_launch_control_xl PRIVATE
        launch_control_xl.cc
        controllers.cc
        interface.cc
        midi_byte_array.cc
        leds.cc
        gui.cc)
ardour_includes(ardour_launch_control_xl PRIVATE . ./launch_control_xl)
ardour_use(ardour_launch_control_xl ardour ardourcp pbd evoral canvas temporal ytkmm)
ardour_uselib(ardour_launch_control_xl SIGCPP XML OSX PANGOMM GLIBMM GIOMM)
target_compile_definitions(ardour_launch_control_xl PRIVATE
        "PACKAGE=\"ardour_launch_control_xl\""
        ARDOURSURFACE_DLL_EXPORTS
        "VERSIONSTRING=\"${ARDOUR_VERSION}\"")
