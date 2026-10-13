# Port of libs/vamp-pyin/wscript.

ardour_add_library(ardourvamppyin SHARED)

target_sources(ardourvamppyin PRIVATE
        libmain.cpp
        PYinVamp.cpp
        YinVamp.cpp
        LocalCandidatePYIN.cpp
        Yin.cpp
        YinUtil.cpp
        MonoNote.cpp
        MonoPitch.cpp
        MonoNoteParameters.cpp
        SparseHMM.cpp
        MonoNoteHMM.cpp
        MonoPitchHMM.cpp)

ardour_includes(ardourvamppyin PUBLIC .)
ardour_uselib(ardourvamppyin VAMPSDK)
# autowaf.ensure_visible_symbols(obj, True)
target_compile_options(ardourvamppyin PRIVATE -fvisibility=default)
