# libs/waveview/wscript
ardour_target(waveview SHARED GLOB
        INCLUDES .
        EXPORT_INCLUDES .
        USE pbd canvas ardour gtkmm2ext temporal ytkmm
        USELIB SIGCPP PANGOMM CAIROMM XML GLIBMM GIOMM
        DEFINES LIBWAVEVIEW_DLL_EXPORTS=1 "PACKAGE=\"libwaveview\"")
