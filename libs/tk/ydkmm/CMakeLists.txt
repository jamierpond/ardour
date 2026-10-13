# Port of libs/tk/ydkmm/wscript.

ardour_add_library(ydkmm SHARED)

target_sources(ydkmm PRIVATE
        bitmap.cc
        color.cc
        colormap.cc
        cursor.cc
        device.cc
        display.cc
        displaymanager.cc
        dragcontext.cc
        drawable.cc
        event.cc
        gc.cc
        general.cc
        image.cc
        pixbuf.cc
        pixbufanimation.cc
        pixbufanimationiter.cc
        pixbufformat.cc
        pixbufloader.cc
        pixmap.cc
        rectangle.cc
        region.cc
        rgb.cc
        rgbcmap.cc
        screen.cc
        types.cc
        visual.cc
        window.cc
        wrap_init.cc)

ardour_includes(ydkmm PUBLIC .)
ardour_use(ydkmm ztkmm ytk)
ardour_uselib(ydkmm GLIBMM GIOMM SIGCPP CAIROMM PANGOMM)
target_compile_definitions(ydkmm PRIVATE
        _LARGEFILE64_SOURCE
        _REENTRANT
        "G_LOG_DOMAIN=\"gdkmm\""
        GDKMM_BUILD=1
        _FILE_OFFSET_BITS=64)
