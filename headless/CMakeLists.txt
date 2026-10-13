# Port of headless/wscript: hardour, the GUI-less Ardour.

ardour_add_executable(hardour OUTPUT_NAME "hardour-${ARDOUR_VERSION}")
target_sources(hardour PRIVATE
        load_session.cc
        misc.cc)

# "this program does not do the whole hidden symbols thing"
target_compile_options(hardour PRIVATE "$<$<COMPILE_LANGUAGE:CXX>:-fvisibility=default>")
ardour_includes(hardour PRIVATE . ../libs)
ardour_use(hardour pbd ardour ardourcp temporal midipp)
target_compile_definitions(hardour PRIVATE
        "VERSIONSTRING=\"${ARDOUR_VERSION}\""
        "DATA_DIR=\"${ARDOUR_DATADIR}\""
        "CONFIG_DIR=\"${CMAKE_INSTALL_FULL_SYSCONFDIR}\""
        "LOCALEDIR=\"${ARDOUR_LOCALEDIR}\"")
ardour_uselib(hardour
        UUID FLAC FONTCONFIG GLIBMM GIOMM GTHREAD OGG CURL DL XML
        AUDIOUNITS OSX
        FFTW3F LO TAGLIB LILV RUBBERBAND AUBIO LRDF ARCHIVE VAMPSDK VAMPHOSTSDK)

if (HAVE_SUIL)
    ardour_use(hardour suil)
endif ()
if (TARGET Ardour::USB)
    ardour_uselib(hardour USB)
endif ()
# "obj.use += ' libappleutility'" on a list appends characters: a no-op in
# waf; libappleutility is linked through libardour either way.
if (NEED_INTL)
    ardour_link_intl(hardour)
endif ()
