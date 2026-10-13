# libs/audiographer/wscript
ardour_target(audiographer SHARED
        SOURCES private/gdither/gdither.cc private/limiter/limiter.cc
                src/general/sndfile.cc src/general/sample_format_converter.cc src/routines.cc
                src/debug_utils.cc src/general/analyser.cc src/general/broadcast_info.cc
                src/general/demo_noise.cc src/general/loudness_reader.cc src/general/limiter.cc
                src/general/normalizer.cc src/general/sr_converter.cc
        INCLUDES . ./src ../ardour ../temporal ../evoral
        EXPORT_INCLUDES . ./src
        USE pbd
        USELIB GLIB GLIBMM GTHREAD SAMPLERATE SNDFILE FFTW3F VAMPSDK VAMPHOSTSDK XML
        DEFINES LIBAUDIOGRAPHER_DLL_EXPORTS=1)
