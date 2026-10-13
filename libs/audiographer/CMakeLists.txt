# Port of libs/audiographer/wscript.

ardour_add_library(audiographer SHARED)

target_sources(audiographer PRIVATE
        private/gdither/gdither.cc
        private/limiter/limiter.cc
        src/general/sndfile.cc
        src/general/sample_format_converter.cc
        src/routines.cc
        src/debug_utils.cc
        src/general/analyser.cc
        src/general/broadcast_info.cc
        src/general/demo_noise.cc
        src/general/loudness_reader.cc
        src/general/limiter.cc
        src/general/normalizer.cc)

if (TARGET Ardour::SAMPLERATE)
    target_sources(audiographer PRIVATE src/general/sr_converter.cc)
endif ()

ardour_includes(audiographer PUBLIC . ./src PRIVATE ../ardour ../temporal ../evoral)
ardour_uselib(audiographer GLIB GLIBMM GTHREAD SAMPLERATE SNDFILE FFTW3F VAMPSDK VAMPHOSTSDK XML)
ardour_use(audiographer pbd)
target_compile_definitions(audiographer PRIVATE LIBAUDIOGRAPHER_DLL_EXPORTS=1)

# bld.env['LIB_FFTW3F'] += ['fftw3f_threads'] when fftw >= 3.3.5. waf mutates
# the shared FFTW3F uselib (task generators are posted after every build()
# has run), so every FFTW3F user links it, not just this library.
if (TARGET Ardour::FFTW35F AND NOT WIN32)
    find_library(ARDOUR_FFTW3F_THREADS fftw3f_threads
            HINTS ${ARDOUR_PKG_FFTW3F_LIBRARY_DIRS} REQUIRED)
    target_link_libraries(ardour-uselib-FFTW3F INTERFACE "${ARDOUR_FFTW3F_THREADS}")
endif ()
