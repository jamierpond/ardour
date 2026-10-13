# Port of libs/ctrl-interface/control_protocol/wscript.

ardour_add_library(ardourcp SHARED)

target_sources(ardourcp PRIVATE
        basic_ui.cc
        control_protocol.cc)

ardour_includes(ardourcp PUBLIC . PRIVATE ./control_protocol)
ardour_use(ardourcp ardour pbd)
ardour_uselib(ardourcp GLIBMM SIGCPP XML OSX)
target_compile_definitions(ardourcp PRIVATE
        LIBCONTROLCP_DLL_EXPORTS
        "PACKAGE=\"ardour_cp\"")
