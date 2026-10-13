# Port of libs/surfaces/faderport8/wscript.

set(_faderport8_sources
        faderport8.cc
        fp8_controls.cc
        fp8_strip.cc
        callbacks.cc
        actions.cc
        gui.cc)

ardour_add_library(ardour_faderport8 SHARED)
target_sources(ardour_faderport8 PRIVATE
        ${_faderport8_sources}
        faderport8_interface.cc)
ardour_includes(ardour_faderport8 PRIVATE .)
ardour_use(ardour_faderport8 ardour ardourcp gtkmm2ext pbd ytkmm)
ardour_uselib(ardour_faderport8 XML OSX CAIROMM PANGOMM GLIBMM GIOMM)
target_compile_definitions(ardour_faderport8 PRIVATE
        "PACKAGE=\"ardour_faderport8\""
        ARDOURSURFACE_DLL_EXPORTS)

ardour_add_library(ardour_faderport16 SHARED)
target_sources(ardour_faderport16 PRIVATE
        ${_faderport8_sources}
        faderport16_interface.cc)
ardour_includes(ardour_faderport16 PRIVATE .)
ardour_use(ardour_faderport16 ardour ardourcp gtkmm2ext pbd ytkmm)
ardour_uselib(ardour_faderport16 XML OSX CAIROMM PANGOMM GLIBMM GIOMM)
target_compile_definitions(ardour_faderport16 PRIVATE
        "PACKAGE=\"ardour_faderport8\""
        ARDOURSURFACE_DLL_EXPORTS
        FADERPORT16)

ardour_add_library(ardour_faderport2 SHARED)
target_sources(ardour_faderport2 PRIVATE
        ${_faderport8_sources}
        faderport2_interface.cc)
ardour_includes(ardour_faderport2 PRIVATE .)
ardour_use(ardour_faderport2 ardour ardourcp gtkmm2ext pbd ytkmm)
ardour_uselib(ardour_faderport2 XML OSX CAIROMM PANGOMM GLIBMM GIOMM)
target_compile_definitions(ardour_faderport2 PRIVATE
        "PACKAGE=\"ardour_faderport8\""
        ARDOURSURFACE_DLL_EXPORTS
        FADERPORT2)
