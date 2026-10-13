# libs/canvas/wscript
ardour_target(canvas SHARED GLOB
        INCLUDES .
        EXPORT_INCLUDES .
        USE pbd gtkmm2ext ytkmm
        USELIB SIGCPP CAIROMM PANGOMM XML OSX GIOMM PANGOCAIRO
        DEFINES LIBCANVAS_DLL_EXPORTS=1 "PACKAGE=\"libcanvas\"")
