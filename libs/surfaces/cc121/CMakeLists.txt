# Port of libs/surfaces/cc121/wscript.

ardour_add_library(ardour_cc121 SHARED)
target_sources(ardour_cc121 PRIVATE
        cc121.cc
        gui.cc
        cc121_interface.cc
        operations.cc)
ardour_includes(ardour_cc121 PRIVATE . ./cc121)
ardour_use(ardour_cc121 ardour ardourcp gtkmm2ext pbd ytkmm)
ardour_uselib(ardour_cc121 XML OSX GLIBMM GIOMM PANGOMM)
target_compile_definitions(ardour_cc121 PRIVATE
        "PACKAGE=\"ardour_cc121\""
        ARDOURSURFACE_DLL_EXPORTS)
