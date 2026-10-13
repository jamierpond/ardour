# Port of luasession/wscript: the command-line Lua session tool.

if (NOT HAVE_READLINE)
    return()
endif ()

# commandline luasession wrapper script
if (NOT WIN32)
    set(LIBDIR "${ARDOUR_DLLDIR}")
    set(DATADIR "${ARDOUR_DATADIR}")
    set(CONFDIR "${ARDOUR_CONFDIR}")
    configure_file(ardour-lua.sh.in "ardour${ARDOUR_VERSION_MAJOR}-lua" @ONLY
            FILE_PERMISSIONS OWNER_READ OWNER_WRITE OWNER_EXECUTE GROUP_READ GROUP_EXECUTE WORLD_READ WORLD_EXECUTE)
endif ()

ardour_add_executable(luasession)
target_sources(luasession PRIVATE luasession.cc)
ardour_includes(luasession PRIVATE ../libs)
ardour_use(luasession lua pbd ardour ardourcp temporal midipp)
target_compile_definitions(luasession PRIVATE
        "VERSIONSTRING=\"${ARDOUR_VERSION}\""
        "DATA_DIR=\"${ARDOUR_DATADIR}\""
        "CONFIG_DIR=\"${CMAKE_INSTALL_FULL_SYSCONFDIR}\""
        "LOCALEDIR=\"${ARDOUR_LOCALEDIR}\""
        "PACKAGE=\"ARDOURUTILS\"")
ardour_uselib(luasession
        UUID FLAC FONTCONFIG GLIBMM GIOMM GTHREAD OGG CURL DL XML
        AUDIOUNITS OSX LO
        READLINE
        FFTW3F LO TAGLIB LILV RUBBERBAND AUBIO LRDF ARCHIVE VAMPSDK VAMPHOSTSDK)

if (HAVE_SUIL)
    ardour_use(luasession suil)
endif ()
if (TARGET Ardour::USB)
    ardour_uselib(luasession USB)
endif ()
if (NEED_INTL)
    ardour_link_intl(luasession)
endif ()
if (WIN32)
    set_target_properties(luasession PROPERTIES OUTPUT_NAME "ardour${ARDOUR_VERSION_MAJOR}-lua")
endif ()
