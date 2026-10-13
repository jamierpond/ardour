# libs/vamp-plugins/wscript (with aubio >= 0.4, so Onset.cpp is in)
ardour_target(ardourvampplugins SHARED GLOB
        INCLUDES .
        EXPORT_INCLUDES .
        USE qm-dsp
        USELIB FFTW3F VAMPSDK QMDSP AUBIO4
        OPTIONS -fvisibility=default)
