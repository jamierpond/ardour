# Port of libs/zita-convolver/wscript.

ardour_add_library(zita-convolver STATIC)

target_sources(zita-convolver PRIVATE zita-convolver.cc)

ardour_includes(zita-convolver PUBLIC .)
ardour_uselib(zita-convolver FFTW3F)
target_compile_options(zita-convolver PRIVATE ${ARDOUR_DSP_OPTIMIZATION})
target_compile_definitions(zita-convolver PRIVATE
        "PACKAGE=\"libzita-convolver\""
        ENABLE_VECTOR_MODE
        _POSIX_PTHREAD_SEMANTICS
        _REENTRANT)
