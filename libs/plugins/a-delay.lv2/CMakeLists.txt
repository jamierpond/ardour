# Port of libs/plugins/a-delay.lv2/wscript.

ardour_add_lv2_bundle(a-delay TTL manifest.ttl a-delay.ttl presets.ttl)
target_sources(a-delay PRIVATE a-delay.c)
target_compile_options(a-delay PRIVATE -std=c99)
ardour_includes(a-delay PRIVATE ../../ardour)
ardour_uselib(a-delay CAIRO)
