# Port of libs/surfaces/websockets/wscript.

ardour_add_library(ardour_websockets SHARED)
target_sources(ardour_websockets PRIVATE
        interface.cc
        ardour_websockets.cc
        typed_value.cc
        state.cc
        message.cc
        client.cc
        component.cc
        mixer.cc
        transport.cc
        server.cc
        feedback.cc
        dispatcher.cc
        manifest.cc
        resources.cc
        json.cc)
ardour_includes(ardour_websockets PRIVATE . ./websockets)
ardour_use(ardour_websockets ardour ardourcp gtkmm2ext pbd)
ardour_uselib(ardour_websockets GLIBMM XML WEBSOCKETS OPENSSL SIGCPP)
target_compile_definitions(ardour_websockets PRIVATE
        "PACKAGE=\"ardour_websockets\""
        ARDOURSURFACE_DLL_EXPORTS)
