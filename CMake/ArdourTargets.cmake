# Target helpers that keep each library's CMakeLists.txt a direct transcription
# of its wscript task generator:
#
#   wscript                              CMake
#   -----------------------------------  ---------------------------------------
#   bld.shlib(...) / bld.stlib(...)      ardour_add_library(<t> SHARED|STATIC)
#   obj.target = 'pbd'                   OUTPUT_NAME pbd
#   obj.includes = ['.']                 ardour_includes(<t> PRIVATE .)
#   obj.export_includes = ['.']          ardour_includes(<t> PUBLIC .)
#   obj.use = 'libpbd libtemporal'       ardour_use(<t> pbd temporal)
#   obj.uselib = 'GLIBMM XML'            ardour_uselib(<t> GLIBMM XML)
#   obj.defines = [...]                  target_compile_definitions(<t> PRIVATE ...)
#
# Output files land where waf puts them: <build>/libs/pbd/libpbd.dylib, and so
# on, because each CMakeLists.txt sits in the same directory as its wscript.

# Every target gets the global flags, like every waf task generator gets the
# configured environment.
function(_ardour_target_common target)
    target_link_libraries(${target} PRIVATE ardour-build-flags)
endfunction()

# ardour_add_library(<target> SHARED|STATIC|OBJECT [OUTPUT_NAME <name>])
function(ardour_add_library target kind)
    cmake_parse_arguments(ARG "" "OUTPUT_NAME" "" ${ARGN})
    add_library(${target} ${kind})
    _ardour_target_common(${target})

    if (ARG_OUTPUT_NAME)
        set_target_properties(${target} PROPERTIES OUTPUT_NAME "${ARG_OUTPUT_NAME}")
    endif ()

    if (kind STREQUAL "STATIC" OR kind STREQUAL "OBJECT")
        # The wscripts add compiler_flags_dict['pic'] to every static lib:
        # they all end up inside shared libraries.
        set_target_properties(${target} PROPERTIES POSITION_INDEPENDENT_CODE ON)
    endif ()

    # No VERSION/SOVERSION from the wscripts' vnum: waf drops its own
    # -install_name/-compatibility_version on darwin (LINKFLAGS_cxxshlib = [],
    # LDFLAGS_cxxshlib = ['-dynamiclib']), so the dylibs are unversioned --
    # libpbd.dylib, not libpbd.4.1.0.dylib. Same file names here.
endfunction()

# ardour_add_executable(<target> [OUTPUT_NAME <name>])
function(ardour_add_executable target)
    cmake_parse_arguments(ARG "" "OUTPUT_NAME" "" ${ARGN})
    add_executable(${target})
    _ardour_target_common(${target})
    if (ARG_OUTPUT_NAME)
        set_target_properties(${target} PROPERTIES OUTPUT_NAME "${ARG_OUTPUT_NAME}")
    endif ()
endfunction()

# waf resolves an include dir in both the source tree and its mirror in the
# build tree (that is how the generated config headers are found), so each
# directory is added twice here too.
#   ardour_includes(<target> <PRIVATE|PUBLIC|INTERFACE> <dir>... [<scope> <dir>...])
function(ardour_includes target)
    set(scope PRIVATE)
    foreach (arg IN LISTS ARGN)
        if (arg MATCHES "^(PRIVATE|PUBLIC|INTERFACE)$")
            set(scope ${arg})
            continue()
        endif ()
        cmake_path(ABSOLUTE_PATH arg BASE_DIRECTORY "${CMAKE_CURRENT_SOURCE_DIR}"
                NORMALIZE OUTPUT_VARIABLE src_dir)
        cmake_path(ABSOLUTE_PATH arg BASE_DIRECTORY "${CMAKE_CURRENT_BINARY_DIR}"
                NORMALIZE OUTPUT_VARIABLE bin_dir)
        target_include_directories(${target} ${scope} "${bin_dir}" "${src_dir}")
    endforeach ()
endfunction()

# obj.use = '...': link Ardour's own libraries.
#
# waf propagates a used library's export_includes and, for shared libraries,
# its whole link closure to everything downstream, so shared libraries are
# linked PUBLIC. A static library is linked in only where it is used (waf does
# not relink it into consumers of the shared library that contains it), but its
# include dirs still propagate, so they are re-exported explicitly.
function(ardour_use target)
    get_target_property(self_type ${target} TYPE)
    foreach (lib IN LISTS ARGN)
        if (NOT TARGET ${lib})
            message(FATAL_ERROR "${target}: obj.use names '${lib}', which is not a target")
        endif ()
        get_target_property(type ${lib} TYPE)
        if (self_type STREQUAL "EXECUTABLE")
            target_link_libraries(${target} PRIVATE ${lib})
        elseif (type STREQUAL "STATIC_LIBRARY" AND self_type STREQUAL "SHARED_LIBRARY")
            target_link_libraries(${target} PRIVATE ${lib})
            target_include_directories(${target} PUBLIC
                    "$<TARGET_PROPERTY:${lib},INTERFACE_INCLUDE_DIRECTORIES>")
        else ()
            target_link_libraries(${target} PUBLIC ${lib})
        endif ()
    endforeach ()
endfunction()

# NEED_INTL: obj.linkflags += ' -lintl' (darwin links libintl explicitly).
function(ardour_link_intl target)
    if (APPLE)
        target_link_libraries(${target} PRIVATE Intl::Intl)
    endif ()
endfunction()
