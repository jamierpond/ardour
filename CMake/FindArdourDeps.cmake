# Every third-party dependency and configure-time check, ported from the
# configure() functions of the root wscript and its children.
#
# Each waf "uselib" (the uselib_store of a check_pkg/check_cc: GLIBMM, XML,
# OSX, ...) becomes an INTERFACE target Ardour::<USELIB>, so a wscript's
#     obj.uselib = 'GLIBMM SIGCPP XML OSX'
# ports to
#     ardour_uselib(<target> GLIBMM SIGCPP XML OSX)
# A successful check also does what waf's does: conf.define('HAVE_<USELIB>').
#
# The checks run in the wscripts' configure order (root first, then the
# children in the order the root 'children' list recurses into them), because
# that order is what the generated config headers snapshot. The header writes
# sit at the same points as the wscripts' conf.write_config_header() calls.

find_package(PkgConfig REQUIRED)

include(CheckIncludeFile)
include(CheckIncludeFileCXX)
include(CheckSourceCompiles)

# autowaf.check_pkg(conf, <pkg>, uselib_store=<USELIB>, atleast_version=<v>,
#                   mandatory=<bool>)
#   ardour_check_pkg(<USELIB> <pkg> [ATLEAST <v>] [OPTIONAL])
# Like autowaf, a uselib already found is not looked up again.
function(ardour_check_pkg uselib pkg)
    cmake_parse_arguments(ARG "OPTIONAL" "ATLEAST" "" ${ARGN})

    if (TARGET Ardour::${uselib})
        return()
    endif ()

    set(spec "${pkg}")
    if (ARG_ATLEAST)
        set(spec "${pkg}>=${ARG_ATLEAST}")
    endif ()

    string(MAKE_C_IDENTIFIER "ARDOUR_PKG_${uselib}" prefix)
    pkg_check_modules(${prefix} QUIET IMPORTED_TARGET GLOBAL "${spec}")

    if (NOT ${prefix}_FOUND)
        if (ARG_OPTIONAL)
            message(STATUS "Checking for '${spec}' (${uselib}): not found")
            return()
        endif ()
        message(FATAL_ERROR
                "Required package '${spec}' (waf uselib ${uselib}) was not found by "
                "pkg-config. Install it, or point ARDOUR_DEPSTACK_ROOT / "
                "CMAKE_PREFIX_PATH at a prefix that has it.")
    endif ()

    message(STATUS "Checking for '${spec}' (${uselib}): ${${prefix}_VERSION}")

    add_library(ardour-uselib-${uselib} INTERFACE)
    target_link_libraries(ardour-uselib-${uselib} INTERFACE PkgConfig::${prefix})
    add_library(Ardour::${uselib} ALIAS ardour-uselib-${uselib})

    string(MAKE_C_IDENTIFIER "HAVE_${uselib}" have)
    ardour_define(${have} 1)
endfunction()

# conf.check(header_name=<h>, define_name=<NAME>, mandatory=False)
function(ardour_check_header header define)
    cmake_parse_arguments(ARG "CXX" "" "" ${ARGN})
    if (ARG_CXX)
        check_include_file_cxx("${header}" ${define})
    else ()
        check_include_file("${header}" ${define})
    endif ()
    if (${define})
        ardour_define(${define} 1)
    else ()
        ardour_undefine(${define})
    endif ()
endfunction()

# A uselib that is not a pkg-config package: an INTERFACE target the caller
# fills in.
function(ardour_add_uselib uselib)
    add_library(ardour-uselib-${uselib} INTERFACE)
    add_library(Ardour::${uselib} ALIAS ardour-uselib-${uselib})
endfunction()

# obj.uselib = '...': link the named uselibs. As in waf, a name nothing ever
# defined (UUID, SMF, LIBPBD, GTKMM, ... -- stale names the wscripts still
# list) is ignored.
function(ardour_uselib target)
    cmake_parse_arguments(ARG "PUBLIC" "" "" ${ARGN})
    set(scope PRIVATE)
    if (ARG_PUBLIC)
        set(scope PUBLIC)
    endif ()
    foreach (uselib IN LISTS ARG_UNPARSED_ARGUMENTS)
        if (TARGET Ardour::${uselib})
            target_link_libraries(${target} ${scope} Ardour::${uselib})
        endif ()
    endforeach ()
