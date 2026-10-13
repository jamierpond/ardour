# The bundled LV2 plugins, in the root wscript's order (a-vapor is commented
# out there too).

include(ArdourLV2)

add_subdirectory(reasonablesynth.lv2)
add_subdirectory(a-comp.lv2)
add_subdirectory(a-exp.lv2)
add_subdirectory(a-delay.lv2)
add_subdirectory(a-eq.lv2)
add_subdirectory(a-reverb.lv2)
add_subdirectory(a-fluidsynth.lv2)
