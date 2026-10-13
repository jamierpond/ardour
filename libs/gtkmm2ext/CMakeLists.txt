# libs/gtkmm2ext/wscript
if (APPLE)
    set(_platform gtkapplication_quartz.mm nsglview.mm)
else ()
    set(_platform gtkapplication_x11.c)
endif ()
ardour_target(gtkmm2ext SHARED GLOB
        EXCLUDE gtkapplication_win32.c gtkapplication_x11.c gtkutils.cc sync-menu.c
        SOURCES ${_platform}
        INCLUDES .
        EXPORT_INCLUDES .
        USE pbd ydk ydkmm ytkmm
        USELIB XML CAIROMM PANGOMM GLIBMM GIOMM OSX
        DEFINES LIBGTKMM2EXT_DLL_EXPORTS ABSTRACT_UI_EXPORTS "PACKAGE=\"gtkmm2ext3\""
                "LOCALEDIR=\"${ARDOUR_LOCALEDIR}\"")
