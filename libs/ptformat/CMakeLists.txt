# libs/ptformat/wscript
ardour_target(ptformat SHARED GLOB
        INCLUDES .
        EXPORT_INCLUDES .
        USE pbd
        USELIB GLIBMM
        DEFINES LIBPTFORMAT_DLL_EXPORTS=1 "PACKAGE=\"libptformat\"")
