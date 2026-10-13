# Global build setup for the CMake port of the wscripts: version, compiler
# flags, the configure answers (conf.define) and the generated config headers,
# plus ardour_target(), the one helper every CMakeLists.txt uses.
#
# Supported: macOS 12+ (Apple clang, Homebrew deps) and Windows 10+ (MSYS2
# UCRT64 MinGW gcc). Everything else the wscripts handle is left to waf.

# --- version -----------------------------------------------------------------
# git describe -> 9.8-207-g488c059492 -> 9.8.207, as the root wscript's
# set_version() does it.
execute_process(
        COMMAND "${ARDOUR_NODE}" "${PROJECT_SOURCE_DIR}/scripts/ardour-version.mjs" --json
        OUTPUT_VARIABLE _json COMMAND_ERROR_IS_FATAL ANY)
foreach (key major minor micro version)
    string(TOUPPER "ARDOUR_VERSION_${key}" var)
    string(JSON ${var} GET "${_json}" ${key})
endforeach ()
set(ARDOUR_VERSION "${ARDOUR_VERSION_VERSION}")
set_property(DIRECTORY APPEND PROPERTY CMAKE_CONFIGURE_DEPENDS "${PROJECT_SOURCE_DIR}/.git/HEAD")

# Install layout from the root wscript's build(): <prefix>/{lib,share}/ardour<MAJOR>.
include(GNUInstallDirs)
set(ARDOUR_LWRCASE_DIRNAME "ardour${ARDOUR_VERSION_MAJOR}")
set(ARDOUR_DLLDIR "${CMAKE_INSTALL_FULL_LIBDIR}/${ARDOUR_LWRCASE_DIRNAME}")
set(ARDOUR_DATADIR "${CMAKE_INSTALL_FULL_DATADIR}/${ARDOUR_LWRCASE_DIRNAME}")
set(ARDOUR_CONFDIR "${CMAKE_INSTALL_FULL_SYSCONFDIR}/${ARDOUR_LWRCASE_DIRNAME}")
set(ARDOUR_SYSCONFDIR "${CMAKE_INSTALL_FULL_SYSCONFDIR}")
set(ARDOUR_LOCALEDIR "${ARDOUR_DATADIR}/locale")

# --- compiler flags (root wscript, set_compiler_flags) ----------------------
# Debug = plain `./waf configure`, Release = `--optimize`. CMake's own
# per-config flags are cleared so these are the only ones.
if (NOT CMAKE_BUILD_TYPE)
    set(CMAKE_BUILD_TYPE Debug CACHE STRING "Debug (waf default) or Release (waf --optimize)" FORCE)
endif ()
foreach (lang C CXX OBJC OBJCXX)
    foreach (config DEBUG RELEASE RELWITHDEBINFO MINSIZEREL)
        set(CMAKE_${lang}_FLAGS_${config} "")
    endforeach ()
endforeach ()

# -std=c++17: waf uses it on macOS and with --cxx17; MSYS2's gcc 16 defaults
# to C++20, which libpbd does not compile under, so it is pinned everywhere.
set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_EXTENSIONS OFF)
set(CMAKE_OBJCXX_STANDARD 17)
set(CMAKE_OBJCXX_EXTENSIONS OFF)

add_library(ardour-flags INTERFACE)

set(_c "$<COMPILE_LANGUAGE:C,OBJC>")
set(_cxx "$<COMPILE_LANGUAGE:CXX,OBJCXX>")
set(_debug "$<CONFIG:Debug>")

if (APPLE)
    set(_optimize -O3 -ffast-math -fno-finite-math-only)
    set(_warnings -Wall -Wpointer-arith -Wcast-qual -Wcast-align -Wno-unused-parameter
            -Wno-deprecated-declarations -Wno-deprecated-builtins -Wno-deprecated-copy-with-user-provided-copy)
    set(_cxx_warnings -Woverloaded-virtual -Wno-mismatched-tags -Wno-cast-align
            -Wno-unused-local-typedefs -Wunneeded-internal-declaration)
