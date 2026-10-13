# The run-time files gtk2_ardour/wscript generates next to the executable:
# wrapper scripts, font-substituted rc files, the menu definitions and the key
# bindings. Included from gtk2_ardour/CMakeLists.txt, so CMAKE_CURRENT_* refer
# to that directory.

set(_gtk_src "${CMAKE_CURRENT_SOURCE_DIR}")
set(_gtk_bin "${CMAKE_CURRENT_BINARY_DIR}")

# --- font substitution dictionary -------------------------------------------
# Built exactly as the wscript does: "<basefont> <style> <points>" joined with
# spaces, so with an empty basefont the values start with a space (" 10",
# " bold 10") -- the rc files depend on that spacing being preserved.
if (APPLE)
    set(_font_sizes
            VERYSMALL 7 SMALLER 9 SMALL 10 NORMAL 11 BIG 13
            BIGGER 17 LARGE 18 LARGER 28 HUGER 36 MASSIVE 60)
else ()
    set(_font_sizes
            VERYSMALL 8 SMALLER 6 SMALL 7 NORMAL 8 BIG 11
            BIGGER 13.5 LARGE 14.5 LARGER 19 HUGER 27 MASSIVE 48)
endif ()
set(_basefont "")

foreach (style "" BOLD ITALIC)
    set(_sizes ${_font_sizes})
    while (_sizes)
        list(POP_FRONT _sizes sizename points)
        if (style)
            string(TOLOWER "${style}" _lstyle)
            set(FONT_${style}_${sizename} "${_basefont} ${_lstyle} ${points}")
        else ()
            set(FONT_${sizename} "${_basefont} ${points}")
        endif ()
        set(FONT_SIZE_${sizename} "${points}")
    endwhile ()
endforeach ()
set(MONOSPACE ArdourMono)
set(CLOCKFONT ArdourMono)

# RC files and the default UI configuration (waf 'subst').
set(FONTFAMILY "")
configure_file("${_gtk_src}/clearlooks.rc.in" "${_gtk_bin}/clearlooks.rc" @ONLY)
set(FONTFAMILY ArdourSans)
configure_file("${_gtk_src}/clearlooks.rc.in" "${_gtk_bin}/clearlooks.ardoursans.rc" @ONLY)
configure_file("${_gtk_src}/default_ui_config.in" "${_gtk_bin}/default_ui_config" @ONLY)

# --- menus ------------------------------------------------------------------
# "always build all versions of the menu definitions": the C preprocessor over
# ardour.menus.in (read from stdin, as waf's command-output feature does --
# macOS cpp's output differs when given the file as an argument).
find_program(ARDOUR_CPP cpp REQUIRED)
set(_menus_argv -E -P)
if (APPLE)
    list(APPEND _menus_argv -D__APPLE__)
endif ()
if (ARDOUR_PROGRAM_NAME MATCHES "^[Mm][Ii][Xx][Bb][Uu][Ss]")
    list(APPEND _menus_argv -DMIXBUS)
endif ()
if (ARDOUR_PTFORMAT)
    list(APPEND _menus_argv -DPTFORMAT)
endif ()
# waf decides DEBUG / NDEBUG at configure time; here it follows the build type.
list(APPEND _menus_argv
        "$<$<OR:$<CONFIG:Debug>,$<BOOL:${MIXBUS}>>:-DVAPOR>"
        "$<$<NOT:$<CONFIG:Debug>>:-DNDEBUG>")
if (APPLE)
    list(APPEND _menus_argv -)
endif ()

add_custom_command(
        OUTPUT "${_gtk_bin}/ardour.menus"
        COMMAND "${ARDOUR_CPP}" ${_menus_argv}
                < "${_gtk_src}/ardour.menus.in" > "${_gtk_bin}/ardour.menus"
        DEPENDS "${_gtk_src}/ardour.menus.in"
        COMMAND_EXPAND_LISTS
        VERBATIM)

# --- key bindings -----------------------------------------------------------
# "THE CANONICAL LIST OF FILES PROCESSED FOR BINDINGS IS INSIDE
# ../tools/fmt-bindings": the extra .bindings files are dependencies only.
if (APPLE)
    set(_platform darwin)
elseif (WIN32)
    set(_platform win32)
