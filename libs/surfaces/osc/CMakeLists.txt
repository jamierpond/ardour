# Port of libs/surfaces/osc/wscript.

ardour_add_library(ardour_osc SHARED)
target_sources(ardour_osc PRIVATE
        osc.cc
        osc_route_observer.cc
        osc_select_observer.cc
        osc_global_observer.cc
        osc_cue_observer.cc
        interface.cc
        osc_gui.cc)
ardour_includes(ardour_osc PRIVATE . ./osc)
ardour_use(ardour_osc ardour ardourcp gtkmm2ext pbd ytkmm)
ardour_uselib(ardour_osc LO XML OSX GLIBMM GIOMM PANGOMM)
target_compile_definitions(ardour_osc PRIVATE
        "PACKAGE=\"ardour_osc\""
        ARDOURSURFACE_DLL_EXPORTS)
