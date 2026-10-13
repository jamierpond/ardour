# Port of libs/tk/ydk-pixbuf/wscript.

ardour_add_library(ydk-pixbuf SHARED)

target_sources(ydk-pixbuf PRIVATE
        gdk-pixbuf-animation.c
        gdk-pixbuf-data.c
        gdk-pixbuf-enum-types.c
        gdk-pixbuf-io.c
        gdk-pixbuf-loader.c
        gdk-pixbuf-scale.c
        gdk-pixbuf-scaled-anim.c
        gdk-pixbuf-simple-anim.c
        gdk-pixbuf-util.c
        gdk-pixbuf.c
        gdk-pixdata.c
        io-pixdata.c
        io-jpeg.c
        io-png.c
        io-xbm.c
        io-xpm.c
        pixops/pixops.c)

ardour_includes(ydk-pixbuf PUBLIC . PRIVATE ydk-pixbuf)
ardour_uselib(ydk-pixbuf GLIB GIO GOBJECT LIBPNG LIBJPEG)
# 'DGDK_PIXBUF_COMPILATION' (sic) is what the wscript defines.
target_compile_definitions(ydk-pixbuf PRIVATE
        HAVE_CONFIG_H
        _LARGEFILE64_SOURCE
        _REENTRANT
        "G_LOG_DOMAIN=\"GdkPixbuf\""
        DGDK_PIXBUF_COMPILATION
        _FILE_OFFSET_BITS=64
        GDK_PIXBUF_ENABLE_BACKEND
        G_DISABLE_SINGLE_INCLUDES
        _POSIX_C_SOURCE=200809L
        INCLUDE_png
        INCLUDE_xbm
        INCLUDE_xpm
        INCLUDE_jpeg
        "PACKAGE=\"libydk-pixbuf\""
        "GDK_PIXBUF_LOCALEDIR=\"\"")

if (APPLE)
    ardour_uselib(ydk-pixbuf OSX)
    ardour_link_intl(ydk-pixbuf)
endif ()
