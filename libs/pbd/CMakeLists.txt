# Port of libs/pbd/wscript. libpbd-config.h is written by FindArdourDeps at
# the point this wscript's configure() writes it.

ardour_add_library(pbd SHARED)

target_sources(pbd PRIVATE
        basename.cc
        base_ui.cc
        boost_debug.cc
        cartesian.cc
        ccurl.cc
        command.cc
        configuration_variable.cc
        convert.cc
        controllable.cc
        crossthread.cc
        cpus.cc
        debug.cc
        demangle.cc
        downloader.cc
        enumwriter.cc
        event_loop.cc
        enums.cc
        epa.cc
        error.cc
        ffs.cc
        file_archive.cc
        file_utils.cc
        fpu.cc
        glib_event_source.cc
        history_owner.cc
        id.cc
        inflater.cc
        locale_guard.cc
        localtime_r.cc
        malign.cc
        md5.cc
        microseconds.cc
        mountpoint.cc
        mutex.cc
        openuri.cc
        pathexpand.cc
        pbd.cc
        pcg_rand.cc
        pool.cc
        progress.cc
        property_list.cc
        pthread_utils.cc
        reallocpool.cc
        receiver.cc
        resource.cc
        rwlock.cc
        search_path.cc
        semutils.cc
        shortpath.cc
        signals.cc
        spinlock.cc
        stacktrace.cc
        stateful_diff_command.cc
        stateful.cc
        string_convert.cc
        strreplace.cc
        strsplit.cc
        system_exec.cc
        textreceiver.cc
        timer.cc
        timing.cc
        tlsf.cc
        transmitter.cc
        thread_pool.cc
        undo.cc
        utf8_utils.cc
        uuid.cc
        whitespace.cc
        xml++.cc)

if (ARDOUR_RT_ALLOC_DEBUG)
    target_sources(pbd PRIVATE debug_rt_alloc.c)
endif ()

ardour_includes(pbd PUBLIC .)
ardour_uselib(pbd GLIBMM SIGCPP XML UUID SNDFILE GIOMM CURL)
# Deviation: ARCHIVE is PUBLIC. pbd/file_archive.h includes <archive.h> and is
# reached from libardour (via session.h) and everything above it, none of which
# list ARCHIVE. waf builds only get away with that when libarchive's headers
# share a prefix with something else on the include path (Ardour's own stack,
# or a global --also-include); Homebrew's libarchive is keg-only.
ardour_uselib(pbd PUBLIC ARCHIVE)
target_compile_definitions(pbd PRIVATE
        LIBPBD_DLL_EXPORTS=1
        "PACKAGE=\"libpbd4\""
        "VERSIONSTRING=\"${ARDOUR_VERSION}\"")

if (APPLE)
    target_sources(pbd PRIVATE cocoa_open_uri.mm)
    ardour_uselib(pbd OSX)
endif ()

if (CMAKE_SYSTEM_NAME STREQUAL "NetBSD")
    target_link_libraries(pbd PRIVATE execinfo)
endif ()

if (CMAKE_SYSTEM_PROCESSOR STREQUAL "x86_64" AND NOT APPLE)
    target_compile_definitions(pbd PRIVATE USE_X86_64_ASM)
endif ()

if (WIN32)
    target_compile_definitions(pbd PRIVATE NO_POSIX_MEMALIGN)
    target_sources(pbd PRIVATE
            windows_special_dirs.cc
            windows_timer_utils.cc
            windows_mmcss.cc)
    target_link_libraries(pbd PRIVATE ole32)
endif ()
