# Port of libs/surfaces/contourdesign/wscript.

ardour_add_library(ardour_contourdesign SHARED)
target_sources(ardour_contourdesign PRIVATE
        contourdesign.cc
        contourdesign_gui.cc
        jump_distance_widget.cc
        button_config_widget.cc
        interface.cc)
ardour_includes(ardour_contourdesign PRIVATE . ../libs ../../widgets)
ardour_use(ardour_contourdesign ardour ardourcp gtkmm2ext pbd widgets ytkmm)
ardour_uselib(ardour_contourdesign USB XML OSX PANGOMM GLIBMM GIOMM)
target_compile_definitions(ardour_contourdesign PRIVATE
        "PACKAGE=\"ardour_contourdesign\""
        ARDOURSURFACE_DLL_EXPORTS)