else ()
    set(_optimize -O3 -fomit-frame-pointer -ffast-math -fno-finite-math-only -fstrength-reduce)
    set(_warnings -Wall -Wpointer-arith -Wcast-qual -Wcast-align -Wno-unused-parameter)
    set(_cxx_warnings -Woverloaded-virtual -Wno-unused-local-typedefs -Wno-deprecated-copy)
endif ()

# 'dsp-optimization', for the zita libs and staffpad in every build type.
set(ARDOUR_DSP_OPTIMIZATION -O3 -ffast-math)

target_compile_options(ardour-flags INTERFACE
        "$<IF:${_debug},-g,${_optimize};-pipe>"
        -fshow-column
        ${_warnings}
        "$<${_c}:-Wstrict-prototypes;-Wmissing-prototypes>"
        "$<${_cxx}:${_cxx_warnings}>")

target_compile_definitions(ardour-flags INTERFACE
        "$<IF:${_debug},G_ENABLE_DEBUG,NDEBUG>"
        BOOST_SYSTEM_NO_DEPRECATED _ISOC9X_SOURCE _LARGEFILE64_SOURCE _FILE_OFFSET_BITS=64
        "PROGRAM_NAME=\"Ardour\"" "PROGRAM_VERSION=\"${ARDOUR_VERSION_MAJOR}\""
        HAVE_RF64_RIFF COMPILER_INT128_SUPPORT
        # Read by the sources as "built by Ardour's own build, with its
        # generated config headers", which holds here too.
        WAF_BUILD
        # libpbd's configure appends this to the global CFLAGS (C only).
        "$<${_c}:_POSIX_C_SOURCE=200809L>"
        "$<${_cxx}:__STDC_LIMIT_MACROS;__STDC_FORMAT_MACROS;CANVAS_DEBUG;BOOST_ERROR_CODE_HEADER_ONLY>")

# autowaf puts the source root and build root on every include path.
target_include_directories(ardour-flags INTERFACE "${PROJECT_SOURCE_DIR}" "${PROJECT_BINARY_DIR}")

if (APPLE)
    target_compile_options(ardour-flags INTERFACE -Qunused-arguments)
    target_compile_definitions(ardour-flags INTERFACE
            BUILD_VECLIB_OPTIMIZATIONS
            # waf: 110000 with -mmacosx-version-min=11.0. The SDK rejects a
            # maximum below the 12.0 deployment target, so it follows it.
            MAC_OS_X_VERSION_MAX_ALLOWED=120000
            "$<${_cxx}:CARBON_FLAT_HEADERS;_LIBCPP_ENABLE_CXX17_REMOVED_UNARY_BINARY_FUNCTION>")
    target_link_options(ardour-flags INTERFACE "LINKER:-headerpad_max_install_names")
    target_link_libraries(ardour-flags INTERFACE m)
else ()
    # --dist-target=mingw --cxx17 on x86_64. waf only adds BUILD_SSE_OPTIMIZATIONS
    # for a compiler named x86_64-w64-* (a cross compiler), not MSYS2's gcc.exe.
    target_compile_options(ardour-flags INTERFACE -msse -mfpmath=sse -masm=att -mxsave -fno-inline-functions)
    target_compile_definitions(ardour-flags INTERFACE
            # Windows 10 is the floor (waf leaves it to the toolchain default).
            _WIN32_WINNT=0x0A00
            PLATFORM_WINDOWS COMPILER_MINGW USE_CAIRO_IMAGE_SURFACE MINGW_NATIVE_TLS
            ARCH_X86 USE_XMMINTRIN _USE_MATH_DEFINES WIN32
            "$<${_cxx}:BOOST_NO_AUTO_PTR>")
    target_link_libraries(ardour-flags INTERFACE pthread ws2_32 winmm intl dbghelp)
endif ()

