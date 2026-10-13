# Port of libs/surfaces/mcp_http/wscript.

ardour_add_library(ardour_mcp_http SHARED)
target_sources(ardour_mcp_http PRIVATE
        interface.cc
        mcp_http.cc
        mcp_http_gui.cc
        mcp_http_server.cc)
ardour_includes(ardour_mcp_http PRIVATE . ./mcp_http)
ardour_use(ardour_mcp_http ardour ardourcp gtkmm2ext pbd ytkmm)
ardour_uselib(ardour_mcp_http OSX GLIBMM GIOMM PANGOMM XML WEBSOCKETS OPENSSL)
target_compile_definitions(ardour_mcp_http PRIVATE
        "PACKAGE=\"ardour_mcp_http\""
        ARDOURSURFACE_DLL_EXPORTS)
