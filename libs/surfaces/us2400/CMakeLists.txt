# Port of libs/surfaces/us2400/wscript.

ardour_add_library(ardour_us2400 SHARED)
target_sources(ardour_us2400 PRIVATE
        button.cc
        controls.cc
        device_info.cc
        device_profile.cc
        fader.cc
        gui.cc
        interface.cc
        jog.cc
        jog_wheel.cc
        led.cc
        us2400_control_protocol.cc
        mcp_buttons.cc
        meter.cc
        midi_byte_array.cc
        pot.cc
        strip.cc
        surface.cc
        surface_port.cc
        types.cc)
ardour_includes(ardour_us2400 PRIVATE .)
ardour_use(ardour_us2400 ardour ardourcp gtkmm2ext ytkmm)
ardour_uselib(ardour_us2400 XML OSX PANGOMM GLIBMM GIOMM)
target_compile_definitions(ardour_us2400 PRIVATE
        "PACKAGE=\"ardour_us2400\""
        ARDOURSURFACE_DLL_EXPORTS)