# --- configure answers (conf.define) ----------------------------------------
# What waf's configure decides on each platform, in its define_key order, with
# the probes replaced by their answers. "!NAME" is a failed optional check
# (/* #undef NAME */); ">path" is where a wscript calls write_config_header(),
# so each generated header holds exactly the defines made before it, as in
# waf. Every define is also passed to every compile, as waf does.
if (APPLE)
    set(ARDOUR_DEFINES
            NEED_INTL=1 HAVE_COREAUDIO=1 AUDIOUNIT_SUPPORT=1 MACVST_SUPPORT=1 TOP_MENUBAR=1
            INTERNAL_SHARED_LIBS=1 HAVE_GLIB=1 HAVE_GTHREAD=1 HAVE_GLIBMM=1 HAVE_SNDFILE=1
            HAVE_GIOMM=1 HAVE_CURL=1 HAVE_ARCHIVE=1 HAVE_LO=1 HAVE_TAGLIB=1 HAVE_VAMPSDK=1
            HAVE_VAMPHOSTSDK=1 HAVE_RUBBERBAND=1 HAVE_USB=1 HAVE_RUBBERBAND_3_0_0=1 YTK=1
            HAVE_SUIL=1 EXPORT_VISIBILITY_HIDDEN=0 PHONE_HOME=1 ENABLE_NLS=1 VST3_SUPPORT=1
            _DARWIN_C_SOURCE=1 "CONFIG_ARCH=\"${CMAKE_SYSTEM_PROCESSOR}\"" HAVE_LIBS_APPLEUTILITY=1
            HAVE_FFTW3F=1 HAVE_HIDAPI=1 HAVE_AUBIO=1 HAVE_AUBIO4=1
            >libs/vamp-plugins/libvampplugins-config.h
            HAVE_GOBJECT=1 HAVE_GIO=1 HAVE_LIBPNG=1 HAVE_UNISTD_H=1 HAVE_LIBJPEG=1 HAVE_PANGO=1
            HAVE_CAIRO=1 HAVE_PANGOCAIRO=1 HAVE_GMODULE=1 HAVE_SIGCPP=1 HAVE_CAIROMM=1
            HAVE_PANGOMM=1 HAVE_LV2_1_16_0=1 HAVE_XML=1 HAVE_EXECINFO_H=1 HAVE_POSIX_MEMALIGN=1
            !HAVE_GETMNTENT HAVE_LOCALTIME_R=1
            >libs/pbd/libpbd-config.h
            HAVE_CONTROL_PROTOCOL=1 HAVE_MIDI_SURFACE=1 !HAVE_CWIID_H HAVE_WEBSOCKETS=1
            HAVE_SAMPLERATE=1 HAVE_LV2=1 HAVE_LV2_1_10_0=1 HAVE_LV2_1_17_2=1 HAVE_LV2_1_18_6=1
            HAVE_SERD=1 HAVE_SORD=1 HAVE_SRATOM=1 HAVE_LILV=1 LV2_SUPPORT=1 USE_TLSF=1
            LV2_EXTENDED=1 HAVE_OGG=1 HAVE_FLAC=1 HAVE_FFTW35F=1 CURRENT_SESSION_FILE_VERSION=7003
            !HAVE_SYS_VFS_H HAVE_SYS_STATVFS_H=1
            >libs/ardour/libardour-config.h
            HAVE_BOOST_PTR_CONTAINER_PTR_LIST_HPP=1 HAVE_SIGCPP2_12_1=1 HAVE_LV2_1_0_0=1
            HAVE_PANGOFT2=1 HAVE_FONTCONFIG=1 HAVE_COCOA_LIVE_RESIZING=1
            >gtk2_ardour/gtk2ardour-config.h
            HAVE_READLINE=1)
