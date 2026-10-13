# gtk2_ardour/wscript: the GUI executable and the files it loads at run time.

set(_uselib UUID FLAC FONTCONFIG GTHREAD OGG PANGOMM CURL DL CANVAS FFTW3F LO TAGLIB XML LILV
        RUBBERBAND AUBIO LRDF ARCHIVE VAMPSDK VAMPHOSTSDK GLIBMM GIOMM PANGOFT2 LIBPNG LIBJPEG USB
        AUDIOUNITS OSX INTL)
set(_exclude audio_region_operations_box.cc beatbox_gui.cc canvas_test.cc evtest.cc gprofhelper.c
        luadoc.cc stripable_treemodel.cc toolbar_test.cc
        bundle_env_cocoa.cc bundle_env_linux.cc bundle_env_mingw.cc bundle_env_msvc.cc bundle_env_msvc2.cc
        linux_vst_gui_support.cc lxvst_plugin_ui.cc windows_vst_plugin_ui.cc
        vst3_hwnd_plugin_ui.cc vst3_x11_plugin_ui.cc)

if (APPLE)
    set(_platform bundle_env_cocoa.cc cocoacarbon.mm mac_vst_plugin_ui.mm au_pluginui.mm vst3_nsview_plugin_ui.mm)
    set(_defines MACVST_SUPPORT)
else ()
    # create_resource_file(): the application icon.
    file(CONFIGURE OUTPUT windows_icon.rc CONTENT "IDI_ICON1 ICON DISCARDABLE \"${CMAKE_CURRENT_SOURCE_DIR}/icons/Ardour.ico\"\n")
    enable_language(RC)
    set(_platform bundle_env_mingw.cc windows_vst_plugin_ui.cc vst3_hwnd_plugin_ui.cc
            "${CMAKE_CURRENT_BINARY_DIR}/windows_icon.rc")
    set(_defines WINDOWS_VST_SUPPORT)
endif ()

ardour_target(ardour-gui EXECUTABLE GLOB
        OUTPUT_NAME ardour-${ARDOUR_VERSION}
        EXCLUDE ${_exclude}
        SOURCES ${_platform} "${CMAKE_CURRENT_BINARY_DIR}/gtk2ardour-version.h"
        INCLUDES . ../libs ../libs/vst3
        USE pbd ardour ardourcp temporal midipp gtkmm2ext canvas waveview widgets ptformat ytk ytkmm aaf
        USELIB ${_uselib}
        DEFINES "PACKAGE=\"gtk2_ardour${ARDOUR_VERSION_MAJOR}\"" "DATA_DIR=\"${ARDOUR_DATADIR}\""
                "CONFIG_DIR=\"${ARDOUR_SYSCONFDIR}\"" "LOCALEDIR=\"${ARDOUR_LOCALEDIR}\""
                PHONE_HOME ${_defines})
if (WIN32)
    target_link_options(ardour-gui PRIVATE -mwindows)
endif ()

# --- generated files ----------------------------------------------------------
set(_scripts "${PROJECT_SOURCE_DIR}/scripts")

add_custom_command(OUTPUT gtk2ardour-version.h
        COMMAND "${ARDOUR_NODE}" "${_scripts}/gtk2ardour-version.mjs"
                ${ARDOUR_VERSION} ${ARDOUR_VERSION_MAJOR} ${ARDOUR_VERSION_MINOR}
                "${CMAKE_CURRENT_BINARY_DIR}/gtk2ardour-version.h"
        DEPENDS "${_scripts}/gtk2ardour-version.mjs")

# ardour.keys from the .bindings files.
file(GLOB _bindings CONFIGURE_DEPENDS *.bindings)
add_custom_command(OUTPUT ardour.keys
        COMMAND "${ARDOUR_NODE}" "${_scripts}/fmt-bindings.mjs" "${CMAKE_CURRENT_SOURCE_DIR}/ardour.keys.in"
                > ardour.keys
        DEPENDS ardour.keys.in ${_bindings} "${_scripts}/fmt-bindings.mjs")

