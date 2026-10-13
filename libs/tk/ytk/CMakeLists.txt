# libs/tk/ytk/wscript. 'DATK_DISABLE_SINGLE_INCLUDES' (sic) is the wscript's.
set(_quartz gtkclipboard-quartz.c gtkdnd-quartz.c gtkmountoperation-stub.c gtkplug-stub.c
        gtkquartz.c gtksearchenginequartz.c gtksocket-stub.c)
set(_win32 gtkclipboard.c gtkdnd.c gtkplug-win32.c gtksocket-win32.c gtkwin32embed.c
        gtkwin32embedwidget.c gtkmountoperation-stub.c)
set(_x11 gtkmountoperation-x11.c gtkplug-x11.c gtksocket-x11.c gtkxembed.c)

if (APPLE)
    set(_platform ${_quartz})
    # Same DISABLE_VISIBILITY deviation as libs/tk/ydk.
    set(_options -xobjective-c)
    set(_defines DISABLE_VISIBILITY)
else ()
    set(_platform ${_win32})
    set(_defines INSIDE_GTK_WIN32 DLL_EXPORT PIC)
endif ()

ardour_target(ytk SHARED GLOB
        EXCLUDE ${_quartz} ${_win32} ${_x11}
        SOURCES ${_platform}
        INCLUDES . ytk
        EXPORT_INCLUDES .
        USE ztk ydk-pixbuf ydk
        USELIB GLIB GIO PANGO CAIRO PANGOCAIRO GMODULE OSX
        DEFINES HAVE_CONFIG_H _LARGEFILE64_SOURCE _REENTRANT "G_LOG_DOMAIN=\"Gtk\"" GTK_COMPILATION
                _FILE_OFFSET_BITS=64 GTK_DISABLE_DEPRECATED G_DISABLE_CAST_CHECKS
                G_DISABLE_SINGLE_INCLUDES DATK_DISABLE_SINGLE_INCLUDES GDK_PIXBUF_DISABLE_SINGLE_INCLUDES
                GTK_DISABLE_SINGLE_INCLUDES GDK_PIXBUF_DISABLE_DEPRECATED "GTK_PRINT_BACKENDS=\"file,lpr\""
                GTK_PRINT_BACKEND_ENABLE_UNSUPPORTED "GTK_PRINT_PREVIEW_COMMAND=\"\"" _POSIX_C_SOURCE=200809L
                "GTK_VERSION=\"2.24.23\"" "GTK_BINARY_VERSION=\"2.10.0\"" "GTK_HOST=\"ardour\""
                "PACKAGE=\"ytk${ARDOUR_VERSION_MAJOR}\"" "GETTEXT_PACKAGE=\"ytk${ARDOUR_VERSION_MAJOR}\""
                "GTK_DATA_PREFIX=\"${CMAKE_INSTALL_PREFIX}\"" "GTK_SYSCONFDIR=\"${ARDOUR_SYSCONFDIR}\""
                "GTK_DATA_DIR=\"${ARDOUR_DATADIR}\"" "GTK_LIBDIR=\"${ARDOUR_DLLDIR}\""
                "GTK_LOCALEDIR=\"${ARDOUR_LOCALEDIR}\"" ${_defines}
        OPTIONS -w ${_options})
if (WIN32)
    target_link_options(ytk PRIVATE -Wl,--export-all-symbols)
    target_link_libraries(ytk PRIVATE imm32 ole32 gdi32 comdlg32 winspool comctl32 uuid)
endif ()
