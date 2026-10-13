# libs/evoral/wscript: libsmf (static) and libevoral.
file(GLOB _smf CONFIGURE_DEPENDS libsmf/*.c)
list(FILTER _smf EXCLUDE REGEX "smfsh.c$")
ardour_target(smf STATIC
        SOURCES ${_smf}
        INCLUDES ./src
        EXPORT_INCLUDES .
        USE temporal
        USELIB GLIB
        DEFINES "SMF_VERSION=\"1.2\"" LIBSMF_DLL_EXPORTS)

ardour_target(evoral SHARED GLOB
        INCLUDES . ./src
        EXPORT_INCLUDES .
        USE smf pbd
        USELIB GLIBMM GTHREAD XML OSX
        DEFINES LIBEVORAL_DLL_EXPORTS "PACKAGE=\"libevoral\"")
