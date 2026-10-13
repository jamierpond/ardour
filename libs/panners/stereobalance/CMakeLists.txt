# Port of libs/panners/stereobalance/wscript.

ardour_add_library(panbalance SHARED)
target_sources(panbalance PRIVATE
        panner_balance.cc)
ardour_includes(panbalance PRIVATE .)
ardour_use(panbalance ardour ardourcp pbd)
ardour_uselib(panbalance GLIBMM XML OSX)
target_compile_definitions(panbalance PRIVATE
        "PACKAGE=\"libardour_panbalance\""
        ARDOURPANNER_DLL_EXPORTS)
