# libs/tk/ydk/wscript
if (APPLE)
    file(GLOB _platform CONFIGURE_DEPENDS RELATIVE "${CMAKE_CURRENT_SOURCE_DIR}" quartz/*.c)
    list(REMOVE_ITEM _platform quartz/gdktestutils-quartz.c)
    # The quartz backend is Objective-C in .c files. DISABLE_VISIBILITY is a
    # deviation: glib >= 2.76 defines G_HAVE_GNUC_VISIBILITY everywhere, and
    # gdkaliasdef.c then emits ELF aliases Mach-O cannot express. Ardour's own
    # older glib left it undefined on macOS, which this restores.
    set(_options -xobjective-c)
    set(_defines DISABLE_VISIBILITY)
    set(_backend quartz)
else ()
    file(GLOB _platform CONFIGURE_DEPENDS RELATIVE "${CMAKE_CURRENT_SOURCE_DIR}" win32/*.c)
    list(REMOVE_ITEM _platform win32/gdktestutils-win32.c)
    set(_options -mms-bitfields -Wl,--export-all-symbols)
    set(_defines INSIDE_GDK_WIN32 DLL_EXPORT PIC)
    set(_backend win32)
endif ()

ardour_target(ydk SHARED GLOB
        EXCLUDE gdkmedialib.c
        SOURCES ${_platform}
        INCLUDES . ydk ${_backend} ${_backend}/ydk ydk/${_backend}
        EXPORT_INCLUDES . ydk ${_backend}
        USE ztk ydk-pixbuf
        USELIB GLIB PANGO CAIRO PANGOCAIRO OSX GIO-WINDOWS
        DEFINES HAVE_CONFIG_H _LARGEFILE64_SOURCE _REENTRANT "G_LOG_DOMAIN=\"Gdk\"" GDK_COMPILATION
                _FILE_OFFSET_BITS=64 GDK_PIXBUF_DISABLE_DEPRECATED G_DISABLE_CAST_CHECKS
                G_DISABLE_SINGLE_INCLUDES ATK_DISABLE_SINGLE_INCLUDES GDK_PIXBUF_DISABLE_SINGLE_INCLUDES
                ${_defines}
        OPTIONS -w ${_options})
if (WIN32)
    target_link_options(ydk PRIVATE -Wl,--export-all-symbols)
    target_link_libraries(ydk PRIVATE imm32 ole32 gdi32 comdlg32 winspool comctl32 uuid)
endif ()
