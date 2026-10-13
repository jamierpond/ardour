# libs/vfork/wscript
ardour_target(ardour-exec-wrapper EXECUTABLE SOURCES exec_wrapper.c DEFINES _POSIX_SOURCE _XOPEN_SOURCE=500)
