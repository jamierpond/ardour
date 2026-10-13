# Port of libs/surfaces/generic_midi/wscript.

ardour_add_library(ardour_generic_midi SHARED)
target_sources(ardour_generic_midi PRIVATE
        generic_midi_control_protocol.cc
        gmcp_gui.cc
        interface.cc
        midiinvokable.cc
        midicontrollable.cc
        midifunction.cc
        midiaction.cc)
ardour_includes(ardour_generic_midi PUBLIC . PRIVATE ./generic_midi)
ardour_use(ardour_generic_midi ardour ardourcp gtkmm2ext pbd ytkmm)
ardour_uselib(ardour_generic_midi XML OSX GLIBMM GIOMM PANGOMM)
target_compile_definitions(ardour_generic_midi PRIVATE
        "PACKAGE=\"ardour_genericmidi\""
        ARDOURSURFACE_DLL_EXPORTS)