else ()
    set(ARDOUR_DEFINES
            INTERNAL_SHARED_LIBS=1 HAVE_GLIB=1 HAVE_GTHREAD=1 HAVE_GLIBMM=1 HAVE_SNDFILE=1
            HAVE_GIOMM=1 HAVE_CURL=1 HAVE_ARCHIVE=1 HAVE_LO=1 HAVE_TAGLIB=1 HAVE_VAMPSDK=1
            HAVE_VAMPHOSTSDK=1 HAVE_RUBBERBAND=1 HAVE_USB=1 HAVE_RUBBERBAND_3_0_0=1
            HAVE_WINSOCK2_H=1 WINDOWS=1 YTK=1 HAVE_SUIL=1 EXPORT_VISIBILITY_HIDDEN=0 PHONE_HOME=1
            ENABLE_NLS=1 WINDOWS_VST_SUPPORT=1 VST3_SUPPORT=1 "CONFIG_ARCH=\"${CMAKE_SYSTEM_PROCESSOR}\""
            HAVE_FFTW3F=1 HAVE_HIDAPI=1 HAVE_AUBIO=1 HAVE_AUBIO4=1
            >libs/vamp-plugins/libvampplugins-config.h
            HAVE_GOBJECT=1 HAVE_GIO=1 HAVE_LIBPNG=1 HAVE_UNISTD_H=1 HAVE_LIBJPEG=1 HAVE_PANGO=1
            HAVE_CAIRO=1 HAVE_PANGOCAIRO=1 HAVE_GIO_WINDOWS=1 HAVE_GMODULE=1 HAVE_SIGCPP=1
            HAVE_CAIROMM=1 HAVE_PANGOMM=1 HAVE_LV2_1_16_0=1 HAVE_XML=1 !HAVE_EXECINFO_H
            !HAVE_POSIX_MEMALIGN !HAVE_GETMNTENT HAVE_LOCALTIME_R=1
            >libs/pbd/libpbd-config.h
            HAVE_CONTROL_PROTOCOL=1 HAVE_MIDI_SURFACE=1 !HAVE_CWIID_H HAVE_WEBSOCKETS=1
            HAVE_PORTAUDIO=1 !WITH_ASIO HAVE_SAMPLERATE=1 HAVE_LV2=1 HAVE_LV2_1_10_0=1
            HAVE_LV2_1_17_2=1 HAVE_LV2_1_18_6=1 HAVE_SERD=1 HAVE_SORD=1 HAVE_SRATOM=1 HAVE_LILV=1
            LV2_SUPPORT=1 USE_TLSF=1 LV2_EXTENDED=1 HAVE_OGG=1 HAVE_FLAC=1 HAVE_FFTW35F=1
            CURRENT_SESSION_FILE_VERSION=7003 !HAVE_SYS_VFS_H !HAVE_SYS_STATVFS_H
            >libs/ardour/libardour-config.h
            HAVE_BOOST_PTR_CONTAINER_PTR_LIST_HPP=1 HAVE_SIGCPP2_12_1=1 HAVE_LV2_1_0_0=1
            HAVE_PANGOFT2=1 HAVE_FONTCONFIG=1
            >gtk2_ardour/gtk2ardour-config.h
            HAVE_READLINE=1)
endif ()

set(_header_body "")
foreach (entry IN LISTS ARDOUR_DEFINES)
    if (entry MATCHES "^>(.*)$")
        # waf's write_config_header() format, guard and all.
        get_filename_component(_name "${CMAKE_MATCH_1}" NAME)
        string(MAKE_C_IDENTIFIER "${_name}" _guard)
        string(TOUPPER "W_${_guard}_WAF" _guard)
        file(CONFIGURE OUTPUT "${PROJECT_BINARY_DIR}/${CMAKE_MATCH_1}" @ONLY CONTENT
                "/* WARNING! All changes made to this file will be lost! */\n\n#ifndef ${_guard}\n#define ${_guard}\n\n${_header_body}\n#endif /* ${_guard} */\n")
    elseif (entry MATCHES "^!(.*)$")
        string(APPEND _header_body "/* #undef ${CMAKE_MATCH_1} */\n")
    elseif (entry MATCHES "^([^=]+)=(.*)$")
        string(APPEND _header_body "#define ${CMAKE_MATCH_1} ${CMAKE_MATCH_2}\n")
        target_compile_definitions(ardour-flags INTERFACE "${entry}")
        set(${CMAKE_MATCH_1} "${CMAKE_MATCH_2}")
    endif ()
endforeach ()

