# Port of libs/surfaces/console1/wscript.

ardour_add_library(ardour_console1 SHARED)
target_sources(ardour_console1 PRIVATE
        console1_interface.cc
        console1.cc
        c1_operations.cc
        c1_plugin_operations.cc
        c1_gui.cc)
ardour_includes(ardour_console1 PRIVATE . ./console1)
ardour_use(ardour_console1 ardour ardourcp ardour_midisurface gtkmm2ext pbd evoral temporal ytkmm)
ardour_uselib(ardour_console1 SIGCPP XML OSX GLIBMM GIOMM PANGOMM)
target_compile_definitions(ardour_console1 PRIVATE
        "PACKAGE=\"ardour_console1\""
        ARDOURSURFACE_DLL_EXPORTS)
