# headless/wscript: hardour. "this program does not do the whole hidden
# symbols thing" (-fvisibility=default).
ardour_target(hardour EXECUTABLE GLOB
        OUTPUT_NAME hardour-${ARDOUR_VERSION}
        INCLUDES . ../libs
        USE pbd ardour ardourcp temporal midipp suil
        USELIB UUID FLAC FONTCONFIG GLIBMM GIOMM GTHREAD OGG CURL DL XML AUDIOUNITS OSX FFTW3F LO
               TAGLIB LILV RUBBERBAND AUBIO LRDF ARCHIVE VAMPSDK VAMPHOSTSDK USB INTL
        DEFINES "VERSIONSTRING=\"${ARDOUR_VERSION}\"" "DATA_DIR=\"${ARDOUR_DATADIR}\""
                "CONFIG_DIR=\"${ARDOUR_SYSCONFDIR}\"" "LOCALEDIR=\"${ARDOUR_LOCALEDIR}\""
        OPTIONS $<$<COMPILE_LANGUAGE:CXX>:-fvisibility=default>)
if (WIN32)
    target_link_options(hardour PRIVATE $<$<NOT:$<CONFIG:Debug>>:-mwindows>)
endif ()
