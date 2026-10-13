# Port of libs/evoral/wscript.

# libsmf: a static helper linked into libevoral.
ardour_add_library(smf STATIC)
target_sources(smf PRIVATE
        libsmf/smf.c
        libsmf/smf_decode.c
        libsmf/smf_load.c
        libsmf/smf_save.c
        libsmf/smf_tempo.c)
ardour_includes(smf INTERFACE . PRIVATE ./src)
ardour_uselib(smf GLIB)
ardour_use(smf temporal)
target_compile_definitions(smf PRIVATE
        "SMF_VERSION=\"1.2\""
        LIBSMF_DLL_EXPORTS)

ardour_add_library(evoral SHARED)
target_sources(evoral PRIVATE
        Control.cc
        ControlList.cc
        ControlSet.cc
        Curve.cc
        Event.cc
        Note.cc
        SMF.cc
        Sequence.cc
        debug.cc)
ardour_includes(evoral PUBLIC . PRIVATE ./src)
ardour_uselib(evoral GLIBMM GTHREAD SMF XML LIBPBD OSX)
ardour_use(evoral smf pbd)
target_compile_definitions(evoral PRIVATE
        LIBEVORAL_DLL_EXPORTS
        "PACKAGE=\"libevoral\"")