endfunction()

# ---------------------------------------------------------------------------
# Root wscript configure()
# ---------------------------------------------------------------------------

if (APPLE)
    ardour_define(NEED_INTL 1)
    ardour_define(HAVE_COREAUDIO 1)
    ardour_define(AUDIOUNIT_SUPPORT 1)
    ardour_define(MACVST_SUPPORT 1)
    ardour_define(TOP_MENUBAR 1)
endif ()

if (ARDOUR_INTERNAL_SHARED_LIBS)
    ardour_define(INTERNAL_SHARED_LIBS 1)
endif ()

# DL: check_cc(lib='dl', uselib_store='DL') -- no define.
ardour_add_uselib(DL)
if (NOT CMAKE_SYSTEM_NAME MATCHES "OpenBSD|NetBSD")
    target_link_libraries(ardour-uselib-DL INTERFACE dl)
endif ()

# "Checking for boost library >= 1.68". waf passes --boost-include to every
# C++ compile; Boost's include dir goes onto every C++ compile here too.
find_package(Boost 1.68 CONFIG REQUIRED COMPONENTS headers)
get_target_property(_ardour_boost_inc Boost::headers INTERFACE_INCLUDE_DIRECTORIES)
target_include_directories(ardour-build-flags SYSTEM INTERFACE
        "$<$<COMPILE_LANGUAGE:CXX,OBJCXX>:${_ardour_boost_inc}>")

if (CMAKE_SYSTEM_NAME STREQUAL "Linux")
    ardour_check_pkg(ALSA alsa)
    ardour_check_pkg(PULSEAUDIO libpulse OPTIONAL)
endif ()

ardour_check_pkg(GLIB glib-2.0 ATLEAST 2.28)
ardour_check_pkg(GTHREAD gthread-2.0 ATLEAST 2.2)
ardour_check_pkg(GLIBMM glibmm-2.4 ATLEAST 2.32.0)
ardour_check_pkg(SNDFILE sndfile ATLEAST 1.0.18)
ardour_check_pkg(GIOMM giomm-2.4 ATLEAST 2.2)
ardour_check_pkg(CURL libcurl ATLEAST 7.55.0)
ardour_check_pkg(ARCHIVE libarchive ATLEAST 3.0.0)
ardour_check_pkg(LO liblo ATLEAST 0.26)
ardour_check_pkg(TAGLIB taglib ATLEAST 1.9)
ardour_check_pkg(VAMPSDK vamp-sdk ATLEAST 2.1)
ardour_check_pkg(VAMPHOSTSDK vamp-hostsdk ATLEAST 2.1)
ardour_check_pkg(RUBBERBAND rubberband)
ardour_check_pkg(USB libusb-1.0 ATLEAST 1.0.16 OPTIONAL)

# "we cannot rely on pkg-config" for the rubberband version.
set(CMAKE_REQUIRED_LIBRARIES PkgConfig::ARDOUR_PKG_RUBBERBAND)
check_source_compiles(CXX [[
#include <rubberband/RubberBandStretcher.h>
#if (RUBBERBAND_API_MAJOR_VERSION >= 2 && RUBBERBAND_API_MINOR_VERSION >= 7) || RUBBERBAND_API_MAJOR_VERSION >= 3
int main () { return 0; }
#else
#error
#endif
]] ARDOUR_HAVE_RUBBERBAND_3_0_0)
if (ARDOUR_HAVE_RUBBERBAND_3_0_0)
    ardour_define(HAVE_RUBBERBAND_3_0_0 1)
endif ()

# RF64=>RIFF and int128 are plain -D flags in the wscript, not conf.define()s,
# so they are on every compile line but not in the config headers.
set(CMAKE_REQUIRED_LIBRARIES PkgConfig::ARDOUR_PKG_SNDFILE)
check_source_compiles(C [[
#include <sndfile.h>
int main () { int x = SFC_RF64_AUTO_DOWNGRADE; return 0; }
]] ARDOUR_HAVE_RF64_RIFF)
unset(CMAKE_REQUIRED_LIBRARIES)
if (ARDOUR_HAVE_RF64_RIFF)
    target_compile_definitions(ardour-build-flags INTERFACE HAVE_RF64_RIFF)
