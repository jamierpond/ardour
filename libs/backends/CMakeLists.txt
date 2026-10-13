# libs/backends/*/wscript: dummy everywhere, CoreAudio on macOS, PortAudio on
# Windows (waf's auto-detected set for these platforms, minus JACK).
foreach (backend dummy:dummy_audiobackend coreaudio:coreaudio_backend portaudio:portaudio_callback_backend)
    string(REPLACE ":" ";" backend "${backend}")
    list(GET backend 0 dir)
    list(GET backend 1 name)
    if ((dir STREQUAL "coreaudio" AND NOT APPLE) OR (dir STREQUAL "portaudio" AND NOT WIN32))
        continue()
    endif ()
    file(GLOB _srcs CONFIGURE_DEPENDS ${dir}/*.cc)
    list(FILTER _srcs EXCLUDE REGEX "coreaudio_pcmio_aggregate.cc$")
    ardour_target(${name} SHARED
            SOURCES ${_srcs}
            INCLUDES ${dir}
            USE ardour pbd
            USELIB GLIBMM XML OSX
            DEFINES "PACKAGE=\"${dir}-backend\"" ARDOURBACKEND_DLL_EXPORTS)
    set_target_properties(${name} PROPERTIES LIBRARY_OUTPUT_DIRECTORY ${CMAKE_CURRENT_BINARY_DIR}/${dir}
            RUNTIME_OUTPUT_DIRECTORY ${CMAKE_CURRENT_BINARY_DIR}/${dir})
endforeach ()

target_link_libraries(dummy_audiobackend PRIVATE ltc)
if (APPLE)
    target_link_libraries(coreaudio_backend PRIVATE
            "-framework CoreAudio" "-framework AudioToolbox" "-framework CoreServices" "-framework CoreMidi")
else ()
    target_link_libraries(portaudio_callback_backend PRIVATE Ardour::PORTAUDIO
            portaudio.a ole32 setupapi uuid winmm ksuser jack64)
    target_compile_definitions(portaudio_callback_backend PRIVATE
            USE_MMCSS_THREAD_PRIORITIES "BACKEND_NAME=\"PortAudio (default)\"")
endif ()
