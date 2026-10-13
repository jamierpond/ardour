# Port of libs/panners/2in2out/wscript.

ardour_add_library(pan2in2out SHARED)
target_sources(pan2in2out PRIVATE
        panner_2in2out.cc)
ardour_includes(pan2in2out PRIVATE .)
ardour_use(pan2in2out ardour ardourcp pbd)
ardour_uselib(pan2in2out GLIBMM XML OSX)
target_compile_definitions(pan2in2out PRIVATE
        "PACKAGE=\"libardour_pan2in2out\""
        ARDOURPANNER_DLL_EXPORTS)
