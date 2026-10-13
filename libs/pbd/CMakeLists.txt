# libs/pbd/wscript. crossthread.*.cc are #included by crossthread.cc.
if (APPLE)
    set(_platform cocoa_open_uri.mm)
else ()
    set(_platform windows_special_dirs.cc windows_timer_utils.cc windows_mmcss.cc)
    set(_defines NO_POSIX_MEMALIGN)
endif ()

ardour_target(pbd SHARED GLOB
        EXCLUDE crossthread.posix.cc crossthread.win.cc debug_rt_alloc.c
                windows_special_dirs.cc windows_timer_utils.cc windows_mmcss.cc
        SOURCES ${_platform}
        INCLUDES .
        EXPORT_INCLUDES .
        USELIB GLIBMM SIGCPP XML SNDFILE GIOMM CURL OSX OLE
        DEFINES LIBPBD_DLL_EXPORTS=1 "PACKAGE=\"libpbd4\"" "VERSIONSTRING=\"${ARDOUR_VERSION}\"" ${_defines})

# Deviation: ARCHIVE is PUBLIC. pbd/file_archive.h includes <archive.h> and
# reaches libardour and everything above it, none of which list ARCHIVE; waf
# only gets away with it when libarchive shares a prefix with other headers.
target_link_libraries(pbd PUBLIC Ardour::ARCHIVE)
