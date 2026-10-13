# Port of libs/surfaces/maschine2/wscript.

ardour_add_library(ardour_maschine2 SHARED)
target_sources(ardour_maschine2 PRIVATE
        maschine2.cc
        callbacks.cc
        canvas.cc
        interface.cc
        layout.cc
        m2_dev_mk2.cc
        m2_map_mk2.cc
        m2_dev_mikro.cc
        m2_map_mikro.cc
        ui_knob.cc
        ui_menu.cc)
ardour_includes(ardour_maschine2 PRIVATE . ./maschine2)
ardour_use(ardour_maschine2 ardour ardourcp pbd canvas hidapi gtkmm2ext ytkmm)
ardour_uselib(ardour_maschine2 CAIROMM PANGOMM XML OSX GLIBMM GIOMM)
target_compile_definitions(ardour_maschine2 PRIVATE
        "PACKAGE=\"ardour_maschine2\""
        ARDOURSURFACE_DLL_EXPORTS
        "VERSIONSTRING=\"${ARDOUR_VERSION}\"")
