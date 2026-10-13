# The global compile and link flags, ported from set_compiler_flags() and
# configure() in the root wscript.
#
# waf appends these to the environment every task generator inherits, so every
# object file in the tree gets them. Here they live on one INTERFACE target,
# ardour-build-flags, that ardour_add_library()/ardour_add_executable() link
# PRIVATE into every target -- same reach, but nothing is set directory-wide
# and a consumer of an installed library does not inherit Ardour's warnings.
#
# Build types map onto waf's two modes:
#   Debug (default)  = ./waf configure            (-g, -DG_ENABLE_DEBUG)
#   Release          = ./waf configure --optimize
#   RelWithDebInfo   = ./waf configure --optimize --debug-symbols
# CMake's own per-config flags (-O3 -DNDEBUG, -g, ...) are cleared below so the
# waf flag dictionary is the only source of optimisation/debug flags.

if (NOT CMAKE_BUILD_TYPE AND NOT CMAKE_CONFIGURATION_TYPES)
    # waf's autowaf.set_options(debug_by_default=True): a plain configure is a
    # debuggable build.
    set(CMAKE_BUILD_TYPE Debug CACHE STRING
            "Debug (waf default), Release (--optimize) or RelWithDebInfo (--optimize --debug-symbols)"
            FORCE)
endif ()

foreach (lang C CXX OBJC OBJCXX)
    foreach (config DEBUG RELEASE RELWITHDEBINFO MINSIZEREL)
        set(CMAKE_${lang}_FLAGS_${config} "")
    endforeach ()
endforeach ()

add_library(ardour-build-flags INTERFACE)
add_library(Ardour::BuildFlags ALIAS ardour-build-flags)

if (MSVC)
    message(FATAL_ERROR
            "The CMake build does not port the wscript's MSVC flag set yet; "
            "use waf for MSVC builds.")
endif ()

# Which wscript flag dictionary applies: 'clang15-darwin', 'clang-darwin',
# 'clang', 'gcc-darwin' or 'gcc'.
set(_ardour_is_clang OFF)
if (CMAKE_CXX_COMPILER_ID MATCHES "Clang")
    set(_ardour_is_clang ON)
endif ()

set(_c   "$<COMPILE_LANGUAGE:C,OBJC>")
set(_cxx "$<COMPILE_LANGUAGE:CXX,OBJCXX>")
set(_debug "$<CONFIG:Debug>")
set(_optimize "$<NOT:$<CONFIG:Debug>>")

# --- autowaf.configure() ----------------------------------------------------
# Every target sees the source root and the build root on its include path
# (autowaf prepends -I<top> to CFLAGS/CXXFLAGS and adds the build node to
# INCPATHS). The build root is where the generated config headers live.
target_include_directories(ardour-build-flags INTERFACE
        "${PROJECT_SOURCE_DIR}"
        "${PROJECT_BINARY_DIR}")

# --- autowaf.set_basic_compiler_flags() -------------------------------------
# 'debuggable' / 'nondebuggable' and 'show-column'.
target_compile_options(ardour-build-flags INTERFACE
        "$<${_debug}:-g>"
        -fshow-column)
target_compile_definitions(ardour-build-flags INTERFACE "$<${_optimize}:NDEBUG>")

# --- set_compiler_flags(): optimisation vs. debug ---------------------------
# Debug: debug_flags = [-DG_ENABLE_DEBUG] (also with --gtk-debug).
# Optimised: optimization_flags = full-optimization + pipe (+ -g for
# --debug-symbols, i.e. RelWithDebInfo).
option(ARDOUR_GTK_DEBUG "Enable g/ytk debug mode (G_ENABLE_DEBUG) in optimised builds too (waf --gtk-debug)" OFF)

if (APPLE AND _ardour_is_clang)
    # clang_darwin_dict['full-optimization']
    set(_ardour_full_optimization -O3 -ffast-math -fno-finite-math-only)
elseif (_ardour_is_clang)
    set(_ardour_full_optimization -O3 -fomit-frame-pointer -ffast-math -fno-finite-math-only)
else ()
    set(_ardour_full_optimization -O3 -fomit-frame-pointer -ffast-math -fno-finite-math-only -fstrength-reduce)
endif ()

if (ARDOUR_GTK_DEBUG)
    target_compile_definitions(ardour-build-flags INTERFACE G_ENABLE_DEBUG)
