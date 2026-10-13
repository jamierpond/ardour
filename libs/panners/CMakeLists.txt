# libs/panners/*/wscript: one module per panner.
foreach (panner 1in2out:pan1in2out 2in2out:pan2in2out stereobalance:panbalance vbap:panvbap)
    string(REPLACE ":" ";" panner "${panner}")
    list(GET panner 0 dir)
    list(GET panner 1 name)
    file(GLOB _srcs CONFIGURE_DEPENDS ${dir}/*.cc)
    string(REPLACE "pan" "" _short "${name}")
    ardour_target(${name} SHARED
            SOURCES ${_srcs}
            INCLUDES ${dir}
            USE ardour ardourcp pbd
            USELIB GLIBMM XML OSX
            DEFINES "PACKAGE=\"libardour_pan${_short}\"" ARDOURPANNER_DLL_EXPORTS)
    set_target_properties(${name} PROPERTIES LIBRARY_OUTPUT_DIRECTORY ${CMAKE_CURRENT_BINARY_DIR}/${dir}
            RUNTIME_OUTPUT_DIRECTORY ${CMAKE_CURRENT_BINARY_DIR}/${dir})
endforeach ()