endif ()

check_source_compiles(C [[
int main () { __int128 x = 0; return 0; }
]] ARDOUR_HAVE_INT128)
if (ARDOUR_HAVE_INT128)
    target_compile_definitions(ardour-build-flags INTERFACE COMPILER_INT128_SUPPORT)
endif ()

# "always use localized gtk2"
ardour_define(YTK 1)
ardour_define(HAVE_SUIL 1)

if (ARDOUR_EXPORTS_HIDDEN)
    ardour_define(EXPORT_VISIBILITY_HIDDEN 1)
    if (ARDOUR_INTERNAL_SHARED_LIBS)
        target_compile_options(ardour-build-flags INTERFACE -fvisibility=hidden)
    endif ()
else ()
    ardour_define(EXPORT_VISIBILITY_HIDDEN 0)
endif ()

if (ARDOUR_PHONE_HOME)
    ardour_define(PHONE_HOME 1)
endif ()
if (ARDOUR_NLS)
    ardour_define(ENABLE_NLS 1)
else ()
    ardour_define(ENABLE_NLS 0)
endif ()
if (WIN32)
    ardour_define(WINDOWS_VST_SUPPORT 1)
endif ()
if (ARDOUR_LXVST AND NOT APPLE AND NOT WIN32)
    ardour_define(LXVST_SUPPORT 1)
endif ()
if (ARDOUR_VST3)
    ardour_define(VST3_SUPPORT 1)
endif ()
if (ARDOUR_RT_ALLOC_DEBUG)
    ardour_define(DEBUG_RT_ALLOC 1)
    target_compile_definitions(ardour-build-flags INTERFACE DEBUG_RT_ALLOC)
    target_link_libraries(ardour-build-flags INTERFACE dl)
endif ()
if (ARDOUR_DENORMAL_EXCEPTION)
    ardour_define(DEBUG_DENORMAL_EXCEPTION 1)
    target_compile_definitions(ardour-build-flags INTERFACE DEBUG_DENORMAL_EXCEPTION)
endif ()
if (ARDOUR_BUILD_TESTS)
    ardour_check_pkg(CPPUNIT cppunit ATLEAST 1.12.0)
endif ()
if (ARDOUR_PTFORMAT)
    ardour_define(PTFORMAT 1)
endif ()
if (NOT ARDOUR_THREADED_WAVEVIEWS)
    ardour_define(NO_THREADED_WAVEVIEWS 1)
endif ()
if (CMAKE_SYSTEM_NAME STREQUAL "Linux" AND ARDOUR_FUTEX_SEMAPHORE)
    check_source_compiles(C [[
#include <sys/syscall.h>
#include <linux/futex.h>
int main () { int x = SYS_futex | FUTEX_WAKE_PRIVATE; return 0; }
]] ARDOUR_HAVE_SYS_FUTEX)
    if (ARDOUR_HAVE_SYS_FUTEX)
        ardour_define(USE_FUTEX_SEMAPHORE 1)
    endif ()
endif ()

# Backends: --with-backends, or auto (dummy, jack if found, coreaudio on macOS,
# alsa/pulseaudio on Linux).
if (NOT ARDOUR_BACKENDS)
    set(_ardour_backends dummy)
    ardour_check_pkg(JACK jack ATLEAST 1.9.10 OPTIONAL)
    if (TARGET Ardour::JACK)
        list(APPEND _ardour_backends jack)
    endif ()
    if (TARGET Ardour::PULSEAUDIO)
        list(APPEND _ardour_backends pulseaudio)
    endif ()
    if (CMAKE_SYSTEM_NAME STREQUAL "Linux")
        list(APPEND _ardour_backends alsa)
    endif ()
    if (APPLE)
        list(APPEND _ardour_backends coreaudio)
    endif ()
    if (WIN32)
        list(APPEND _ardour_backends portaudio)
    endif ()
    set(ARDOUR_BACKENDS "${_ardour_backends}" CACHE STRING
            "Backends to build (waf --with-backends): jack;alsa;portaudio;coreaudio;pulseaudio;dummy" FORCE)
endif ()
if (NOT "dummy" IN_LIST ARDOUR_BACKENDS)
    list(APPEND ARDOUR_BACKENDS dummy)
