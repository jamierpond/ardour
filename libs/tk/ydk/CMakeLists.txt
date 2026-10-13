# Port of libs/tk/ydk/wscript.

ardour_add_library(ydk SHARED)

target_sources(ydk PRIVATE
        gdk.c
        gdkaliasdef.c
        gdkapplaunchcontext.c
        gdkcairo.c
        gdkcolor.c
        gdkcursor.c
        gdkdisplay.c
        gdkdisplaymanager.c
        gdkdnd.c
        gdkdraw.c
        gdkenumtypes.c
        gdkevents.c
        gdkfont.c
        gdkgc.c
        gdkglobals.c
        gdkimage.c
        gdkkeys.c
        gdkkeyuni.c
        gdkmarshalers.c
        gdkoffscreenwindow.c
        gdkpango.c
        gdkpixbuf-drawable.c
        gdkpixbuf-render.c
        gdkpixmap.c
        gdkpolyreg-generic.c
        gdkrectangle.c
        gdkregion-generic.c
        gdkrgb.c
        gdkscreen.c
        gdkselection.c
        gdkvisual.c
        gdkwindow.c
        gdkwindowimpl.c)

ardour_includes(ydk PUBLIC . ydk)
ardour_use(ydk ztk ydk-pixbuf)
ardour_uselib(ydk GLIB PANGO CAIRO PANGOCAIRO)
target_compile_options(ydk PRIVATE -w)
target_compile_definitions(ydk PRIVATE
        HAVE_CONFIG_H
        _LARGEFILE64_SOURCE
        _REENTRANT
        "G_LOG_DOMAIN=\"Gdk\""
        GDK_COMPILATION
        _FILE_OFFSET_BITS=64
        GDK_PIXBUF_DISABLE_DEPRECATED
        G_DISABLE_CAST_CHECKS
        G_DISABLE_SINGLE_INCLUDES
        ATK_DISABLE_SINGLE_INCLUDES
        GDK_PIXBUF_DISABLE_SINGLE_INCLUDES)

if (APPLE)
    target_sources(ydk PRIVATE
                gdkkeynames.c
                quartz/GdkQuartzView.c
                quartz/GdkQuartzWindow.c
                quartz/gdkapplaunchcontext-quartz.c
                quartz/gdkcolor-quartz.c
                quartz/gdkcursor-quartz.c
                quartz/gdkdisplay-quartz.c
                quartz/gdkdnd-quartz.c
                quartz/gdkdrawable-quartz.c
                quartz/gdkeventloop-quartz.c
                quartz/gdkevents-quartz.c
                quartz/gdkfont-quartz.c
                quartz/gdkgc-quartz.c
                quartz/gdkgeometry-quartz.c
                quartz/gdkglobals-quartz.c
                quartz/gdkim-quartz.c
                quartz/gdkimage-quartz.c
                quartz/gdkinput.c
                quartz/gdkkeys-quartz.c
                quartz/gdkmain-quartz.c
                quartz/gdkpixmap-quartz.c
                quartz/gdkproperty-quartz.c
                quartz/gdkscreen-quartz.c
                quartz/gdkselection-quartz.c
                quartz/gdkspawn-quartz.c
                quartz/gdkvisual-quartz.c
                quartz/gdkwindow-quartz.c)
    # The quartz backend is Objective-C in .c files.
    target_compile_options(ydk PRIVATE -xobjective-c)
    ardour_uselib(ydk OSX)
    ardour_includes(ydk PRIVATE quartz quartz/ydk ydk/quartz PUBLIC quartz)

    # Deviation: glib >= 2.76 defines G_HAVE_GNUC_VISIBILITY on every GNU-ish
    # compiler, and the generated gdkaliasdef.c then emits ELF symbol aliases
    # that Mach-O cannot express ("aliases are not supported on darwin").
    # Ardour's own (older) glib only defined it on ELF platforms, where the
    # alias table is wanted; DISABLE_VISIBILITY restores that behaviour on
    # macOS. (The waf build needs CFLAGS=-DDISABLE_VISIBILITY --keepflags
    # against the same glib.)
    target_compile_definitions(ydk PRIVATE DISABLE_VISIBILITY)
elseif (WIN32)
    target_sources(ydk PRIVATE
                gdkkeynames.c
                win32/bdfcursor.c
                win32/gdkapplaunchcontext-win32.c
                win32/gdkcolor-win32.c
                win32/gdkcursor-win32.c
                win32/gdkdisplay-win32.c
                win32/gdkdnd-win32.c
                win32/gdkdrawable-win32.c
                win32/gdkevents-win32.c
                win32/gdkfont-win32.c
                win32/gdkgc-win32.c
                win32/gdkgeometry-win32.c
                win32/gdkglobals-win32.c
                win32/gdkim-win32.c
                win32/gdkimage-win32.c
                win32/gdkinput-win32.c
                win32/gdkinput.c
                win32/gdkkeys-win32.c
                win32/gdkmain-win32.c
                win32/gdkpixmap-win32.c
                win32/gdkproperty-win32.c
                win32/gdkscreen-win32.c
                win32/gdkselection-win32.c
                win32/gdkspawn-win32.c
                win32/gdkvisual-win32.c
                win32/gdkwin32id.c
                win32/gdkwindow-win32.c)
    ardour_uselib(ydk GIO-WINDOWS)
    target_compile_definitions(ydk PRIVATE INSIDE_GDK_WIN32 DLL_EXPORT PIC)
    ardour_includes(ydk PRIVATE win32 win32/ydk PUBLIC win32)
    target_link_libraries(ydk PRIVATE imm32 ole32 gdi32 comdlg32 winspool comctl32 uuid)
else ()
    target_sources(ydk PRIVATE
                x11/gdkapplaunchcontext-x11.c
                x11/gdkasync.c
                x11/gdkcolor-x11.c
                x11/gdkcursor-x11.c
                x11/gdkdisplay-x11.c
                x11/gdkdnd-x11.c
                x11/gdkdrawable-x11.c
                x11/gdkevents-x11.c
                x11/gdkfont-x11.c
                x11/gdkgc-x11.c
                x11/gdkgeometry-x11.c
                x11/gdkglobals-x11.c
                x11/gdkim-x11.c
                x11/gdkimage-x11.c
                x11/gdkinput-none.c
                x11/gdkinput.c
                x11/gdkkeys-x11.c
                x11/gdkmain-x11.c
                x11/gdkpixmap-x11.c
                x11/gdkproperty-x11.c
                x11/gdkscreen-x11.c
                x11/gdkselection-x11.c
                x11/gdkspawn-x11.c
                x11/gdkvisual-x11.c
                x11/gdkwindow-x11.c
                x11/gdkxftdefaults.c
                x11/gdkxid.c
                x11/xsettings-client.c
                x11/xsettings-common.c)
    ardour_uselib(ydk GIO-UNIX X11 XEXT XINERAMA RANDR DL)
    ardour_includes(ydk PRIVATE x11 x11/ydk ydk/x11 PUBLIC x11)
endif ()
