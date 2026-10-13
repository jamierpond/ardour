# Port of libs/plugins/a-fluidsynth.lv2/wscript.

ardour_add_lv2_bundle(a-fluidsynth TTL manifest.ttl a-fluidsynth.ttl)
target_sources(a-fluidsynth PRIVATE a-fluidsynth.cc)
ardour_includes(a-fluidsynth PRIVATE ../../ardour)
ardour_uselib(a-fluidsynth LIBFLUIDSYNTH GLIB)
ardour_use(a-fluidsynth fluidsynth)
