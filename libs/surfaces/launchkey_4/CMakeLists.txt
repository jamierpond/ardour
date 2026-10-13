# Port of libs/surfaces/launchkey_4/wscript.

ardour_add_library(ardour_launchkey_4 SHARED)
target_sources(ardour_launchkey_4 PRIVATE
        launchkey_4.cc
        gui.cc
        launchkey_4_interface.cc)
ardour_includes(ardour_launchkey_4 PRIVATE .)
ardour_use(ardour_launchkey_4 ardour ardourcp ardour_midisurface gtkmm2ext pbd evoral canvas temporal ytkmm)
ardour_uselib(ardour_launchkey_4 CAIROMM PANGOMM USB SIGCPP XML OSX GLIBMM GIOMM)
target_compile_definitions(ardour_launchkey_4 PRIVATE
        "PACKAGE=\"ardour_launchpad_x\""
        ARDOURSURFACE_DLL_EXPORTS)
