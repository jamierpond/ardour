# libs/temporal/wscript
ardour_target(temporal SHARED GLOB
        EXCLUDE test.cc test2.cc
        INCLUDES .
        EXPORT_INCLUDES .
        USE pbd
        USELIB GLIBMM XML OSX
        DEFINES LIBTEMPORAL_DLL_EXPORTS=1 "PACKAGE=\"libtemporal\"")
