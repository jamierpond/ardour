# The bundled LV2 plugins (libs/plugins/*.lv2). Each wscript builds the same
# shape: a module without the 'lib' prefix and its .ttl files, substituted with
# @LIB_EXT@, all placed in <build>/libs/LV2/<bundle>/ -- the directory Ardour
# searches when run from the build tree.
#
#   ardour_add_lv2_bundle(<name> TTL <file>...)
#
# The caller then adds sources and flags to the <name> target as its wscript
# does.

set(ARDOUR_LV2_BUILD_DIR "${PROJECT_BINARY_DIR}/libs/LV2")

function(ardour_add_lv2_bundle name)
    cmake_parse_arguments(ARG "" "" "TTL" ${ARGN})
    set(bundle "${name}.lv2")
    set(out_dir "${ARDOUR_LV2_BUILD_DIR}/${bundle}")

    ardour_add_library(${name} SHARED)
    set_target_properties(${name} PROPERTIES
            PREFIX ""
            LIBRARY_OUTPUT_DIRECTORY "${out_dir}"
            RUNTIME_OUTPUT_DIRECTORY "${out_dir}")
    # use = 'LV2_1_0_0'
    ardour_uselib(${name} LV2_1_0_0)

    # obj.LIB_EXT = module_ext ('.dylib', '.so', '.dll')
    set(LIB_EXT "${CMAKE_SHARED_LIBRARY_SUFFIX}")
    foreach (ttl IN LISTS ARG_TTL)
        configure_file("${ttl}.in" "${out_dir}/${ttl}" @ONLY)
    endforeach ()

    install(TARGETS ${name} LIBRARY DESTINATION "${ARDOUR_LV2DIR}/${bundle}")
    foreach (ttl IN LISTS ARG_TTL)
        install(FILES "${out_dir}/${ttl}" DESTINATION "${ARDOUR_LV2DIR}/${bundle}")
    endforeach ()
endfunction()
