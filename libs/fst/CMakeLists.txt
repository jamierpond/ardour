# libs/fst/wscript: the VST2/VST3 scanners (and vstwin, which libardour links
# on Windows).
set(_common
        "VERSIONSTRING=\"${ARDOUR_VERSION}\"" "PACKAGE=\"ardour${ARDOUR_VERSION_MAJOR}\""
        "LIBARDOUR=\"${ARDOUR_LWRCASE_DIRNAME}\"")
if (WIN32)
    set(_link -mwindows)
endif ()

ardour_target(ardour-vst3-scanner EXECUTABLE
        SOURCES vst3-scanner.cc
        INCLUDES ../pbd/ ../ardour/ ../vst3/ ..
        USE pbd
        USELIB GLIBMM GIOMM DL ARCHIVE CURL XML USB OSX GDI32
        DEFINES VST3_SCANNER_APP ${_common} "LOCALEDIR=\"${ARDOUR_LOCALEDIR}\"")

if (WIN32)
    ardour_target(vstwin OBJECT SOURCES vstwin.c INCLUDES ../pbd/ ../ardour/ . USELIB GIOMM)
    set(_vstwin vstwin)
endif ()
ardour_target(ardour-vst-scanner EXECUTABLE
        SOURCES vst2-scanner.cc
        INCLUDES ../pbd/ ../ardour/ .
        USE pbd temporal evoral ${_vstwin}
        USELIB GLIBMM GIOMM DL GDI32 OSX ARCHIVE CURL XML USB
        DEFINES _POSIX_SOURCE USE_WS_PREFIX VST_SCANNER_APP ${_common})
target_link_options(ardour-vst3-scanner PRIVATE ${_link})
target_link_options(ardour-vst-scanner PRIVATE ${_link})