endif ()
if ("coreaudio" IN_LIST ARDOUR_BACKENDS AND NOT APPLE)
    message(FATAL_ERROR "Coreaudio backend is only available for OSX")
endif ()

# set_compiler_flags()
if (APPLE)
    # "Prevents visibility issues in standard headers"
    ardour_define(_DARWIN_C_SOURCE 1)
endif ()
if (ARDOUR_ARM_NEON_SUPPORT)
    ardour_define(ARM_NEON_SUPPORT 1)
endif ()
ardour_define(CONFIG_ARCH "${CMAKE_SYSTEM_PROCESSOR}" QUOTED)
if (ARDOUR_PROGRAM_NAME MATCHES "^[Mm][Ii][Xx][Bb][Uu][Ss]")
    ardour_define(MIXBUS 1)
endif ()

# sub_config_and_use(conf, 'libs/appleutility')
if (APPLE)
    ardour_define(HAVE_LIBS_APPLEUTILITY 1)
endif ()

# --- OSX / AUDIOUNITS: the macOS link flag bundles ------------------------
if (APPLE)
    ardour_add_uselib(OSX)
    # CXXFLAGS_OSX only -- the C compiles never see it.
    target_compile_options(ardour-uselib-OSX INTERFACE
            "$<$<COMPILE_LANGUAGE:CXX,OBJCXX>:-F/Library/Frameworks>")
    # LINKFLAGS_OSX. -undefined dynamic_lookup and -flat_namespace matter at
    # run time: the surfaces, panners and backends resolve symbols against
    # whatever libardour is already loaded.
    target_link_libraries(ardour-uselib-OSX INTERFACE
            "-framework AppKit"
            "-framework CoreAudio"
            "-framework CoreAudioKit"
            "-framework CoreFoundation"
            "-framework CoreServices")
    target_link_options(ardour-uselib-OSX INTERFACE
            "SHELL:-undefined dynamic_lookup"
            -flat_namespace)
    if (ARDOUR_FPU_OPTIMIZATION)
        target_link_libraries(ardour-uselib-OSX INTERFACE "-framework Accelerate")
    endif ()

    ardour_add_uselib(AUDIOUNITS)
    target_compile_definitions(ardour-uselib-AUDIOUNITS INTERFACE
            "$<$<COMPILE_LANGUAGE:CXX,OBJCXX>:AUDIOUNIT_SUPPORT>")
    target_link_libraries(ardour-uselib-AUDIOUNITS INTERFACE
            "-framework AudioToolbox"
            "-framework AudioUnit"
            "-framework Cocoa")
endif ()

# libintl: NEED_INTL targets add '-lintl' to their link flags.
if (APPLE)
    find_package(Intl REQUIRED)
endif ()

# ---------------------------------------------------------------------------
# Children, in the root wscript's 'children' order
# ---------------------------------------------------------------------------

# libs/zita-convolver
ardour_check_pkg(FFTW3F fftw3f)

# libs/hidapi
if (APPLE OR WIN32)
    ardour_define(HAVE_HIDAPI 1)
elseif (CMAKE_SYSTEM_NAME STREQUAL "Linux")
    ardour_check_pkg(UDEV libudev OPTIONAL)
    if (TARGET Ardour::UDEV)
        ardour_define(HAVE_HIDAPI 1)
    endif ()
endif ()

# libs/vamp-plugins
ardour_check_pkg(AUBIO aubio ATLEAST 0.3.2)
ardour_check_pkg(AUBIO4 aubio ATLEAST 0.4.0 OPTIONAL)
ardour_write_config_header(libs/vamp-plugins/libvampplugins-config.h)

# libs/tk/ztk
ardour_check_pkg(GOBJECT gobject-2.0)

# libs/tk/ydk-pixbuf
ardour_check_pkg(GIO gio-2.0 ATLEAST 2.2)
ardour_check_pkg(LIBPNG libpng)
ardour_check_header(unistd.h HAVE_UNISTD_H)
find_package(JPEG REQUIRED)
ardour_add_uselib(LIBJPEG)
target_link_libraries(ardour-uselib-LIBJPEG INTERFACE JPEG::JPEG)
ardour_define(HAVE_LIBJPEG 1)