else ()
    target_compile_definitions(ardour-build-flags INTERFACE "$<${_debug}:G_ENABLE_DEBUG>")
endif ()
target_compile_options(ardour-build-flags INTERFACE
        "$<${_optimize}:${_ardour_full_optimization};-pipe>"
        "$<$<CONFIG:RelWithDebInfo>:-g>")

# The 'dsp-optimization' entry, used by the zita libs, staffpad and the
# bundled LV2 plugins regardless of build type.
set(ARDOUR_DSP_OPTIMIZATION -O3 -ffast-math)

# --- FPU optimisation -------------------------------------------------------
option(ARDOUR_FPU_OPTIMIZATION "Build with runtime-checked SIMD code (waf: on unless --no-fpu-optimization)" ON)

if (ARDOUR_FPU_OPTIMIZATION)
    if (APPLE)
        # Accelerate itself is linked through Ardour::OSX (LINKFLAGS_OSX).
        target_compile_definitions(ardour-build-flags INTERFACE BUILD_VECLIB_OPTIMIZATIONS)
    elseif (CMAKE_SYSTEM_PROCESSOR MATCHES "x86_64|AMD64|i[3-6]86")
        target_compile_definitions(ardour-build-flags INTERFACE BUILD_SSE_OPTIMIZATIONS)
    endif ()
endif ()

if (ARDOUR_FPU_OPTIMIZATION AND CMAKE_SYSTEM_PROCESSOR MATCHES "aarch64|armv7" AND NOT APPLE)
    set(ARDOUR_ARM_NEON_SUPPORT ON)
endif ()

if (CMAKE_SYSTEM_PROCESSOR MATCHES "x86_64|AMD64|i[3-6]86" AND NOT CMAKE_OSX_ARCHITECTURES MATCHES "arm64")
    target_compile_definitions(ardour-build-flags INTERFACE ARCH_X86)
endif ()

# --- macOS compatibility ----------------------------------------------------
# wscript: -DMAC_OS_X_VERSION_MAX_ALLOWED=110000 -mmacosx-version-min=11.0 for
# every current build host (10.13 only for the old Intel builders). The
# -mmacosx-version-min half is what CMAKE_OSX_DEPLOYMENT_TARGET emits, set in
# the root CMakeLists before project().
if (APPLE)
    if (CMAKE_OSX_DEPLOYMENT_TARGET VERSION_LESS 11.0)
        target_compile_definitions(ardour-build-flags INTERFACE MAC_OS_X_VERSION_MAX_ALLOWED=101300)
    else ()
        target_compile_definitions(ardour-build-flags INTERFACE MAC_OS_X_VERSION_MAX_ALLOWED=110000)
    endif ()
endif ()

# --- warnings ---------------------------------------------------------------
if (_ardour_is_clang)
    set(_ardour_basic_warnings -Wall -Wpointer-arith -Wcast-qual -Wcast-align
            -Wno-unused-parameter -Wno-deprecated-declarations)
    if (APPLE AND CMAKE_CXX_COMPILER_VERSION VERSION_GREATER_EQUAL 15)
        # clang15_darwin_dict: "Xcode 15 does not like our boost version".
        list(APPEND _ardour_basic_warnings
                -Wno-deprecated-builtins -Wno-deprecated-copy-with-user-provided-copy)
    endif ()
    set(_ardour_extra_cxx_warnings -Woverloaded-virtual -Wno-mismatched-tags
            -Wno-cast-align -Wno-unused-local-typedefs -Wunneeded-internal-declaration)
else ()
    set(_ardour_basic_warnings -Wall -Wpointer-arith -Wcast-qual -Wcast-align -Wno-unused-parameter)
    if (APPLE)
        set(_ardour_extra_cxx_warnings -Woverloaded-virtual)
    else ()
        set(_ardour_extra_cxx_warnings -Woverloaded-virtual -Wno-unused-local-typedefs -Wno-deprecated-copy)
    endif ()
endif ()
set(_ardour_extra_c_warnings -Wstrict-prototypes -Wmissing-prototypes)

target_compile_options(ardour-build-flags INTERFACE
        ${_ardour_basic_warnings}
        "$<${_c}:${_ardour_extra_c_warnings}>"
        "$<${_cxx}:${_ardour_extra_cxx_warnings}>")

