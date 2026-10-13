# Port of libs/staffpad/wscript.

ardour_add_library(staffpad STATIC)

target_sources(staffpad PRIVATE
        TimeAndPitch.cpp
        FourierTransform_pffft.cpp
        pffft/pffft.c)

ardour_includes(staffpad PUBLIC . PRIVATE pffft)
target_compile_options(staffpad PRIVATE ${ARDOUR_DSP_OPTIMIZATION})
target_compile_definitions(staffpad PRIVATE "PACKAGE=\"staffpad\"")