# libs/tk/ydk
ardour_check_pkg(PANGO pango ATLEAST 1.20)
ardour_check_pkg(CAIRO cairo ATLEAST 1.12)
ardour_check_pkg(PANGOCAIRO pangocairo)

# libs/tk/ytk
ardour_check_pkg(GMODULE gmodule-2.0)
if (NOT APPLE AND NOT WIN32)
    ardour_check_pkg(X11 x11)
    ardour_check_pkg(XEXT xext)
endif ()

# libs/tk/ztkmm, ydkmm, ytkmm
ardour_check_pkg(SIGCPP sigc++-2.0 ATLEAST 2.0)
ardour_check_pkg(CAIROMM cairomm-1.0 ATLEAST 1.8.4)
ardour_check_pkg(PANGOMM pangomm-1.4 ATLEAST 1.4)

# libs/tk/suil
ardour_check_pkg(LV2_1_16_0 lv2 ATLEAST 1.16.0 OPTIONAL)

# libs/pbd
ardour_check_pkg(XML libxml-2.0)
ardour_check_header(execinfo.h HAVE_EXECINFO_H)
check_source_compiles(C [[
#define _XOPEN_SOURCE 600
 #include <stdlib.h>
 int main(void) { return posix_memalign (0, 64, 1); }
]] ARDOUR_HAVE_POSIX_MEMALIGN)
if (ARDOUR_HAVE_POSIX_MEMALIGN)
    ardour_define(HAVE_POSIX_MEMALIGN 1)
else ()
    ardour_undefine(HAVE_POSIX_MEMALIGN)
endif ()
check_source_compiles(C [[
#include <mntent.h>
 int main(void) { return (int)getmntent(0); }
]] ARDOUR_HAVE_GETMNTENT)
if (ARDOUR_HAVE_GETMNTENT)
    ardour_define(HAVE_GETMNTENT 1)
else ()
    ardour_undefine(HAVE_GETMNTENT)
endif ()
check_source_compiles(C [[
#include <time.h>
 int main(void) { return NULL == localtime_r(NULL, NULL); }
]] ARDOUR_HAVE_LOCALTIME_R)
if (ARDOUR_HAVE_LOCALTIME_R)
    ardour_define(HAVE_LOCALTIME_R 1)
else ()
    ardour_undefine(HAVE_LOCALTIME_R)
endif ()
ardour_write_config_header(libs/pbd/libpbd-config.h)

# libs/midi++2
ardour_check_pkg(CPPUNIT cppunit ATLEAST 1.12.0 OPTIONAL)

# libs/ctrl-interface: sub_config_and_use() for both children.
ardour_define(HAVE_CONTROL_PROTOCOL 1)
ardour_define(HAVE_MIDI_SURFACE 1)

# libs/surfaces
if (APPLE OR WIN32)
    # maschine2 is opt-in (waf --maschine).
    if (ARDOUR_MASCHINE)
        ardour_define(BUILD_MASCHINE 1)
    endif ()
endif ()
ardour_check_header(cwiid.h HAVE_CWIID_H)
if (HAVE_CWIID_H)
    ardour_check_header(bluetooth/bluetooth.h HAVE_BLUETOOTH_H)
    if (HAVE_BLUETOOTH_H)
        ardour_check_pkg(CWIID cwiid ATLEAST 0.6.00 OPTIONAL)
        if (TARGET Ardour::CWIID)
            ardour_define(BUILD_WIIMOTE 1)
        endif ()
    endif ()
endif ()
ardour_check_pkg(WEBSOCKETS libwebsockets ATLEAST 2.0.0 OPTIONAL)

# libs/ardour
ardour_check_pkg(LRDF lrdf ATLEAST 0.4.0 OPTIONAL)
ardour_check_pkg(SAMPLERATE samplerate ATLEAST 0.1.0)
ardour_check_pkg(LV2 lv2 ATLEAST 1.2.0)
ardour_check_pkg(LV2_1_10_0 lv2 ATLEAST 1.10.0 OPTIONAL)
ardour_check_pkg(LV2_1_17_2 lv2 ATLEAST 1.17.2 OPTIONAL)
ardour_check_pkg(LV2_1_18_6 lv2 ATLEAST 1.18.6 OPTIONAL)
ardour_check_pkg(SERD serd-0 ATLEAST 0.14.0)
ardour_check_pkg(SORD sord-0 ATLEAST 0.8.0)
ardour_check_pkg(SRATOM sratom-0 ATLEAST 0.2.0)
ardour_check_pkg(LILV lilv-0 ATLEAST 0.24.2)
ardour_define(LV2_SUPPORT 1)
ardour_define(USE_TLSF 1)
if (TARGET Ardour::LV2_1_10_0)
    # "non-standard LV2 extention"
    ardour_define(LV2_EXTENDED 1)
