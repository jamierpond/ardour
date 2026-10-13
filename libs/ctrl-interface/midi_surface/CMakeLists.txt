# Port of libs/ctrl-interface/midi_surface/wscript.

ardour_add_library(ardour_midisurface SHARED)

target_sources(ardour_midisurface PRIVATE
        midi_surface.cc
        midi_byte_array.cc)

ardour_includes(ardour_midisurface PUBLIC . PRIVATE ./midi_surface)
ardour_uselib(ardour_midisurface GLIB GLIBMM SIGCPP XML OSX)
ardour_use(ardour_midisurface ardour ardourcp pbd evoral midipp temporal)
target_compile_definitions(ardour_midisurface PRIVATE
        "PACKAGE=\"ardour_midisurface\""
        ARDOURSURFACE_DLL_EXPORTS
        "VERSIONSTRING=\"${ARDOUR_VERSION}\"")
