# Port of libs/surfaces/wiimote/wscript.

ardour_add_library(ardour_wiimote SHARED)
target_sources(ardour_wiimote PRIVATE
        wiimote.cc
        interface.cc)
ardour_includes(ardour_wiimote PRIVATE . ../libs)
ardour_use(ardour_wiimote ardour ardourcp gtkmm2ext ytkmm)
ardour_uselib(ardour_wiimote CWIID XML GLIBMM GIOMM PANGOMM)
target_compile_definitions(ardour_wiimote PRIVATE
        "PACKAGE=\"ardour_wiimote\""
        ARDOURSURFACE_DLL_EXPORTS)