# ardour.menus: the C preprocessor over ardour.menus.in, fed on stdin like
# waf's command-output (macOS cpp formats differently given a file argument).
if (APPLE)
    set(_cpp cpp -E -P -D__APPLE__ -)
else ()
    set(_cpp ${CMAKE_C_COMPILER} -E -P -x c -)
endif ()
add_custom_command(OUTPUT ardour.menus
        COMMAND ${_cpp} "$<IF:$<CONFIG:Debug>,-DVAPOR,-DNDEBUG>"
                < "${CMAKE_CURRENT_SOURCE_DIR}/ardour.menus.in" > ardour.menus
        DEPENDS ardour.menus.in)

add_custom_target(ardour-gui-resources ALL DEPENDS ardour.keys ardour.menus)
add_dependencies(ardour-gui ardour-gui-resources)

# Font substitutions for the rc files: "<basefont> [<style>] <points>" with an
# empty basefont, so the values keep their leading space (" 10", " bold 10").
if (APPLE)
    set(_sizes VERYSMALL 7 SMALLER 9 SMALL 10 NORMAL 11 BIG 13 BIGGER 17 LARGE 18 LARGER 28 HUGER 36 MASSIVE 60)
else ()
    set(_sizes VERYSMALL 8 SMALLER 6 SMALL 7 NORMAL 8 BIG 11 BIGGER 13.5 LARGE 14.5 LARGER 19 HUGER 27 MASSIVE 48)
endif ()
while (_sizes)
    list(POP_FRONT _sizes size points)
    set(FONT_${size} " ${points}")
    set(FONT_BOLD_${size} " bold ${points}")
    set(FONT_ITALIC_${size} " italic ${points}")
    set(FONT_SIZE_${size} "${points}")
endwhile ()
set(MONOSPACE ArdourMono)
set(CLOCKFONT ArdourMono)
set(FONTFAMILY "")
configure_file(clearlooks.rc.in clearlooks.rc @ONLY)
configure_file(default_ui_config.in default_ui_config @ONLY)
set(FONTFAMILY ArdourSans)
configure_file(clearlooks.rc.in clearlooks.ardoursans.rc @ONLY)

# ardev: run from the build tree. Deviation: ardev_common.sh.in hard-codes
# waf's $TOP/build; this copy points at the CMake build directory instead.
if (APPLE)
    file(RELATIVE_PATH _bin "${PROJECT_SOURCE_DIR}" "${PROJECT_BINARY_DIR}")
    set(LIBS "${_bin}/libs")
    set(VERSION "${ARDOUR_VERSION}")
    set(EXECUTABLE "${_bin}/gtk2_ardour/ardour-${ARDOUR_VERSION}")
    set(LD_LIBRARY_PATH LD_LIBRARY_PATH)
    file(READ ardev_common.sh.in _ardev)
    string(REPLACE "$TOP/build" "$TOP/${_bin}" _ardev "${_ardev}")
    file(CONFIGURE OUTPUT ardev_common.sh CONTENT "${_ardev}" @ONLY)
    file(RELATIVE_PATH _top "${CMAKE_CURRENT_BINARY_DIR}" "${PROJECT_SOURCE_DIR}")
    file(CONFIGURE OUTPUT ardev @ONLY CONTENT [=[#!/bin/sh
TOP=`dirname "$0"`/@_top@
. "`dirname "$0"`/ardev_common.sh"
exec $TOP/$EXECUTABLE "$@"
]=])
    file(CHMOD "${CMAKE_CURRENT_BINARY_DIR}/ardev" PERMISSIONS
            OWNER_READ OWNER_WRITE OWNER_EXECUTE GROUP_READ GROUP_EXECUTE WORLD_READ WORLD_EXECUTE)
endif ()
