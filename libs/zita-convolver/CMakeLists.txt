# libs/zita-convolver/wscript
ardour_target(zita-convolver STATIC GLOB
        INCLUDES .
        EXPORT_INCLUDES .
        USELIB FFTW3F
        DEFINES "PACKAGE=\"libzita-convolver\"" ENABLE_VECTOR_MODE _POSIX_PTHREAD_SEMANTICS _REENTRANT
        OPTIONS ${ARDOUR_DSP_OPTIMIZATION})
