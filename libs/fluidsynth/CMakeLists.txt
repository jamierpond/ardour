# Port of libs/fluidsynth/wscript.

ardour_add_library(fluidsynth STATIC OUTPUT_NAME libfluidsynth)

target_sources(fluidsynth PRIVATE
        src/fluid_midi.c
        src/fluid_adsr_env.c
        src/fluid_chorus.c
        src/fluid_iir_filter.c
        src/fluid_lfo.c
        src/fluid_rev.c
        src/fluid_rvoice.c
        src/fluid_rvoice_dsp.c
        src/fluid_rvoice_event.c
        src/fluid_rvoice_mixer.c
        src/fluid_defsfont.c
        src/fluid_chan.c
        src/fluid_event.c
        src/fluid_gen.c
        src/fluid_mod.c
        src/fluid_synth.c
        src/fluid_tuning.c
        src/fluid_voice.c
        src/fluid_conv.c
        src/fluid_hash.c
        src/fluid_list.c
        src/fluid_ringbuffer.c
        src/fluid_samplecache.c
        src/fluid_settings.c
        src/fluid_sffile.c
        src/fluid_sfont.c
        src/fluid_synth_monopoly.c
        src/fluid_sys.c)

# export_includes come from the 'libfluidsynth_includes' task generator, which the
# library itself also uses.
ardour_includes(fluidsynth PRIVATE . src/ PUBLIC fluidsynth)
ardour_uselib(fluidsynth GLIB)
target_compile_definitions(fluidsynth PRIVATE HAVE_CONFIG_H "DEFAULT_SOUNDFONT=\"\"")

# -std=gnu99
set_target_properties(fluidsynth PROPERTIES C_STANDARD 99 C_EXTENSIONS ON)
target_compile_options(fluidsynth PRIVATE -fvisibility=hidden -Wno-unused-function)
