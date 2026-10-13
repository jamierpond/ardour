# libs/fluidsynth/wscript (+ its 'libfluidsynth_includes' generator). -std=gnu99.
file(GLOB _srcs CONFIGURE_DEPENDS src/*.c)
ardour_target(fluidsynth STATIC
        OUTPUT_NAME libfluidsynth
        SOURCES ${_srcs}
        INCLUDES . src/ fluidsynth
        EXPORT_INCLUDES fluidsynth
        USELIB GLIB
        DEFINES HAVE_CONFIG_H "DEFAULT_SOUNDFONT=\"\""
        OPTIONS -fvisibility=hidden -Wno-unused-function)
set_target_properties(fluidsynth PROPERTIES C_STANDARD 99 C_EXTENSIONS ON)
