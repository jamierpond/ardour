# Port of libs/hidapi/wscript.

if (NOT HAVE_HIDAPI)
    return()
endif ()

ardour_add_library(hidapi STATIC)

ardour_includes(hidapi PUBLIC hidapi)
target_compile_definitions(hidapi PRIVATE _POSIX_C_SOURCE=200809L)
# autowaf.ensure_visible_symbols(obj, False)
target_compile_options(hidapi PRIVATE -fvisibility=hidden)

if (APPLE)
    target_sources(hidapi PRIVATE mac/hid.c)
    # obj.framework: a static library has no link step of its own, so the
    # frameworks go to whatever links it.
    target_link_libraries(hidapi INTERFACE "-framework IOKit" "-framework CoreFoundation")
elseif (WIN32)
    target_sources(hidapi PRIVATE windows/hid.c)
    target_link_libraries(hidapi INTERFACE setupapi)
else ()
    target_sources(hidapi PRIVATE linux/hid.c)
    ardour_uselib(hidapi UDEV)
endif ()
