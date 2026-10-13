# Port of libs/vamp-plugins/wscript. libvampplugins-config.h is written by
# FindArdourDeps at the point this wscript's configure() writes it.

ardour_add_library(ardourvampplugins SHARED)

target_sources(ardourvampplugins PRIVATE
        plugins.cpp
        AmplitudeFollower.cpp
        BarBeatTrack.cpp
        BeatTrack.cpp
        ChromagramPlugin.cpp
        EBUr128.cpp
        ebu_r128_proc.cc
        KeyDetect.cpp
        OnsetDetect.cpp
        PercussionOnsetDetector.cpp
        SimilarityPlugin.cpp
        SpectralCentroid.cpp
        TonalChangeDetect.cpp
        Transcription.cpp
        TruePeak.cpp
        ZeroCrossing.cpp)

ardour_includes(ardourvampplugins PUBLIC .)
ardour_uselib(ardourvampplugins FFTW3F VAMPSDK QMDSP)
# obj.use also names 'libvampplugin', a task generator that no longer exists.
ardour_use(ardourvampplugins qm-dsp)
# autowaf.ensure_visible_symbols(obj, True)
target_compile_options(ardourvampplugins PRIVATE -fvisibility=default)

if (TARGET Ardour::AUBIO4)
    target_sources(ardourvampplugins PRIVATE Onset.cpp)
    ardour_uselib(ardourvampplugins AUBIO4)
elseif (TARGET Ardour::AUBIO)
    target_sources(ardourvampplugins PRIVATE Onset.cpp)
    ardour_uselib(ardourvampplugins AUBIO)
endif ()
