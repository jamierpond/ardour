# libs/hidapi/wscript
ardour_target(hidapi STATIC
        SOURCES $<IF:$<BOOL:${APPLE}>,mac/hid.c,windows/hid.c>
        INCLUDES hidapi
        EXPORT_INCLUDES hidapi
        USELIB SETUPAPI
        DEFINES _POSIX_C_SOURCE=200809L
        OPTIONS -fvisibility=hidden)
if (APPLE)
    # obj.framework; a static lib has no link step, so it goes to the user.
    target_link_libraries(hidapi INTERFACE "-framework IOKit" "-framework CoreFoundation")
else ()
    target_link_libraries(hidapi INTERFACE setupapi -mwindows)
endif ()
