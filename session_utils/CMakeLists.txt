# session_utils/wscript: ardour<MAJOR>-<util> for each <util>.cc here.
file(GLOB _utils CONFIGURE_DEPENDS RELATIVE "${CMAKE_CURRENT_SOURCE_DIR}" [a-z]*.cc)
list(REMOVE_ITEM _utils example.cc common.cc)
foreach (util IN LISTS _utils)
    string(REPLACE ".cc" "" util "${util}")
    set(t ardour${ARDOUR_VERSION_MAJOR}-${util})
    ardour_target(${t} EXECUTABLE
            SOURCES common.cc ${util}.cc
            INCLUDES . ../libs
            USE pbd ardour ardourcp temporal midipp suil
            USELIB UUID FLAC FONTCONFIG GLIBMM GIOMM GTHREAD OGG CURL DL XML AUDIOUNITS OSX LO FFTW3F
                   TAGLIB LILV RUBBERBAND AUBIO LRDF ARCHIVE VAMPSDK VAMPHOSTSDK USB INTL
            DEFINES "VERSIONSTRING=\"${ARDOUR_VERSION}\"" "UTILNAME=\"${t}\"" "DATA_DIR=\"${ARDOUR_DATADIR}\""
                    "CONFIG_DIR=\"${ARDOUR_SYSCONFDIR}\"" "LOCALEDIR=\"${ARDOUR_LOCALEDIR}\""
                    "PACKAGE=\"ARDOURUTILS\""
            OPTIONS $<$<COMPILE_LANGUAGE:CXX>:-fvisibility=default>)
    if (WIN32)
        target_link_options(${t} PRIVATE -mconsole)
    endif ()
endforeach ()
