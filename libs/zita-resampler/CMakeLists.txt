# libs/zita-resampler/wscript
ardour_target(zita-resampler STATIC GLOB
        INCLUDES .
        EXPORT_INCLUDES .
        DEFINES "PACKAGE=\"libzita-resampler\""
        OPTIONS ${ARDOUR_DSP_OPTIMIZATION})
