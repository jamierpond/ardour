# libs/clearlooks-newer/wscript
ardour_target(clearlooks SHARED GLOB
        EXCLUDE bits.c
        INCLUDES .
        USE ztk ytk ydk-pixbuf
        USELIB CAIRO PANGO
        OPTIONS -fvisibility=default)

# "make a symlink to the .dylib that meets GTK's criteria for finding it
# (namely that the library must be a *.so and that it must reside in a
# directory called `engines')" -- for running from the build tree.
if (APPLE)
    add_custom_command(TARGET clearlooks POST_BUILD
            COMMAND ${CMAKE_COMMAND} -E make_directory engines
            COMMAND ${CMAKE_COMMAND} -E create_symlink ../$<TARGET_FILE_NAME:clearlooks> engines/libclearlooks.so
            WORKING_DIRECTORY "${CMAKE_CURRENT_BINARY_DIR}")
endif ()