else ()
    set(_platform linux)
endif ()
set(_bindings_inputs
        ardour.keys.in mixer.bindings processor_box.bindings step_editing.bindings
        monitor.bindings trigger.bindings regionfx_box.bindings automation.bindings)
list(TRANSFORM _bindings_inputs PREPEND "${_gtk_src}/")

add_custom_command(
        OUTPUT "${_gtk_bin}/ardour.keys"
        COMMAND Python3::Interpreter "${PROJECT_SOURCE_DIR}/tools/fmt-bindings.py"
                "--platform=${_platform}" "--winkey=Mod4><Super" --accelmap 1
                "${_gtk_src}/ardour.keys.in" > "${_gtk_bin}/ardour.keys"
        DEPENDS ${_bindings_inputs} "${PROJECT_SOURCE_DIR}/tools/fmt-bindings.py"
        VERBATIM)

add_custom_target(ardour-gui-resources ALL
        DEPENDS "${_gtk_bin}/ardour.menus" "${_gtk_bin}/ardour.keys")
add_dependencies(ardour-gui ardour-gui-resources)

# --- run-from-build-tree wrapper (ardev) ------------------------------------
# waf substitutes ardev_common.sh.in into build/gtk2_ardour/ardev_common_waf.sh,
# which gtk2_ardour/ardev sources from the hard-coded build/ directory. The
# template also hard-codes "$TOP/build" in ARDOUR_DATA_PATH/ARDOUR_CONFIG_PATH.
# Deviation: the CMake copy points those at this build tree instead, and gets
# its own ardev launcher next to it (gtk2_ardour/ardev itself only knows waf's
# build/ directory).
file(RELATIVE_PATH _bin_rel "${PROJECT_SOURCE_DIR}" "${PROJECT_BINARY_DIR}")
if (_bin_rel MATCHES "^\\.\\.")
    message(WARNING "ardev expects the build directory inside the source tree; "
            "${PROJECT_BINARY_DIR} is not, so the generated ardev will not work.")
endif ()

set(LIBS "${_bin_rel}/libs")
set(VERSION "${ARDOUR_VERSION}")
set(EXECUTABLE "${_bin_rel}/gtk2_ardour/${ARDOUR_EXECUTABLE_NAME}")
set(LD_LIBRARY_PATH LD_LIBRARY_PATH)
file(RELATIVE_PATH _top_rel "${_gtk_bin}" "${PROJECT_SOURCE_DIR}")
file(READ "${_gtk_src}/ardev_common.sh.in" _ardev)
string(REPLACE "$TOP/build" "$TOP/${_bin_rel}" _ardev "${_ardev}")
file(CONFIGURE OUTPUT "${_gtk_bin}/ardev_common.sh" CONTENT "${_ardev}" @ONLY)

file(CONFIGURE OUTPUT "${_gtk_bin}/ardev" CONTENT [=[#!/bin/sh
# Generated by CMake: run Ardour from the build tree (cf. gtk2_ardour/ardev).
TOP=`dirname "$0"`/@_top_rel@
. "`dirname "$0"`/ardev_common.sh"
export UBUNTU_MENUPROXY=""
exec $TOP/$EXECUTABLE "$@"
]=] @ONLY)
file(CHMOD "${_gtk_bin}/ardev" "${_gtk_bin}/ardev_common.sh"
        PERMISSIONS OWNER_READ OWNER_WRITE OWNER_EXECUTE GROUP_READ GROUP_EXECUTE WORLD_READ WORLD_EXECUTE)

# The installed launcher, ardour<MAJOR> (waf: ardour.sh.in).
set(INSTALL_PREFIX "${CMAKE_INSTALL_PREFIX}")
set(LIBDIR "${ARDOUR_DLLDIR}")
set(DATADIR "${ARDOUR_DATADIR}")
set(CONFDIR "${ARDOUR_CONFDIR}")
configure_file("${_gtk_src}/ardour.sh.in" "${_gtk_bin}/ardour${ARDOUR_VERSION_MAJOR}" @ONLY
        FILE_PERMISSIONS OWNER_READ OWNER_WRITE OWNER_EXECUTE GROUP_READ GROUP_EXECUTE WORLD_READ WORLD_EXECUTE)
