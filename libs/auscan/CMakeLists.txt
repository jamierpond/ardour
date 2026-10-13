# Port of libs/auscan/wscript.

if (NOT AUDIOUNIT_SUPPORT)
    return()
endif ()

ardour_add_executable(ardour-au-scanner)
target_sources(ardour-au-scanner PRIVATE au-scanner.cc)
ardour_includes(ardour-au-scanner PRIVATE ../pbd/ ../ardour/ ..)
target_compile_definitions(ardour-au-scanner PRIVATE
        AU_SCANNER_APP
        "VERSIONSTRING=\"${ARDOUR_VERSION}\""
        "PACKAGE=\"ardour${ARDOUR_VERSION_MAJOR}\""
        "LIBARDOUR=\"${ARDOUR_LWRCASE_DIRNAME}\""
        "LOCALEDIR=\"${ARDOUR_LOCALEDIR}\"")
ardour_use(ardour-au-scanner pbd appleutility temporal evoral)
ardour_uselib(ardour-au-scanner GIOMM DL UUID ARCHIVE CURL XML COREAUDIO AUDIOUNITS OSX)
target_compile_options(ardour-au-scanner PRIVATE "$<$<COMPILE_LANGUAGE:CXX>:-Wno-deprecated-declarations>")
