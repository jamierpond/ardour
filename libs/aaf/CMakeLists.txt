# Port of libs/aaf/wscript.

ardour_add_library(aaf SHARED)

target_sources(aaf PRIVATE
        AAFClass.c
        AAFCore.c
        AAFDump.c
        AAFIEssenceFile.c
        AAFIface.c
        AAFIParser.c
        AAFToText.c
        CFBDump.c
        LibCFB.c
        ProTools.c
        MediaComposer.c
        Resolve.c
        RIFFParser.c
        URIParser.c
        utils.c
        log.c)

ardour_includes(aaf PUBLIC .)
target_compile_definitions(aaf PRIVATE
        LIBAAF_DLL_EXPORTS=1
        "PACKAGE=\"libaaf\""
        _POSIX_C_SOURCE=200809L
        _XOPEN_SOURCE=500)
