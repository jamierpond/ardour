# Port of libs/vfork/wscript.

if (WIN32)
    return()
endif ()

ardour_add_executable(ardour-exec-wrapper)
target_sources(ardour-exec-wrapper PRIVATE exec_wrapper.c)
target_compile_definitions(ardour-exec-wrapper PRIVATE
        _POSIX_SOURCE
        _XOPEN_SOURCE=500)
