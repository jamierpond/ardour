cmake_minimum_required(VERSION 3.31)

# CMake build for Ardour, alongside waf. The wscripts stay the reference: every
# CMakeLists.txt here is a port of the wscript in the same directory (same
# sources, defines, uselibs), and anything that had to differ says so in a
# comment where it happens. docs/cmake.md has the build instructions.

# Before project(): CMake's Darwin platform module creates this as an empty
# cache entry during project(), after which a plain cache set is a no-op. The
# root wscript builds for macOS 11.0 (-mmacosx-version-min=11.0) on every
# current host; a command-line -DCMAKE_OSX_DEPLOYMENT_TARGET still wins.
if (NOT CMAKE_OSX_DEPLOYMENT_TARGET)
    set(CMAKE_OSX_DEPLOYMENT_TARGET "11.0" CACHE STRING "Minimum macOS version")
endif ()

project(Ardour LANGUAGES C CXX)

if (APPLE)
    # ydk, ytk, suil and the AU/VST UIs are Objective-C(++).
    enable_language(OBJC)
    enable_language(OBJCXX)
endif ()

set(CMAKE_EXPORT_COMPILE_COMMANDS ON)

list(APPEND CMAKE_MODULE_PATH "${CMAKE_CURRENT_SOURCE_DIR}/CMake")

# --- options (the root wscript's options(), the ones that apply here) -------

set(ARDOUR_PROGRAM_NAME "Ardour" CACHE STRING "The user-visible name of the program being built (waf --program-name)")
set(ARDOUR_BACKENDS "" CACHE STRING "Backends to build, ;-separated (waf --with-backends). Empty: auto-detect")
option(ARDOUR_INTERNAL_SHARED_LIBS "Build internal libs as shared libraries (waf: default; --internal-static-libs turns it off)" ON)
option(ARDOUR_NLS "Native language support (waf: on unless --no-nls)" ON)
option(ARDOUR_PHONE_HOME "Contact ardour.org at startup for announcements (waf: on unless --no-phone-home)" ON)
option(ARDOUR_VST3 "VST3 plugin support (waf: on unless --no-vst3)" ON)
option(ARDOUR_LXVST "Linux VST support (waf: on unless --no-lxvst; Linux only)" ON)
option(ARDOUR_PTFORMAT "Import PTS/PTF/PTX sessions (waf --ptformat)" OFF)
option(ARDOUR_THREADED_WAVEVIEWS "Threaded waveview rendering (waf: on unless --no-threaded-waveviews)" ON)
option(ARDOUR_EXPORTS_HIDDEN "Hide non-exported symbols (waf --exports-hidden)" OFF)
option(ARDOUR_FUTEX_SEMAPHORE "Use futex for semaphores, Linux only (waf: on unless --no-futex-semaphore)" ON)
option(ARDOUR_RT_ALLOC_DEBUG "Debug memory allocation in the real-time thread (waf --rt-alloc-debug)" OFF)
option(ARDOUR_DENORMAL_EXCEPTION "Raise an FP exception on denormals (waf --denormal-exception)" OFF)
option(ARDOUR_MASCHINE "NI-Maschine surface support (waf --maschine)" OFF)
option(ARDOUR_BUILD_TESTS "Build the unit tests (waf --test)" OFF)

if (NOT ARDOUR_INTERNAL_SHARED_LIBS)
    message(FATAL_ERROR "ARDOUR_INTERNAL_SHARED_LIBS=OFF (waf --internal-static-libs) is not ported yet")
endif ()

# --- version, flags, dependencies -------------------------------------------

include(ArdourVersion)
ardour_detect_version()
message(STATUS "Ardour version ${ARDOUR_VERSION} (${ARDOUR_REVISION}, ${ARDOUR_REVISION_DATE})")

include(ArdourDepStack)
include(ArdourCompilerFlags)
include(ArdourConfig)
include(ArdourTargets)
include(FindArdourDeps)

# The install layout the wscripts compute in build(): everything Ardour loads
# at run time lives under <prefix>/{lib,share,etc}/ardour<MAJOR>.
include(GNUInstallDirs)
set(ARDOUR_LWRCASE_DIRNAME "ardour${ARDOUR_VERSION_MAJOR}")
set(ARDOUR_DLLDIR "${CMAKE_INSTALL_FULL_LIBDIR}/${ARDOUR_LWRCASE_DIRNAME}")
set(ARDOUR_DATADIR "${CMAKE_INSTALL_FULL_DATADIR}/${ARDOUR_LWRCASE_DIRNAME}")
set(ARDOUR_CONFDIR "${CMAKE_INSTALL_FULL_SYSCONFDIR}/${ARDOUR_LWRCASE_DIRNAME}")
set(ARDOUR_LOCALEDIR "${ARDOUR_DATADIR}/locale")

# --- libraries, bottom-up ---------------------------------------------------
# waf walks its 'children' list in a fixed order and resolves 'use' lazily, so
# that order is not a dependency order (surfaces come before libardour). CMake
# needs a target to exist before another one names it, so the directories are
# added in dependency order instead. The configure checks above still run in
# the wscripts' order, which is the one the config headers record.

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
add_subdirectory(libs/ardour)
add_subdirectory(libs/ctrl-interface)
add_subdirectory(libs/gtkmm2ext)
add_subdirectory(libs/canvas)
add_subdirectory(libs/widgets)
add_subdirectory(libs/waveview)
add_subdirectory(libs/panners)
add_subdirectory(libs/backends)
add_subdirectory(libs/surfaces)
add_subdirectory(gtk2_ardour)
