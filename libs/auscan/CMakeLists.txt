# libs/auscan/wscript
ardour_target(ardour-au-scanner EXECUTABLE
        SOURCES au-scanner.cc
        INCLUDES ../pbd/ ../ardour/ ..
        USE pbd appleutility temporal evoral
        USELIB GIOMM DL ARCHIVE CURL XML AUDIOUNITS OSX
        DEFINES AU_SCANNER_APP "VERSIONSTRING=\"${ARDOUR_VERSION}\"" "PACKAGE=\"ardour${ARDOUR_VERSION_MAJOR}\""
                "LIBARDOUR=\"${ARDOUR_LWRCASE_DIRNAME}\"" "LOCALEDIR=\"${ARDOUR_LOCALEDIR}\""
        OPTIONS $<$<COMPILE_LANGUAGE:CXX>:-Wno-deprecated-declarations>)
