# waf's conf.define() and conf.write_config_header(), for the CMake build.
#
# In waf every conf.define() lands in two places: the DEFINES every compile
# task gets on its command line, and every config header written afterwards
# (libpbd-config.h, libardour-config.h, ...), each of which is a snapshot of
# the defines made so far. ardour_define() keeps both: the define goes onto
# ardour-build-flags (so every target sees it, as in waf) and onto an ordered
# list that ardour_write_config_header() snapshots. Calling these in the same
# order as the wscript configure() functions reproduces the headers line for
# line.

define_property(GLOBAL PROPERTY ARDOUR_CONFIG_DEFINES
        BRIEF_DOCS "Ordered conf.define() list: NAME=VALUE, or !NAME for an undefine")

# conf.define(NAME, VALUE). VALUE defaults to 1. Pass QUOTED for a string value
# (waf quotes strings: CONFIG_ARCH="arm64").
function(ardour_define name)
    cmake_parse_arguments(ARG "QUOTED" "" "" ${ARGN})
    set(value 1)
    if (DEFINED ARG_UNPARSED_ARGUMENTS)
        list(GET ARG_UNPARSED_ARGUMENTS 0 value)
    endif ()
    if (ARG_QUOTED)
        set(value "\"${value}\"")
    endif ()

    # waf keeps one entry per name (define_key); a re-define replaces the
    # value but keeps the name's original position in the headers.
    get_property(defines GLOBAL PROPERTY ARDOUR_CONFIG_DEFINES)
    set(index -1)
    set(i 0)
    foreach (entry IN LISTS defines)
        if (entry MATCHES "^!?${name}(=|$)")
            set(index ${i})
        endif ()
        math(EXPR i "${i} + 1")
    endforeach ()
    if (index EQUAL -1)
        list(APPEND defines "${name}=${value}")
    else ()
        list(REMOVE_AT defines ${index})
        list(INSERT defines ${index} "${name}=${value}")
    endif ()
    set_property(GLOBAL PROPERTY ARDOUR_CONFIG_DEFINES "${defines}")

    get_target_property(defs ardour-build-flags INTERFACE_COMPILE_DEFINITIONS)
    if (NOT defs)
        set(defs "")
    endif ()
    list(FILTER defs EXCLUDE REGEX "^${name}(=|$)")
    list(APPEND defs "${name}=${value}")
    set_target_properties(ardour-build-flags PROPERTIES INTERFACE_COMPILE_DEFINITIONS "${defs}")

    set(${name} "${value}" PARENT_SCOPE)
endfunction()

# A failed optional check: waf writes "/* #undef NAME */" into later headers.
function(ardour_undefine name)
    get_property(defines GLOBAL PROPERTY ARDOUR_CONFIG_DEFINES)
    list(FIND defines "!${name}" undefined)
    if (undefined EQUAL -1)
        list(FILTER defines EXCLUDE REGEX "^${name}(=|$)")
        list(APPEND defines "!${name}")
        set_property(GLOBAL PROPERTY ARDOUR_CONFIG_DEFINES "${defines}")
    endif ()
endfunction()

function(ardour_is_defined name out)
    get_property(defines GLOBAL PROPERTY ARDOUR_CONFIG_DEFINES)
    list(FILTER defines INCLUDE REGEX "^${name}(=|$)")
    if (defines)
        set(${out} ON PARENT_SCOPE)
    else ()
        set(${out} OFF PARENT_SCOPE)
    endif ()
endfunction()

# conf.write_config_header(<path>, remove=False): writes <build>/<path> with
# every define made so far, in waf's exact format.
function(ardour_write_config_header path)
    get_filename_component(file "${path}" NAME)
    string(TOUPPER "${file}" guard)
    string(REGEX REPLACE "[^A-Z0-9]" "_" guard "${guard}")
    set(guard "W_${guard}_WAF")

    set(text "/* WARNING! All changes made to this file will be lost! */\n\n")
    string(APPEND text "#ifndef ${guard}\n#define ${guard}\n\n")

    get_property(defines GLOBAL PROPERTY ARDOUR_CONFIG_DEFINES)
    foreach (entry IN LISTS defines)
        if (entry MATCHES "^!(.*)$")
            string(APPEND text "/* #undef ${CMAKE_MATCH_1} */\n")
        elseif (entry MATCHES "^([^=]+)=(.*)$")
            string(APPEND text "#define ${CMAKE_MATCH_1} ${CMAKE_MATCH_2}\n")
        endif ()
    endforeach ()

    string(APPEND text "\n#endif /* ${guard} */\n")

    # file(CONFIGURE) only touches the file when the content changes, so a
    # re-configure does not rebuild everything that includes it.
    file(CONFIGURE OUTPUT "${PROJECT_BINARY_DIR}/${path}" CONTENT "${text}" @ONLY)
endfunction()
