# Port of libs/surfaces/mackie/wscript.

set(_mackie_sources
        button.cc
        controls.cc
        device_info.cc
        device_profile.cc
        fader.cc
        gui.cc
        jog.cc
        jog_wheel.cc
        led.cc
        mackie_control_protocol.cc
        mcp_buttons.cc
        meter.cc
        midi_byte_array.cc
        pot.cc
        strip.cc
        subview.cc
        surface.cc
        surface_port.cc
        types.cc)

ardour_add_library(ardour_mcp SHARED)
target_sources(ardour_mcp PRIVATE
        ${_mackie_sources}
        interface.cc)
ardour_includes(ardour_mcp PRIVATE .)
ardour_use(ardour_mcp ardour ardourcp gtkmm2ext ytkmm)
ardour_uselib(ardour_mcp XML OSX PANGOMM GLIBMM GIOMM)
target_compile_definitions(ardour_mcp PRIVATE
        "PACKAGE=\"ardour_mackie\""
        ARDOURSURFACE_DLL_EXPORTS)

ardour_add_library(ardour_ssl_uf8 SHARED)
target_sources(ardour_ssl_uf8 PRIVATE
        ${_mackie_sources}
        uf8_interface.cc)
ardour_includes(ardour_ssl_uf8 PRIVATE .)
ardour_use(ardour_ssl_uf8 ardour ardourcp gtkmm2ext ytkmm)
ardour_uselib(ardour_ssl_uf8 XML OSX PANGOMM GLIBMM GIOMM)
target_compile_definitions(ardour_ssl_uf8 PRIVATE
        "PACKAGE=\"ardour_ssl_uf8\""
        ARDOURSURFACE_DLL_EXPORTS
        UF8)
