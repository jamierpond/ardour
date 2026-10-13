# libs/plugins/*.lv2/wscript. Each bundle builds into <build>/libs/LV2/<name>.lv2
# (module without 'lib' prefix + .ttl files with @LIB_EXT@ substituted), where
# Ardour looks when run from the build tree. a-vapor is disabled in waf too.
function(lv2_bundle name)
    cmake_parse_arguments(P "" "" "SOURCES;TTL;INCLUDES;USE;USELIB;OPTIONS" ${ARGN})
    set(out "${PROJECT_BINARY_DIR}/libs/LV2/${name}.lv2")
    list(TRANSFORM P_SOURCES PREPEND ${name}.lv2/)
    list(TRANSFORM P_INCLUDES PREPEND ${name}.lv2/)
    ardour_target(${name} SHARED
            SOURCES ${P_SOURCES}
            INCLUDES ${P_INCLUDES}
            USE ${P_USE}
            USELIB LV2_1_0_0 ${P_USELIB}
            OPTIONS ${P_OPTIONS})
    set_target_properties(${name} PROPERTIES PREFIX "" LIBRARY_OUTPUT_DIRECTORY "${out}" RUNTIME_OUTPUT_DIRECTORY "${out}")
    set(LIB_EXT "${CMAKE_SHARED_LIBRARY_SUFFIX}")
    foreach (ttl IN LISTS P_TTL)
        configure_file("${name}.lv2/${ttl}.in" "${out}/${ttl}" @ONLY)
    endforeach ()
endfunction()

set(_c99 $<$<COMPILE_LANGUAGE:C>:-std=c99>)
# lv2.c #includes rsynth.c (waf: dep_files).
lv2_bundle(reasonablesynth SOURCES lv2.c TTL manifest.ttl reasonablesynth.ttl)
lv2_bundle(a-comp SOURCES a-comp.c TTL manifest.ttl a-comp.ttl "a-comp#stereo.ttl" presets.ttl
        INCLUDES ../../ardour ../shared USELIB CAIRO OPTIONS ${_c99})
lv2_bundle(a-exp SOURCES a-exp.c TTL manifest.ttl a-exp.ttl "a-exp#stereo.ttl"
        INCLUDES ../../ardour ../shared USELIB CAIRO OPTIONS ${_c99})
lv2_bundle(a-delay SOURCES a-delay.c TTL manifest.ttl a-delay.ttl presets.ttl
        INCLUDES ../../ardour USELIB CAIRO OPTIONS ${_c99})
lv2_bundle(a-eq SOURCES a-eq.c TTL manifest.ttl a-eq.ttl
        INCLUDES ../../ardour USELIB CAIRO OPTIONS ${_c99})
lv2_bundle(a-reverb SOURCES a-reverb.c TTL manifest.ttl a-reverb.ttl
        INCLUDES ../../ardour USELIB CAIRO OPTIONS ${_c99})
lv2_bundle(a-fluidsynth SOURCES a-fluidsynth.cc TTL manifest.ttl a-fluidsynth.ttl
        INCLUDES ../../ardour USE fluidsynth USELIB GLIB)