if (APPLE AND _ardour_is_clang)
    # "Silence warnings about the non-existing osx clang compiler flags
    # -compatibility_version and -current_version."
    target_compile_options(ardour-build-flags INTERFACE -Qunused-arguments)
endif ()

# --- boilerplate defines ----------------------------------------------------
# "need ISOC9X for llabs()"
target_compile_definitions(ardour-build-flags INTERFACE
        BOOST_SYSTEM_NO_DEPRECATED
        _ISOC9X_SOURCE
        _LARGEFILE64_SOURCE
        _FILE_OFFSET_BITS=64
        "PROGRAM_NAME=\"${ARDOUR_PROGRAM_NAME}\""
        "PROGRAM_VERSION=\"${ARDOUR_PROGRAM_VERSION}\""
        "$<${_cxx}:__STDC_LIMIT_MACROS;__STDC_FORMAT_MACROS;CANVAS_DEBUG>"
        # Do not use Boost.System library
        "$<${_cxx}:BOOST_ERROR_CODE_HEADER_ONLY>")

if (ARDOUR_PROGRAM_NAME MATCHES "^[Mm][Ii][Xx][Bb][Uu][Ss]")
    target_compile_definitions(ardour-build-flags INTERFACE MIXBUS)
endif ()

# libpbd's configure appends this to the global CFLAGS -- C only, every target.
target_compile_definitions(ardour-build-flags INTERFACE "$<${_c}:_POSIX_C_SOURCE=200809L>")

if (APPLE)
    # "Mavericks and later changed the syntax to be used when including Carbon
    # headers" / "C++17 removes 'unary_function' and 'binary_function' this
    # breaks older boost versions".
    target_compile_definitions(ardour-build-flags INTERFACE
            "$<${_cxx}:CARBON_FLAT_HEADERS;_LIBCPP_ENABLE_CXX17_REMOVED_UNARY_BINARY_FUNCTION>")
else ()
    target_compile_definitions(ardour-build-flags INTERFACE "$<${_cxx}:BOOST_NO_AUTO_PTR>")
endif ()

# "Tell everyone that this is a waf build". The sources read it as "built by
# Ardour's own build, with its generated config headers" (e.g.
# vamp-plugins/plugins.cpp includes libvampplugins-config.h under it), which is
# just as true here, so the CMake build defines it too.
target_compile_definitions(ardour-build-flags INTERFACE WAF_BUILD)

# --- sanitizers / profiling -------------------------------------------------
option(ARDOUR_ADDRESS_SANITIZER "Turn on AddressSanitizer (waf --address-sanitizer)" OFF)
option(ARDOUR_THREAD_SANITIZER "Turn on ThreadSanitizer (waf --thread-sanitizer)" OFF)
option(ARDOUR_PROFILE "Compile with a frame pointer for profiling tools (waf --profile)" OFF)

if (ARDOUR_ADDRESS_SANITIZER)
    target_compile_options(ardour-build-flags INTERFACE "$<${_cxx}:-fsanitize=address;-fno-omit-frame-pointer>")
    target_link_options(ardour-build-flags INTERFACE -fsanitize=address)
endif ()

if (ARDOUR_THREAD_SANITIZER)
    target_compile_options(ardour-build-flags INTERFACE -fsanitize=thread -fno-omit-frame-pointer)
    target_link_options(ardour-build-flags INTERFACE -fsanitize=thread)
endif ()

if (ARDOUR_PROFILE)
    target_compile_options(ardour-build-flags INTERFACE "$<${_optimize}:-fno-omit-frame-pointer>")
endif ()

# --- link flags -------------------------------------------------------------
if (APPLE)
    # "this is required, potentially, for anything we link and then relocate
    # into a bundle"
    target_link_options(ardour-build-flags INTERFACE "LINKER:-headerpad_max_install_names")
endif ()

if (NOT WIN32)
    # "explicitly link against libm. This is possible on all POSIX systems and
    # required on Linux for symbol versioning and ABI compatibility"
    target_link_libraries(ardour-build-flags INTERFACE m)
endif ()

# --- C++ standard -----------------------------------------------------------
# wscript: -std=c++17 on darwin or with --cxx17; everything else uses the
# compiler default. Pin 17 everywhere: current compilers default to 17 already.
set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_CXX_EXTENSIONS OFF)
set(CMAKE_OBJCXX_STANDARD 17)
set(CMAKE_OBJCXX_EXTENSIONS OFF)
