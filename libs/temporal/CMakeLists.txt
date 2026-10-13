# Port of libs/temporal/wscript.

ardour_add_library(temporal SHARED)

target_sources(temporal PRIVATE
        debug.cc
        bbt_time.cc
        beats.cc
        domain.cc
        enums.cc
        range.cc
        superclock.cc
        tempo.cc
        time.cc
        timeline.cc)

ardour_includes(temporal PUBLIC .)
ardour_uselib(temporal GLIBMM XML OSX)
ardour_use(temporal pbd)
target_compile_definitions(temporal PRIVATE
        LIBTEMPORAL_DLL_EXPORTS=1
        "PACKAGE=\"libtemporal\"")