endif ()
ardour_check_pkg(OGG ogg ATLEAST 1.1.2)
ardour_check_pkg(FLAC flac ATLEAST 1.2.1)
ardour_check_pkg(FFTW35F fftw3f ATLEAST 3.3.5 OPTIONAL)
# libs/ardour/wscript: CURRENT_SESSION_FILE_VERSION
ardour_define(CURRENT_SESSION_FILE_VERSION 7003)
ardour_check_header(sys/vfs.h HAVE_SYS_VFS_H)
ardour_check_header(sys/statvfs.h HAVE_SYS_STATVFS_H)
if (CMAKE_SYSTEM_NAME STREQUAL "Linux")
    check_source_compiles(C [[
#define _DEFAULT_SOURCE
 #include <unistd.h>
#include <sys/syscall.h>
int main () { syscall(SYS_ioprio_set, 1, 0, 8192); return 0; }
]] ARDOUR_HAVE_IOPRIO)
    if (ARDOUR_HAVE_IOPRIO)
        ardour_define(HAVE_IOPRIO 1)
    endif ()
endif ()
ardour_write_config_header(libs/ardour/libardour-config.h)
# autowaf.check_header(conf, 'cxx', 'boost/ptr_container/ptr_list.hpp')
set(CMAKE_REQUIRED_INCLUDES ${_ardour_boost_inc})
ardour_check_header(boost/ptr_container/ptr_list.hpp HAVE_BOOST_PTR_CONTAINER_PTR_LIST_HPP CXX)
unset(CMAKE_REQUIRED_INCLUDES)

# libs/widgets
ardour_check_pkg(SIGCPP2_12_1 sigc++-2.0 ATLEAST 2.12.1 OPTIONAL)

# libs/plugins/*.lv2
ardour_check_pkg(LV2_1_0_0 lv2 ATLEAST 1.0.0)

# gtk2_ardour
ardour_check_pkg(X11 x11 ATLEAST 1.1 OPTIONAL)
ardour_check_pkg(PANGOFT2 pangoft2 ATLEAST 1.36.8 OPTIONAL)
ardour_check_pkg(FONTCONFIG fontconfig)
if (APPLE)
    set(CMAKE_REQUIRED_FLAGS "-framework AppKit")
    check_source_compiles(OBJC [[
#include <AppKit/NSWindow.h>
 int main(void) { (void) NSWindowWillStartLiveResizeNotification; return 0; }
]] ARDOUR_HAVE_COCOA_LIVE_RESIZING)
    unset(CMAKE_REQUIRED_FLAGS)
    if (ARDOUR_HAVE_COCOA_LIVE_RESIZING)
        ardour_define(HAVE_COCOA_LIVE_RESIZING 1)
    else ()
        ardour_undefine(HAVE_COCOA_LIVE_RESIZING)
    endif ()
endif ()
ardour_write_config_header(gtk2_ardour/gtk2ardour-config.h)

# luasession: readline (static first, then shared).
find_path(ARDOUR_READLINE_INCLUDE_DIR readline/readline.h)
find_library(ARDOUR_READLINE_LIBRARY readline)
if (ARDOUR_READLINE_INCLUDE_DIR AND ARDOUR_READLINE_LIBRARY)
    ardour_add_uselib(READLINE)
    target_include_directories(ardour-uselib-READLINE INTERFACE "${ARDOUR_READLINE_INCLUDE_DIR}")
    target_link_libraries(ardour-uselib-READLINE INTERFACE "${ARDOUR_READLINE_LIBRARY}")
    ardour_define(HAVE_READLINE 1)
else ()
    ardour_undefine(HAVE_READLINE)
endif ()