# --- ardour_target() ---------------------------------------------------------
# One call per wscript task generator:
#
#   ardour_target(<name> SHARED|STATIC|OBJECT|EXECUTABLE   shlib/stlib/objects/program
#       [OUTPUT_NAME <n>]                           obj.target
#       [GLOB] [EXCLUDE <file>...]                  *.c/*.cc/*.cpp here, minus EXCLUDE
#       [SOURCES <file>...]                         obj.source
#       [INCLUDES <dir>...]                         obj.includes
#       [EXPORT_INCLUDES <dir>...]                  obj.export_includes
#       [USE <target>...]                           obj.use (Ardour's own libs)
#       [USELIB <NAME>...]                          obj.uselib (Ardour::<NAME>)
#       [DEFINES <def>...] [OPTIONS <flag>...])     obj.defines / cflags+cxxflags
#
# GLOB is only used where the wscript's list is "every file here but these",
# so the EXCLUDE list is the whole difference. Include dirs resolve in both the
# source and build tree, as in waf. Ardour's shared libs link PUBLIC (waf's
# `use` is transitive); a static helper links PRIVATE but still exports its
# include dirs. A USELIB name nothing defines is ignored, as in waf.
function(ardour_target name kind)
    cmake_parse_arguments(A "GLOB" "OUTPUT_NAME"
            "EXCLUDE;SOURCES;INCLUDES;EXPORT_INCLUDES;USE;USELIB;DEFINES;OPTIONS" ${ARGN})

    if (kind STREQUAL "EXECUTABLE")
        add_executable(${name})
    else ()
        add_library(${name} ${kind})
        # Every static lib in the tree ends up inside a shared one.
        set_target_properties(${name} PROPERTIES POSITION_INDEPENDENT_CODE ON)
    endif ()
    target_link_libraries(${name} PRIVATE ardour-flags)
    if (A_OUTPUT_NAME)
        set_target_properties(${name} PROPERTIES OUTPUT_NAME "${A_OUTPUT_NAME}")
    endif ()

    if (A_GLOB)
        file(GLOB globbed CONFIGURE_DEPENDS RELATIVE "${CMAKE_CURRENT_SOURCE_DIR}" *.c *.cc *.cpp)
        if (A_EXCLUDE)
            list(REMOVE_ITEM globbed ${A_EXCLUDE})
        endif ()
        target_sources(${name} PRIVATE ${globbed})
    endif ()
    target_sources(${name} PRIVATE ${A_SOURCES})

    foreach (dir IN LISTS A_INCLUDES A_EXPORT_INCLUDES)
        set(scope PRIVATE)
        if (dir IN_LIST A_EXPORT_INCLUDES)
            set(scope INTERFACE)
            if (dir IN_LIST A_INCLUDES)
                set(scope PUBLIC)
            endif ()
        endif ()
        cmake_path(ABSOLUTE_PATH dir BASE_DIRECTORY "${CMAKE_CURRENT_SOURCE_DIR}" NORMALIZE OUTPUT_VARIABLE src)
        cmake_path(ABSOLUTE_PATH dir BASE_DIRECTORY "${CMAKE_CURRENT_BINARY_DIR}" NORMALIZE OUTPUT_VARIABLE bin)
        target_include_directories(${name} ${scope} "${bin}" "${src}")
    endforeach ()

    foreach (lib IN LISTS A_USE)
        get_target_property(type ${lib} TYPE)
        if (kind STREQUAL "SHARED" AND type MATCHES "STATIC_LIBRARY|OBJECT_LIBRARY")
            target_link_libraries(${name} PRIVATE ${lib})
            target_include_directories(${name} PUBLIC "$<TARGET_PROPERTY:${lib},INTERFACE_INCLUDE_DIRECTORIES>")
        else ()
            target_link_libraries(${name} PUBLIC ${lib})
        endif ()
    endforeach ()

    foreach (uselib IN LISTS A_USELIB)
        if (TARGET Ardour::${uselib})
            target_link_libraries(${name} PRIVATE Ardour::${uselib})
        endif ()
    endforeach ()

    target_compile_definitions(${name} PRIVATE ${A_DEFINES})
    target_compile_options(${name} PRIVATE ${A_OPTIONS})
endfunction()
