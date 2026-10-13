# Port of session_utils/wscript: ardour<MAJOR>-export, -new_session, ...

# "session-utils depend on the dummy backend"
if (NOT "dummy" IN_LIST ARDOUR_BACKENDS)
    return()
endif ()

string(TOLOWER "${ARDOUR_PROGRAM_NAME}" _pgm)
set(_pgmprefix "${_pgm}${ARDOUR_VERSION_MAJOR}")

# bld.path.ant_glob('[a-z]*.cc', excl=['example.cc', 'common.cc'])
file(GLOB _utils CONFIGURE_DEPENDS RELATIVE "${CMAKE_CURRENT_SOURCE_DIR}" "[a-z]*.cc")
list(REMOVE_ITEM _utils example.cc common.cc)

foreach (util_src IN LISTS _utils)
    get_filename_component(util "${util_src}" NAME_WE)
    set(t "${_pgmprefix}-${util}")

    ardour_add_executable(${t})
    target_sources(${t} PRIVATE common.cc ${util_src})
    # "this program does not do the whole hidden symbols thing"
    target_compile_options(${t} PRIVATE "$<$<COMPILE_LANGUAGE:CXX>:-fvisibility=default>")
    ardour_includes(${t} PRIVATE . ../libs)
    ardour_use(${t} pbd ardour ardourcp temporal midipp)
    if (TARGET suil)
        ardour_use(${t} suil)
    endif ()
    target_compile_definitions(${t} PRIVATE
            "VERSIONSTRING=\"${ARDOUR_VERSION}\""
            "UTILNAME=\"${t}\""
            "DATA_DIR=\"${ARDOUR_DATADIR}\""
            "CONFIG_DIR=\"${CMAKE_INSTALL_FULL_SYSCONFDIR}\""
            "LOCALEDIR=\"${ARDOUR_LOCALEDIR}\""
            "PACKAGE=\"ARDOURUTILS\"")
    ardour_uselib(${t}
            UUID FLAC FONTCONFIG GLIBMM GIOMM GTHREAD OGG CURL DL XML
            AUDIOUNITS OSX LO
            FFTW3F LO TAGLIB LILV RUBBERBAND AUBIO LRDF ARCHIVE VAMPSDK VAMPHOSTSDK)
    if (TARGET Ardour::USB)
        ardour_uselib(${t} USB)
    endif ()
    if (NEED_INTL)
        ardour_link_intl(${t})
    endif ()
endforeach ()

if (NOT WIN32)
    set(LIBDIR "${ARDOUR_DLLDIR}")
    set(DATADIR "${ARDOUR_DATADIR}")
    set(CONFDIR "${ARDOUR_CONFDIR}")
    configure_file(ardour-util.sh.in ardour-util.sh @ONLY
            FILE_PERMISSIONS OWNER_READ OWNER_WRITE OWNER_EXECUTE GROUP_READ GROUP_EXECUTE WORLD_READ WORLD_EXECUTE)
endif ()
