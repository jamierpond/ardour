# Port of libs/surfaces/launchpad_x/wscript.

set(_launchpad_x_sources
        lpx.cc
        gui.cc)

ardour_add_library(ardour_launchpad_mini SHARED)
target_sources(ardour_launchpad_mini PRIVATE
        ${_launchpad_x_sources}
        launchpad_mini_interface.cc)
ardour_includes(ardour_launchpad_mini PRIVATE .)
ardour_use(ardour_launchpad_mini ardour ardourcp ardour_midisurface gtkmm2ext pbd evoral canvas temporal ytkmm)
ardour_uselib(ardour_launchpad_mini CAIROMM PANGOMM USB SIGCPP XML OSX GLIBMM GIOMM)
target_compile_definitions(ardour_launchpad_mini PRIVATE
        "PACKAGE=\"ardour_launchpad_mini\""
        ARDOURSURFACE_DLL_EXPORTS
        LAUNCHPAD_MINI)

ardour_add_library(ardour_launchpad_x SHARED)
target_sources(ardour_launchpad_x PRIVATE
        ${_launchpad_x_sources}
        launchpad_x_interface.cc)
ardour_includes(ardour_launchpad_x PRIVATE .)
ardour_use(ardour_launchpad_x ardour ardourcp ardour_midisurface gtkmm2ext pbd evoral canvas temporal ytkmm)
ardour_uselib(ardour_launchpad_x CAIROMM PANGOMM USB SIGCPP XML OSX GLIBMM GIOMM)
target_compile_definitions(ardour_launchpad_x PRIVATE
        "PACKAGE=\"ardour_launchpad_x\""
        ARDOURSURFACE_DLL_EXPORTS)
