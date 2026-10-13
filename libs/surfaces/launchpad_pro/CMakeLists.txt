# Port of libs/surfaces/launchpad_pro/wscript.

ardour_add_library(ardour_launchpad_pro SHARED)
target_sources(ardour_launchpad_pro PRIVATE
        lppro.cc
        interface.cc
        gui.cc)
ardour_includes(ardour_launchpad_pro PRIVATE . .. ./launchpad_pro)
ardour_use(ardour_launchpad_pro ardour ardourcp ardour_midisurface gtkmm2ext pbd evoral canvas temporal ytkmm)
ardour_uselib(ardour_launchpad_pro CAIROMM PANGOMM USB SIGCPP XML OSX GLIBMM GIOMM)
target_compile_definitions(ardour_launchpad_pro PRIVATE
        "PACKAGE=\"ardour_launchpad_pro\""
        ARDOURSURFACE_DLL_EXPORTS
        "VERSIONSTRING=\"${ARDOUR_VERSION}\"")
