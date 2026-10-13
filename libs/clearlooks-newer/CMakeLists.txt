# Port of libs/clearlooks-newer/wscript.

ardour_add_library(clearlooks SHARED)

target_sources(clearlooks PRIVATE
        animation.c
        cairo-support.c
        clearlooks_draw.c
        clearlooks_rc_style.c
        clearlooks_style.c
        clearlooks_theme_main.c
        support.c
        widget-information.c)

ardour_includes(clearlooks PRIVATE .)
ardour_use(clearlooks ztk ytk ydk-pixbuf)
ardour_uselib(clearlooks CAIRO PANGO)
# autowaf.ensure_visible_symbols(obj, True)
target_compile_options(clearlooks PRIVATE -fvisibility=default)

# "make a symlink to the .dylib that meets GTK's criteria for finding it
# (namely that the library must be a *.so and that it must reside in a
# directory called `engines')" -- ardev points GTK_PATH here.
if (NOT WIN32)
    add_custom_command(TARGET clearlooks POST_BUILD
            COMMAND "${CMAKE_COMMAND}" -E make_directory engines
            COMMAND "${CMAKE_COMMAND}" -E create_symlink
                    "../$<TARGET_FILE_NAME:clearlooks>" engines/libclearlooks.so
            WORKING_DIRECTORY "${CMAKE_CURRENT_BINARY_DIR}"
            VERBATIM)
endif ()
