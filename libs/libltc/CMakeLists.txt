# Port of libs/libltc/wscript.

ardour_add_library(ltc STATIC OUTPUT_NAME libltc)

target_sources(ltc PRIVATE
        ltc.c
        timecode.c
        encoder.c
        decoder.c)

# export_includes come from the 'libltc_includes' task generator, which the
# library itself also uses.
ardour_includes(ltc PRIVATE . PUBLIC ltc)
