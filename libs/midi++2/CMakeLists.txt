# libs/midi++2/wscript
ardour_target(midipp SHARED GLOB
        EXCLUDE miditrace.cc mmctest.cc
        INCLUDES . ../surfaces/control_protocol ../ardour
        EXPORT_INCLUDES .
        USE pbd evoral temporal
        USELIB GLIBMM SIGCPP XML OSX
        DEFINES LIBMIDIPP_DLL_EXPORTS=1)
