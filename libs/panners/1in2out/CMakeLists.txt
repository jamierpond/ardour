# Port of libs/panners/1in2out/wscript.

ardour_add_library(pan1in2out SHARED)
target_sources(pan1in2out PRIVATE
        panner_1in2out.cc)
ardour_includes(pan1in2out PRIVATE .)
ardour_use(pan1in2out ardour ardourcp pbd)
ardour_uselib(pan1in2out GLIBMM XML OSX)
target_compile_definitions(pan1in2out PRIVATE
        "PACKAGE=\"libardour_pan1in2out\""
        ARDOURPANNER_DLL_EXPORTS)
