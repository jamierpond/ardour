# Port of libs/plugins/a-reverb.lv2/wscript.

ardour_add_lv2_bundle(a-reverb TTL manifest.ttl a-reverb.ttl)
target_sources(a-reverb PRIVATE a-reverb.c)
target_compile_options(a-reverb PRIVATE -std=c99)
ardour_includes(a-reverb PRIVATE ../../ardour)
ardour_uselib(a-reverb CAIRO)
