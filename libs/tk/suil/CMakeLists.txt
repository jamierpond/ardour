# Port of libs/tk/suil/wscript.

if (NOT TARGET Ardour::LV2_1_16_0)
    return()
endif ()

set(_suil_module_dir "${ARDOUR_DLLDIR}")
set(_suil_defines
        "SUIL_DIR_SEP=\"/\""
        "SUIL_MODULE_DIR=\"${_suil_module_dir}\""
        SUIL_SHARED
        SUIL_INTERNAL)

if (APPLE)
    list(APPEND _suil_defines SUIL_WITH_COCOA_IN_GTK2 "SUIL_MODULE_PREFIX=\"lib\"" "SUIL_MODULE_EXT=\".dylib\"")
elseif (WIN32)
    list(APPEND _suil_defines SUIL_WITH_WIN_IN_GTK2 "SUIL_MODULE_PREFIX=\"\"" "SUIL_MODULE_EXT=\".dll\"")
else ()
    list(APPEND _suil_defines SUIL_WITH_X11_IN_GTK2 "SUIL_MODULE_PREFIX=\"lib\"" "SUIL_MODULE_EXT=\".so\"")
endif ()

# cflags = pic + c99 (+ -fvisibility=hidden everywhere but Windows). These are
# C flags: the wrapper modules below are C++/Objective-C++, so waf never
# passes them to those compiles.
set(_suil_cflags "$<$<COMPILE_LANGUAGE:C>:-std=c99>")
if (NOT WIN32)
    list(APPEND _suil_cflags "$<$<COMPILE_LANGUAGE:C>:-fvisibility=hidden>")
endif ()

ardour_add_library(suil SHARED)
target_sources(suil PRIVATE host.c instance.c)
ardour_includes(suil PUBLIC .)
ardour_uselib(suil LV2)
target_compile_definitions(suil PRIVATE ${_suil_defines})
target_compile_options(suil PRIVATE ${_suil_cflags})

if (APPLE)
    ardour_uselib(suil DL)

    ardour_add_library(suil_cocoa_in_gtk2 SHARED)
    target_sources(suil_cocoa_in_gtk2 PRIVATE cocoa_in_gtk2.mm)
    ardour_includes(suil_cocoa_in_gtk2 PRIVATE .)
    target_compile_definitions(suil_cocoa_in_gtk2 PRIVATE ${_suil_defines})
    ardour_use(suil_cocoa_in_gtk2 ydk ytk)
    ardour_uselib(suil_cocoa_in_gtk2 LV2 DL GLIB PANGOCAIRO)
    target_link_libraries(suil_cocoa_in_gtk2 PRIVATE "-framework Cocoa")
elseif (WIN32)
    ardour_add_library(suil_win_in_gtk2 SHARED)
    target_sources(suil_win_in_gtk2 PRIVATE win_in_gtk2.cpp)
    ardour_includes(suil_win_in_gtk2 PRIVATE .)
    target_compile_definitions(suil_win_in_gtk2 PRIVATE ${_suil_defines})
    ardour_use(suil_win_in_gtk2 ytk)
    ardour_uselib(suil_win_in_gtk2 LV2 GLIB PANGOCAIRO)
else ()
    ardour_uselib(suil DL)

    ardour_add_library(suil_x11_in_gtk2 SHARED)
    target_sources(suil_x11_in_gtk2 PRIVATE x11_in_gtk2.c)
    ardour_includes(suil_x11_in_gtk2 PRIVATE .)
    target_compile_definitions(suil_x11_in_gtk2 PRIVATE ${_suil_defines})
    target_compile_options(suil_x11_in_gtk2 PRIVATE ${_suil_cflags})
    ardour_use(suil_x11_in_gtk2 ytk)
    ardour_uselib(suil_x11_in_gtk2 X11 LV2 DL GLIB PANGOCAIRO)
    target_link_options(suil_x11_in_gtk2 PRIVATE "LINKER:-z,nodelete")
endif ()
