# libs/surfaces/*/wscript. Every surface is a module in libs/surfaces/<dir>
# built from its directory's sources (minus EXCLUDE), with PACKAGE and
# ARDOURSURFACE_DLL_EXPORTS defined. wiimote (needs cwiid) and maschine2
# (waf --maschine) are not built, as in a default waf configure.
function(surface name dir package)
    cmake_parse_arguments(S "" "" "EXCLUDE;SOURCES;INCLUDES;USE;USELIB;DEFINES" ${ARGN})
    file(GLOB srcs CONFIGURE_DEPENDS RELATIVE "${CMAKE_CURRENT_SOURCE_DIR}" ${dir}/*.cc)
    foreach (ex IN LISTS S_EXCLUDE)
        list(REMOVE_ITEM srcs ${dir}/${ex})
    endforeach ()
    list(TRANSFORM S_INCLUDES PREPEND ${dir}/)
    ardour_target(${name} SHARED
            SOURCES ${srcs}
            INCLUDES ${S_INCLUDES}
            USE ${S_USE}
            USELIB ${S_USELIB}
            DEFINES "PACKAGE=\"${package}\"" ARDOURSURFACE_DLL_EXPORTS ${S_DEFINES})
    set_target_properties(${name} PROPERTIES LIBRARY_OUTPUT_DIRECTORY ${CMAKE_CURRENT_BINARY_DIR}/${dir}
            RUNTIME_OUTPUT_DIRECTORY ${CMAKE_CURRENT_BINARY_DIR}/${dir})
endfunction()

set(_gui ardour ardourcp gtkmm2ext pbd ytkmm)
set(_midisurface ardour ardourcp ardour_midisurface gtkmm2ext pbd evoral canvas temporal ytkmm)
set(_v "VERSIONSTRING=\"${ARDOUR_VERSION}\"")

surface(ardour_generic_midi generic_midi ardour_genericmidi
        INCLUDES . ./generic_midi USE ${_gui} USELIB XML OSX GLIBMM GIOMM PANGOMM)
target_include_directories(ardour_generic_midi INTERFACE ${CMAKE_CURRENT_SOURCE_DIR}/generic_midi)
surface(ardour_faderport faderport ardour_faderport
        INCLUDES . ./faderport USE ardour ardourcp ardour_midisurface gtkmm2ext pbd ytkmm
        USELIB XML OSX PANGOMM GLIBMM GIOMM)
foreach (fp faderport8 faderport16 faderport2)
    string(REPLACE "faderport" "" n "${fp}")
    set(others faderport8_interface.cc faderport16_interface.cc faderport2_interface.cc)
    list(REMOVE_ITEM others ${fp}_interface.cc)
    surface(ardour_${fp} faderport8 ardour_faderport8 EXCLUDE ${others}
            INCLUDES . USE ${_gui} USELIB XML OSX CAIROMM PANGOMM GLIBMM GIOMM
            DEFINES $<$<NOT:$<STREQUAL:${n},8>>:FADERPORT${n}>)
endforeach ()
surface(ardour_cc121 cc121 ardour_cc121
        INCLUDES . ./cc121 USE ${_gui} USELIB XML OSX GLIBMM GIOMM PANGOMM)
surface(ardour_mcp mackie ardour_mackie EXCLUDE test.cc uf8_interface.cc
        INCLUDES . USE ardour ardourcp gtkmm2ext ytkmm USELIB XML OSX PANGOMM GLIBMM GIOMM)
surface(ardour_ssl_uf8 mackie ardour_ssl_uf8 EXCLUDE test.cc interface.cc
        INCLUDES . USE ardour ardourcp gtkmm2ext ytkmm USELIB XML OSX PANGOMM GLIBMM GIOMM DEFINES UF8)
surface(ardour_us2400 us2400 ardour_us2400 EXCLUDE test.cc us2400_control_protocol_poll.cc
        INCLUDES . USE ardour ardourcp gtkmm2ext ytkmm USELIB XML OSX PANGOMM GLIBMM GIOMM)
surface(ardour_launch_control_xl launch_control_xl ardour_launch_control_xl
        INCLUDES . ./launch_control_xl USE ardour ardourcp pbd evoral canvas temporal ytkmm
        USELIB SIGCPP XML OSX PANGOMM GLIBMM GIOMM DEFINES ${_v})
surface(ardour_osc osc ardour_osc EXCLUDE osc_controllable.cc
        INCLUDES . ./osc USE ${_gui} USELIB LO XML OSX GLIBMM GIOMM PANGOMM)
surface(ardour_console1 console1 ardour_console1
        INCLUDES . ./console1 USE ardour ardourcp ardour_midisurface gtkmm2ext pbd evoral temporal ytkmm
        USELIB SIGCPP XML OSX GLIBMM GIOMM PANGOMM)
surface(ardour_push2 push2 ardour_push2
        INCLUDES . .. ./push2 USE ${_midisurface}
        USELIB CAIROMM PANGOMM USB SIGCPP XML OSX GLIBMM GIOMM PANGOCAIRO DEFINES ${_v})
surface(ardour_contourdesign contourdesign ardour_contourdesign
        INCLUDES . ../libs ../../widgets USE ardour ardourcp gtkmm2ext pbd widgets ytkmm
        USELIB USB XML OSX PANGOMM GLIBMM GIOMM)
surface(ardour_launchpad_pro launchpad_pro ardour_launchpad_pro
        INCLUDES . .. ./launchpad_pro USE ${_midisurface}
        USELIB CAIROMM PANGOMM USB SIGCPP XML OSX GLIBMM GIOMM DEFINES ${_v})
surface(ardour_launchpad_mini launchpad_x ardour_launchpad_mini EXCLUDE launchpad_x_interface.cc
        INCLUDES . USE ${_midisurface} USELIB CAIROMM PANGOMM USB SIGCPP XML OSX GLIBMM GIOMM
        DEFINES LAUNCHPAD_MINI)
surface(ardour_launchpad_x launchpad_x ardour_launchpad_x EXCLUDE launchpad_mini_interface.cc
        INCLUDES . USE ${_midisurface} USELIB CAIROMM PANGOMM USB SIGCPP XML OSX GLIBMM GIOMM)
# (sic: PACKAGE is ardour_launchpad_x in the wscript)
surface(ardour_launchkey_4 launchkey_4 ardour_launchpad_x
        INCLUDES . USE ${_midisurface} USELIB CAIROMM PANGOMM USB SIGCPP XML OSX GLIBMM GIOMM)
surface(ardour_websockets websockets ardour_websockets
        INCLUDES . ./websockets USE ardour ardourcp gtkmm2ext pbd USELIB GLIBMM XML WEBSOCKETS SIGCPP)
# (The wscript's mingw-only _WIN32_WINNT=0x0601 is superseded by the global
# Windows 10 floor, _WIN32_WINNT=0x0A00.)
surface(ardour_mcp_http mcp_http ardour_mcp_http
        INCLUDES . ./mcp_http USE ${_gui} USELIB OSX GLIBMM GIOMM PANGOMM XML WEBSOCKETS)
