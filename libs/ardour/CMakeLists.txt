# libs/ardour/wscript. revision.cc and config_text.cc are generated into the
# build tree (waf writes them into the source tree, hence the EXCLUDE).
set(_exclude
        revision.cc config_text.cc luabindings.cc sha1.c beatbox.cc step_sequencer.cc st_stretch.cc
        lxvst_plugin.cc linux_vst_support.cc windows_vst_plugin.cc
        mac_vst_plugin.cc mac_vst_support.cc coreaudiosource.cc caimportable.cc audio_unit.cc auv2_scan.cc
        aarch64_neon_functions.cc arm_neon_functions.cc sse_functions_xmm.cc sse_functions_avx.cc
        sse_functions_avx_linux.cc x86_functions_fma.cc x86_functions_avx512f.cc)
set(_use pbd midipp evoral audiographer temporal lua ptformat staffpad zita-resampler zita-convolver ltc fluidsynth suil)
set(_uselib GLIBMM GTHREAD AUBIO SIGCPP XML LO USB SNDFILE SAMPLERATE AUDIOUNITS GIOMM FFTW3F
        LILV SERD SORD SRATOM OSX CURL TAGLIB VAMPSDK VAMPHOSTSDK RUBBERBAND DL)
set(_defines LIBARDOUR_DLL_EXPORTS=1 VST3_SUPPORT
        "PACKAGE=\"ardour${ARDOUR_VERSION_MAJOR}\"" "DATA_DIR=\"${ARDOUR_DATADIR}\""
        "CONFIG_DIR=\"${ARDOUR_SYSCONFDIR}\"" "LOCALEDIR=\"${ARDOUR_LOCALEDIR}\""
        "LIBARDOUR=\"${ARDOUR_LWRCASE_DIRNAME}\"")
set(_includes . ../vst3/ ../ctrl-interface/control_protocol ..)

if (APPLE)
    set(_platform mac_vst_plugin.cc mac_vst_support.cc coreaudiosource.cc caimportable.cc audio_unit.cc auv2_scan.cc)
    list(APPEND _use appleutility)
    list(APPEND _defines MACVST_SUPPORT)
else ()
    set(_platform windows_vst_plugin.cc)
    list(APPEND _use vstwin)
    list(APPEND _uselib GDI32)
    list(APPEND _defines WINDOWS_VST_SUPPORT)
    list(APPEND _includes ../fst)
    set(_options $<$<COMPILE_LANGUAGE:CXX>:-Og>)
    set(_lua_options "$<$<CONFIG:Debug>:-Og;-Wa,-mbig-obj>")
endif ()

# The Lua bindings: one huge translation unit, a static lib with libardour's
# includes, uselibs and use list.
ardour_target(luabindings STATIC
        SOURCES luabindings.cc
        INCLUDES ${_includes}
        USE ${_use}
        USELIB ${_uselib}
        OPTIONS ${_lua_options})

ardour_target(ardour SHARED GLOB
        EXCLUDE ${_exclude}
        SOURCES ${_platform} "${CMAKE_CURRENT_BINARY_DIR}/revision.cc" "${CMAKE_CURRENT_BINARY_DIR}/config_text.cc"
        INCLUDES ${_includes}
        EXPORT_INCLUDES .
        USE ${_use} luabindings
        USELIB ${_uselib}
        DEFINES ${_defines}
        OPTIONS ${_options})

# waf rewrites revision.cc on every build; the script only touches it when
# HEAD moved.
add_custom_target(ardour-revision
        COMMAND "${ARDOUR_NODE}" "${PROJECT_SOURCE_DIR}/scripts/ardour-version.mjs"
                --revision-cc "${CMAKE_CURRENT_BINARY_DIR}/revision.cc"
        BYPRODUCTS "${CMAKE_CURRENT_BINARY_DIR}/revision.cc")
add_dependencies(ardour ardour-revision)

# config_text.cc: the build summary in the About dialog. Deviation: waf lists
# ~60 configure answers and its raw flag lists; this names the build instead.
file(CONFIGURE OUTPUT "${CMAKE_CURRENT_BINARY_DIR}/config_text.cc" @ONLY CONTENT [[
#include "ardour/ardour.h"
namespace ARDOUR {
const char* const ardour_config_info = "\n\
Build system: CMake @CMAKE_VERSION@\n\
Build type: @CMAKE_BUILD_TYPE@\n\
Install prefix: @CMAKE_INSTALL_PREFIX@\n\
C++ compiler: @CMAKE_CXX_COMPILER_ID@ @CMAKE_CXX_COMPILER_VERSION@\n\
";
}
]])
