# Third-party dependencies. Each waf "uselib" becomes an Ardour::<NAME> target
# that ardour_target(... USELIB <NAME>) links.
#
# The wscripts treat several of these as optional, or check one package at
# several versions (LV2_1_10_0, LV2_1_18_6, ...). Here each is required at the
# highest version any wscript asks for, so every alias answers "yes", matching
# the configure answers in Ardour.cmake.

if (APPLE)
    # Homebrew: its pkgconf (unlike pkg-config 0.29) includes Requires.private
    # cflags, which cairomm needs for cairo-ft.h -> freetype. Its keg-only
    # formulae are not on pkg-config's default path.
    execute_process(COMMAND brew --prefix OUTPUT_VARIABLE _brew OUTPUT_STRIP_TRAILING_WHITESPACE ERROR_QUIET)
    if (_brew)
        set(PKG_CONFIG_EXECUTABLE "${_brew}/bin/pkg-config" CACHE FILEPATH "")
        list(APPEND CMAKE_PREFIX_PATH "${_brew}/opt/curl" "${_brew}/opt/libarchive" "${_brew}/opt/libxml2"
                "${_brew}/opt/libffi" "${_brew}")
    endif ()
endif ()

find_package(PkgConfig REQUIRED)

#   <USELIB> <pkg-config spec> [<alias USELIB>...]
set(_pkgs
        "GLIB        glib-2.0>=2.28"
        "GTHREAD     gthread-2.0>=2.10.1"
        "GOBJECT     gobject-2.0"
        "GMODULE     gmodule-2.0"
        "GIO         gio-2.0>=2.2"
        "GLIBMM      glibmm-2.4>=2.32.0"
        "GIOMM       giomm-2.4>=2.2"
        "SIGCPP      sigc++-2.0>=2.12.1     SIGCPP2_12_1"
        "SNDFILE     sndfile>=1.0.18"
        "SAMPLERATE  samplerate>=0.1.7"
        "CURL        libcurl>=7.55.0"
        "ARCHIVE     libarchive>=3.0.0"
        "LO          liblo>=0.26"
        "TAGLIB      taglib>=1.9"
        "VAMPSDK     vamp-sdk>=2.1"
        "VAMPHOSTSDK vamp-hostsdk>=2.1"
        "RUBBERBAND  rubberband"
        "USB         libusb-1.0>=1.0.16"
        "FFTW3F      fftw3f>=3.3.5          FFTW35F"
        "AUBIO       aubio>=0.4.0           AUBIO4"
        "LIBPNG      libpng"
        "PANGO       pango>=1.20"
        "CAIRO       cairo>=1.12.0"
        "PANGOCAIRO  pangocairo"
        "PANGOFT2    pangoft2>=1.36.8"
        "FONTCONFIG  fontconfig"
        "CAIROMM     cairomm-1.0>=1.8.4"
        "PANGOMM     pangomm-1.4>=1.4"
        "XML         libxml-2.0"
        "LV2         lv2>=1.18.6            LV2_1_0_0 LV2_1_10_0 LV2_1_16_0 LV2_1_17_2 LV2_1_18_6"
        "SERD        serd-0>=0.14.0"
        "SORD        sord-0>=0.8.0"
        "SRATOM      sratom-0>=0.2.0"
        "LILV        lilv-0>=0.24.2"
        "OGG         ogg>=1.1.2"
        "FLAC        flac>=1.2.1"
        "WEBSOCKETS  libwebsockets>=2.0.0")
if (WIN32)
    list(APPEND _pkgs
            "GIO-WINDOWS gio-windows-2.0"
            "PORTAUDIO   portaudio-2.0>=19")
endif ()

foreach (entry IN LISTS _pkgs)
    string(REGEX REPLACE " +" ";" entry "${entry}")
    list(POP_FRONT entry uselib spec)
    pkg_check_modules(PKG_${uselib} REQUIRED QUIET IMPORTED_TARGET GLOBAL "${spec}")
    foreach (name ${uselib} ${entry})
        add_library(Ardour::${name} ALIAS PkgConfig::PKG_${uselib})
    endforeach ()
