# libs/libltc/wscript (+ its 'libltc_includes' generator)
ardour_target(ltc STATIC GLOB
        OUTPUT_NAME libltc
        INCLUDES . ltc
        EXPORT_INCLUDES ltc)
