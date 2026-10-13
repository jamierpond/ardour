# libs/staffpad/wscript
ardour_target(staffpad STATIC GLOB
        SOURCES pffft/pffft.c
        INCLUDES . pffft
        EXPORT_INCLUDES .
        DEFINES "PACKAGE=\"staffpad\""
        OPTIONS ${ARDOUR_DSP_OPTIMIZATION})
