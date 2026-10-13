# Port of libs/plugins/a-eq.lv2/wscript.

ardour_add_lv2_bundle(a-eq TTL manifest.ttl a-eq.ttl)
target_sources(a-eq PRIVATE a-eq.c)
target_compile_options(a-eq PRIVATE -std=c99)
ardour_includes(a-eq PRIVATE ../../ardour)
ardour_uselib(a-eq CAIRO)
