# libs/aaf/wscript
ardour_target(aaf SHARED GLOB
        INCLUDES .
        EXPORT_INCLUDES .
        DEFINES LIBAAF_DLL_EXPORTS=1 "PACKAGE=\"libaaf\"" _POSIX_C_SOURCE=200809L _XOPEN_SOURCE=500)
