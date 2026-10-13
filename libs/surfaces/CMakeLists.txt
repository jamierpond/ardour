# Port of libs/surfaces/wscript.

add_subdirectory(generic_midi)
add_subdirectory(faderport)
add_subdirectory(faderport8)
add_subdirectory(cc121)
add_subdirectory(mackie)
add_subdirectory(us2400)
add_subdirectory(launch_control_xl)
add_subdirectory(osc)
add_subdirectory(console1)

if (BUILD_WIIMOTE)
    add_subdirectory(wiimote)
endif ()

if (TARGET Ardour::USB)
    add_subdirectory(push2)
    add_subdirectory(contourdesign)
    add_subdirectory(launchpad_pro)
    add_subdirectory(launchpad_x)
    add_subdirectory(launchkey_4)
else ()
    message(STATUS "You are missing the libusb-1.0 development package needed to compile Push2 and ContourDesign support")
endif ()

if (BUILD_MASCHINE)
    add_subdirectory(maschine2)
endif ()

if (TARGET Ardour::WEBSOCKETS)
    add_subdirectory(websockets)
    add_subdirectory(mcp_http)
endif ()
