# Port of libs/plugins/a-comp.lv2/wscript.

ardour_add_lv2_bundle(a-comp TTL manifest.ttl a-comp.ttl "a-comp#stereo.ttl" presets.ttl)
target_sources(a-comp PRIVATE a-comp.c)
target_compile_options(a-comp PRIVATE -std=c99)
ardour_includes(a-comp PRIVATE ../../ardour ../shared)
ardour_uselib(a-comp CAIRO)
