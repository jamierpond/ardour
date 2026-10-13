# Port of libs/midi++2/wscript.

ardour_add_library(midipp SHARED)

target_sources(midipp PRIVATE
        midi.cc
        channel.cc
        ipmidi_port.cc
        parser.cc
        port.cc
        midnam_patch.cc
        mmc.cc
        mtc.cc)

ardour_includes(midipp PUBLIC . PRIVATE ../surfaces/control_protocol ../ardour)
ardour_uselib(midipp GLIBMM SIGCPP XML OSX)
ardour_use(midipp pbd evoral temporal)
target_compile_definitions(midipp PRIVATE LIBMIDIPP_DLL_EXPORTS=1)
