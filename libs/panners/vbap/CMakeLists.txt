# Port of libs/panners/vbap/wscript.

ardour_add_library(panvbap SHARED)
target_sources(panvbap PRIVATE
        vbap_speakers.cc
        vbap.cc)
ardour_includes(panvbap PRIVATE .)
ardour_use(panvbap ardour ardourcp pbd)
ardour_uselib(panvbap GLIBMM XML OSX)
target_compile_definitions(panvbap PRIVATE
        "PACKAGE=\"libardour_panvbap\""
        ARDOURPANNER_DLL_EXPORTS)
