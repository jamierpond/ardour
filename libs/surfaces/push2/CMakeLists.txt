# Port of libs/surfaces/push2/wscript.

ardour_add_library(ardour_push2 SHARED)
target_sources(ardour_push2 PRIVATE
        push2.cc
        buttons.cc
        canvas.cc
        cues.cc
        interface.cc
        midi_byte_array.cc
        leds.cc
        level_meter.cc
        gui.cc
        knob.cc
        layout.cc
        menu.cc
        mix.cc
        scale.cc
        splash.cc
        track_mix.cc
        utils.cc)
ardour_includes(ardour_push2 PRIVATE . .. ./push2)
ardour_use(ardour_push2 ardour ardourcp ardour_midisurface gtkmm2ext pbd evoral canvas temporal ytkmm)
ardour_uselib(ardour_push2 CAIROMM PANGOMM USB SIGCPP XML OSX GLIBMM GIOMM PANGOCAIRO)
target_compile_definitions(ardour_push2 PRIVATE
        "PACKAGE=\"ardour_push2\""
        ARDOURSURFACE_DLL_EXPORTS
        "VERSIONSTRING=\"${ARDOUR_VERSION}\"")
