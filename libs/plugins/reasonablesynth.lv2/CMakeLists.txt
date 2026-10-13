# Port of libs/plugins/reasonablesynth.lv2/wscript. lv2.c #includes rsynth.c
# (waf's dep_files); it is listed as a header-only source so edits rebuild.

ardour_add_lv2_bundle(reasonablesynth TTL manifest.ttl reasonablesynth.ttl)
target_sources(reasonablesynth PRIVATE lv2.c rsynth.c)
set_source_files_properties(rsynth.c PROPERTIES HEADER_FILE_ONLY ON)
