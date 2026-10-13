# luasession/wscript: the command-line Lua session tool.
ardour_target(luasession EXECUTABLE GLOB
        OUTPUT_NAME $<IF:$<BOOL:${WIN32}>,ardour${ARDOUR_VERSION_MAJOR}-lua,luasession>
        INCLUDES ../libs
        USE lua pbd ardour ardourcp temporal midipp suil
        USELIB UUID FLAC FONTCONFIG GLIBMM GIOMM GTHREAD OGG CURL DL XML AUDIOUNITS OSX LO READLINE
               FFTW3F TAGLIB LILV RUBBERBAND AUBIO LRDF ARCHIVE VAMPSDK VAMPHOSTSDK USB INTL
        DEFINES "VERSIONSTRING=\"${ARDOUR_VERSION}\"" "DATA_DIR=\"${ARDOUR_DATADIR}\""
                "CONFIG_DIR=\"${ARDOUR_SYSCONFDIR}\"" "LOCALEDIR=\"${ARDOUR_LOCALEDIR}\""
                "PACKAGE=\"ARDOURUTILS\"")
if (WIN32)
    target_link_options(luasession PRIVATE -mconsole)
endif ()
