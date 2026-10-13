# Port of libs/qm-dsp/wscript.

ardour_add_library(qm-dsp STATIC)

target_sources(qm-dsp PRIVATE
        base/Pitch.cpp
        base/KaiserWindow.cpp
        base/SincWindow.cpp
        dsp/chromagram/Chromagram.cpp
        dsp/chromagram/ConstantQ.cpp
        dsp/keydetection/GetKeyMode.cpp
        dsp/mfcc/MFCC.cpp
        dsp/onsets/DetectionFunction.cpp
        dsp/onsets/PeakPicking.cpp
        dsp/phasevocoder/PhaseVocoder.cpp
        dsp/rateconversion/Decimator.cpp
        dsp/rateconversion/DecimatorB.cpp
        dsp/rhythm/BeatSpectrum.cpp
        dsp/signalconditioning/DFProcess.cpp
        dsp/signalconditioning/Filter.cpp
        dsp/signalconditioning/FiltFilt.cpp
        dsp/signalconditioning/Framer.cpp
        dsp/tempotracking/DownBeat.cpp
        dsp/tempotracking/TempoTrack.cpp
        dsp/tempotracking/TempoTrackV2.cpp
        dsp/tonal/ChangeDetectionFunction.cpp
        dsp/tonal/TCSgram.cpp
        dsp/tonal/TonalEstimator.cpp
        dsp/transforms/FFT.cpp
        dsp/wavelet/Wavelet.cpp
        maths/Correlation.cpp
        maths/CosineDistance.cpp
        maths/KLDivergence.cpp
        maths/MathUtilities.cpp
        maths/pca/pca.c
        ext/kissfft/kiss_fft.c
        ext/kissfft/tools/kiss_fftr.c)

ardour_includes(qm-dsp PUBLIC . PRIVATE ext/kissfft ext/kissfft/tools/)
target_compile_definitions(qm-dsp PRIVATE kiss_fft_scalar=double)
# autowaf.ensure_visible_symbols(obj, False)
target_compile_options(qm-dsp PRIVATE -fvisibility=hidden)
