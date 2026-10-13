# libs/tk/ydk-pixbuf/wscript. 'DGDK_PIXBUF_COMPILATION' (sic) is the wscript's.
ardour_target(ydk-pixbuf SHARED GLOB
        EXCLUDE gdk-pixbuf-marshal.c
        SOURCES pixops/pixops.c
        INCLUDES . ydk-pixbuf
        EXPORT_INCLUDES .
        USELIB GLIB GIO GOBJECT LIBPNG LIBJPEG OSX INTL
        DEFINES HAVE_CONFIG_H _LARGEFILE64_SOURCE _REENTRANT "G_LOG_DOMAIN=\"GdkPixbuf\""
                DGDK_PIXBUF_COMPILATION _FILE_OFFSET_BITS=64 GDK_PIXBUF_ENABLE_BACKEND
                G_DISABLE_SINGLE_INCLUDES _POSIX_C_SOURCE=200809L INCLUDE_png INCLUDE_xbm
                INCLUDE_xpm INCLUDE_jpeg "PACKAGE=\"libydk-pixbuf\"" "GDK_PIXBUF_LOCALEDIR=\"\"")