endforeach ()

# libs/audiographer: LIB_FFTW3F += fftw3f_threads (fftw >= 3.3.5, not Windows).
# waf mutates the shared uselib, so every FFTW3F user links it.
if (NOT WIN32)
    find_library(_fftw3f_threads fftw3f_threads HINTS ${PKG_FFTW3F_LIBRARY_DIRS} REQUIRED)
    set_property(TARGET PkgConfig::PKG_FFTW3F APPEND PROPERTY INTERFACE_LINK_LIBRARIES "${_fftw3f_threads}")
endif ()

# Deviation: the LV2 plugins include <cairo/cairo.h>, but pkg-config's cflags
# point inside include/cairo; waf only finds it through a shared prefix on the
# global include path.
set_property(TARGET PkgConfig::PKG_CAIRO APPEND PROPERTY INTERFACE_INCLUDE_DIRECTORIES "${PKG_CAIRO_INCLUDEDIR}")

# Boost (headers only): waf passes --boost-include to every C++ compile.
find_package(Boost 1.68 CONFIG REQUIRED COMPONENTS headers)
get_target_property(_boost_inc Boost::headers INTERFACE_INCLUDE_DIRECTORIES)
target_include_directories(ardour-flags SYSTEM INTERFACE "$<$<COMPILE_LANGUAGE:CXX,OBJCXX>:${_boost_inc}>")

find_package(JPEG REQUIRED)
add_library(Ardour::LIBJPEG ALIAS JPEG::JPEG)

find_path(_readline_inc readline/readline.h REQUIRED)
find_library(_readline_lib readline REQUIRED)
add_library(ardour-readline INTERFACE)
target_include_directories(ardour-readline INTERFACE "${_readline_inc}")
target_link_libraries(ardour-readline INTERFACE "${_readline_lib}")
add_library(Ardour::READLINE ALIAS ardour-readline)

if (APPLE)
    # DL: check_cc(lib='dl'). The wscript skips it for mingw.
    add_library(ardour-dl INTERFACE)
    target_link_libraries(ardour-dl INTERFACE dl)
    add_library(Ardour::DL ALIAS ardour-dl)

    # NEED_INTL: the macOS targets link -lintl explicitly.
    find_package(Intl REQUIRED)
    add_library(Ardour::INTL ALIAS Intl::Intl)

    # LINKFLAGS_OSX / CXXFLAGS_OSX. -undefined dynamic_lookup and
    # -flat_namespace matter at run time: surfaces, panners and backends
    # resolve symbols against the libardour already loaded.
    add_library(ardour-osx INTERFACE)
    target_compile_options(ardour-osx INTERFACE "$<$<COMPILE_LANGUAGE:CXX,OBJCXX>:-F/Library/Frameworks>")
    target_link_libraries(ardour-osx INTERFACE
            "-framework AppKit" "-framework CoreAudio" "-framework CoreAudioKit"
            "-framework CoreFoundation" "-framework CoreServices" "-framework Accelerate")
    target_link_options(ardour-osx INTERFACE "SHELL:-undefined dynamic_lookup" -flat_namespace)
    add_library(Ardour::OSX ALIAS ardour-osx)

    add_library(ardour-audiounits INTERFACE)
    target_compile_definitions(ardour-audiounits INTERFACE "$<$<COMPILE_LANGUAGE:CXX,OBJCXX>:AUDIOUNIT_SUPPORT>")
    target_link_libraries(ardour-audiounits INTERFACE
            "-framework AudioToolbox" "-framework AudioUnit" "-framework Cocoa")
    add_library(Ardour::AUDIOUNITS ALIAS ardour-audiounits)
else ()
    foreach (lib OLE:ole32 GDI32:gdi32 SETUPAPI:setupapi)
        string(REPLACE ":" ";" lib "${lib}")
        list(GET lib 0 uselib)
        list(GET lib 1 name)
        add_library(ardour-${name} INTERFACE)
        target_link_libraries(ardour-${name} INTERFACE ${name})
        add_library(Ardour::${uselib} ALIAS ardour-${name})
    endforeach ()
endif ()
