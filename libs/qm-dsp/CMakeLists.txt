# libs/qm-dsp/wscript
file(GLOB_RECURSE _srcs CONFIGURE_DEPENDS RELATIVE "${CMAKE_CURRENT_SOURCE_DIR}" base/*.cpp dsp/*.cpp maths/*.cpp maths/*.c)
list(REMOVE_ITEM _srcs dsp/chromagram/CQprecalc.cpp)
ardour_target(qm-dsp STATIC
        SOURCES ${_srcs} ext/kissfft/kiss_fft.c ext/kissfft/tools/kiss_fftr.c
        INCLUDES . ext/kissfft ext/kissfft/tools/
        EXPORT_INCLUDES .
        DEFINES kiss_fft_scalar=double
        OPTIONS -fvisibility=hidden)
