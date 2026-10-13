# libs/tk/ztkmm/wscript
ardour_target(ztkmm SHARED GLOB
        INCLUDES .
        EXPORT_INCLUDES .
        USE ztk
        USELIB GLIBMM SIGCPP
        DEFINES _LARGEFILE64_SOURCE _REENTRANT "G_LOG_DOMAIN=\"atkmm\"" ATKMM_BUILD=1 _FILE_OFFSET_BITS=64
        OPTIONS -w)
