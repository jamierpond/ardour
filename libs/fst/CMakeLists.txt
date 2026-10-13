# Port of libs/fst/wscript: the VST2/VST3 plugin scanner executables.

if (VST3_SUPPORT)
    ardour_add_executable(ardour-vst3-scanner)
    target_sources(ardour-vst3-scanner PRIVATE vst3-scanner.cc)
    ardour_includes(ardour-vst3-scanner PRIVATE ../pbd/ ../ardour/ ../vst3/ ..)
    target_compile_definitions(ardour-vst3-scanner PRIVATE
            VST3_SCANNER_APP
            "VERSIONSTRING=\"${ARDOUR_VERSION}\""
            "PACKAGE=\"ardour${ARDOUR_VERSION_MAJOR}\""
            "LIBARDOUR=\"${ARDOUR_LWRCASE_DIRNAME}\""
            "LOCALEDIR=\"${ARDOUR_LOCALEDIR}\"")
    ardour_use(ardour-vst3-scanner pbd)
    ardour_uselib(ardour-vst3-scanner GLIBMM GIOMM DL UUID ARCHIVE CURL XML)
    if (TARGET Ardour::USB)
        ardour_uselib(ardour-vst3-scanner USB)
    endif ()
    if (APPLE)
        ardour_uselib(ardour-vst3-scanner OSX)
    endif ()
    if (CMAKE_SYSTEM_NAME MATCHES "BSD")
        target_compile_definitions(ardour-vst3-scanner PRIVATE _POSIX_C_SOURCE=200809L _XOPEN_SOURCE=700)
    endif ()
endif ()

if (WINDOWS_VST_SUPPORT OR LXVST_SUPPORT OR MACVST_SUPPORT)
    ardour_add_executable(ardour-vst-scanner)
    target_sources(ardour-vst-scanner PRIVATE vst2-scanner.cc)
    ardour_includes(ardour-vst-scanner PRIVATE ../pbd/ ../ardour/ .)
    target_compile_definitions(ardour-vst-scanner PRIVATE
            _POSIX_SOURCE
            USE_WS_PREFIX
            VST_SCANNER_APP
            "PACKAGE=\"ardour${ARDOUR_VERSION_MAJOR}\""
            "LIBARDOUR=\"${ARDOUR_LWRCASE_DIRNAME}\""
            "VERSIONSTRING=\"${ARDOUR_VERSION}\"")
    ardour_use(ardour-vst-scanner pbd temporal evoral)
    ardour_uselib(ardour-vst-scanner GLIBMM GIOMM DL OSX ARCHIVE CURL XML)
    if (TARGET Ardour::USB)
        ardour_uselib(ardour-vst-scanner USB)
    endif ()
    if (CMAKE_SYSTEM_NAME MATCHES "BSD")
        target_compile_definitions(ardour-vst-scanner PRIVATE _POSIX_C_SOURCE=200809 _XOPEN_SOURCE=700)
    endif ()
endif ()
