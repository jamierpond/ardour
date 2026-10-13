# Port of libs/backends/coreaudio/wscript.

ardour_add_library(coreaudio_backend SHARED)
target_sources(coreaudio_backend PRIVATE
        coreaudio_backend.cc
        coreaudio_pcmio.cc
        coremidi_io.cc)
ardour_includes(coreaudio_backend PRIVATE .)
ardour_use(coreaudio_backend ardour pbd)
ardour_uselib(coreaudio_backend GLIBMM XML OSX)
target_link_libraries(coreaudio_backend PRIVATE
        "-framework CoreAudio"
        "-framework AudioToolbox"
        "-framework CoreServices"
        "-framework CoreMidi")
target_compile_definitions(coreaudio_backend PRIVATE
        "PACKAGE=\"coreaudio-backend\""
        ARDOURBACKEND_DLL_EXPORTS)
