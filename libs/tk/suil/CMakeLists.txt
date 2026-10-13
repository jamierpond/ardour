# libs/tk/suil/wscript. cflags (-std=c99, -fvisibility=hidden on macOS) are C
# only; the C++/Objective-C++ wrapper module never sees them.
if (APPLE)
    set(_defines SUIL_WITH_COCOA_IN_GTK2 "SUIL_MODULE_PREFIX=\"lib\"" "SUIL_MODULE_EXT=\".dylib\"")
    set(_cflags -std=c99 -fvisibility=hidden)
    set(_wrapper cocoa_in_gtk2 cocoa_in_gtk2.mm)
else ()
    set(_defines SUIL_WITH_WIN_IN_GTK2 "SUIL_MODULE_PREFIX=\"\"" "SUIL_MODULE_EXT=\".dll\"")
    set(_cflags -std=c99)
    set(_wrapper win_in_gtk2 win_in_gtk2.cpp)
endif ()
list(APPEND _defines "SUIL_DIR_SEP=\"/\"" "SUIL_MODULE_DIR=\"${ARDOUR_DLLDIR}\"" SUIL_SHARED SUIL_INTERNAL)

ardour_target(suil SHARED
        SOURCES host.c instance.c
        INCLUDES .
        EXPORT_INCLUDES .
        USELIB LV2 DL
        DEFINES ${_defines}
        OPTIONS ${_cflags})

list(POP_FRONT _wrapper _name)
ardour_target(suil_${_name} SHARED
        SOURCES ${_wrapper}
        INCLUDES .
        USE ydk ytk
        USELIB LV2 DL GLIB PANGOCAIRO
        DEFINES ${_defines})
if (APPLE)
    target_link_libraries(suil_${_name} PRIVATE "-framework Cocoa")
endif ()
