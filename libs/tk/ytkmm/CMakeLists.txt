# libs/tk/ytkmm/wscript
ardour_target(ytkmm SHARED GLOB
        INCLUDES .
        EXPORT_INCLUDES .
        USE ztk ytk ztkmm ydkmm
        USELIB GLIBMM GIOMM SIGCPP CAIROMM PANGOMM
        DEFINES _LARGEFILE64_SOURCE _REENTRANT "G_LOG_DOMAIN=\"gtkmm\"" GTKMM_BUILD=1 _FILE_OFFSET_BITS=64
        OPTIONS -w)
