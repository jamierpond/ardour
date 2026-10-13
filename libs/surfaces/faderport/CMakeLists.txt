# Port of libs/surfaces/faderport/wscript.

ardour_add_library(ardour_faderport SHARED)
target_sources(ardour_faderport PRIVATE
        faderport.cc
        gui.cc
        faderport_interface.cc
        operations.cc)
ardour_includes(ardour_faderport PRIVATE . ./faderport)
ardour_use(ardour_faderport ardour ardourcp ardour_midisurface gtkmm2ext pbd ytkmm)
ardour_uselib(ardour_faderport XML OSX PANGOMM GLIBMM GIOMM)
target_compile_definitions(ardour_faderport PRIVATE
        "PACKAGE=\"ardour_faderport\""
        ARDOURSURFACE_DLL_EXPORTS)
