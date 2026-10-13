# Port of libs/zita-resampler/wscript.

ardour_add_library(zita-resampler STATIC)

target_sources(zita-resampler PRIVATE
        resampler.cc
        resampler-table.cc
        cresampler.cc
        vresampler.cc
        vmresampler.cc)

ardour_includes(zita-resampler PUBLIC .)
target_compile_options(zita-resampler PRIVATE ${ARDOUR_DSP_OPTIMIZATION})
target_compile_definitions(zita-resampler PRIVATE "PACKAGE=\"libzita-resampler\"")
