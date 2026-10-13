# Port of libs/plugins/a-exp.lv2/wscript.

ardour_add_lv2_bundle(a-exp TTL manifest.ttl a-exp.ttl "a-exp#stereo.ttl")
target_sources(a-exp PRIVATE a-exp.c)
target_compile_options(a-exp PRIVATE -std=c99)
ardour_includes(a-exp PRIVATE ../../ardour ../shared)
ardour_uselib(a-exp CAIRO)
