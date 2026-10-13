cmake_minimum_required(VERSION 3.31)

# CMake build for Ardour on macOS 12+ and Windows 10+ (MSYS2 MinGW), alongside
# waf. Each CMakeLists.txt ports the wscript next to it; docs/cmake.md lists
# where the two differ.

set(CMAKE_OSX_DEPLOYMENT_TARGET 12.0 CACHE STRING "Minimum macOS version")

project(Ardour LANGUAGES C CXX)

if (APPLE)
    enable_language(OBJC)
    enable_language(OBJCXX)
elseif (NOT MINGW)
    message(FATAL_ERROR "The CMake build supports macOS and Windows (MSYS2 MinGW) only; use waf elsewhere.")
endif ()

set(CMAKE_EXPORT_COMPILE_COMMANDS ON)
list(APPEND CMAKE_MODULE_PATH "${CMAKE_CURRENT_SOURCE_DIR}/CMake")

# Code generators (version, codename, key bindings) are Node scripts.
find_program(ARDOUR_NODE node REQUIRED)

include(Ardour)
include(ArdourDeps)

# Dependency order (waf's 'children' order is not one; it resolves 'use' late).
if (APPLE)
    add_subdirectory(libs/appleutility)
endif ()
add_subdirectory(libs/zita-resampler)
add_subdirectory(libs/zita-convolver)
add_subdirectory(libs/staffpad)
add_subdirectory(libs/fluidsynth)
add_subdirectory(libs/hidapi)
add_subdirectory(libs/libltc)
add_subdirectory(libs/qm-dsp)
add_subdirectory(libs/vamp-plugins)
add_subdirectory(libs/vamp-pyin)
add_subdirectory(libs/aaf)
add_subdirectory(libs/tk)
add_subdirectory(libs/clearlooks-newer)
add_subdirectory(libs/pbd)
add_subdirectory(libs/ptformat)
add_subdirectory(libs/lua)
add_subdirectory(libs/temporal)
add_subdirectory(libs/evoral)
add_subdirectory(libs/midi++2)
add_subdirectory(libs/audiographer)
add_subdirectory(libs/fst)
add_subdirectory(libs/ardour)
add_subdirectory(libs/ctrl-interface)
add_subdirectory(libs/gtkmm2ext)
add_subdirectory(libs/canvas)
add_subdirectory(libs/widgets)
add_subdirectory(libs/waveview)
add_subdirectory(libs/panners)
add_subdirectory(libs/backends)
add_subdirectory(libs/surfaces)
add_subdirectory(libs/plugins)
if (APPLE)
    add_subdirectory(libs/auscan)
    add_subdirectory(libs/vfork)
endif ()
add_subdirectory(gtk2_ardour)
add_subdirectory(headless)
add_subdirectory(luasession)
add_subdirectory(session_utils)
