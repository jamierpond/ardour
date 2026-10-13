# libs/ctrl-interface/{control_protocol,midi_surface}/wscript
ardour_target(ardourcp SHARED
        SOURCES control_protocol/basic_ui.cc control_protocol/control_protocol.cc
        INCLUDES control_protocol control_protocol/control_protocol
        EXPORT_INCLUDES control_protocol
        USE ardour pbd
        USELIB GLIBMM SIGCPP XML OSX
        DEFINES LIBCONTROLCP_DLL_EXPORTS "PACKAGE=\"ardour_cp\"")

ardour_target(ardour_midisurface SHARED
        SOURCES midi_surface/midi_surface.cc midi_surface/midi_byte_array.cc
        INCLUDES midi_surface midi_surface/midi_surface
        EXPORT_INCLUDES midi_surface
        USE ardour ardourcp pbd evoral midipp temporal
        USELIB GLIB GLIBMM SIGCPP XML OSX
        DEFINES "PACKAGE=\"ardour_midisurface\"" ARDOURSURFACE_DLL_EXPORTS "VERSIONSTRING=\"${ARDOUR_VERSION}\"")
