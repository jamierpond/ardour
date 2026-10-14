# Building Ardour with CMake

The CMake build sits alongside waf and covers macOS 12+ and Windows 10+
(64-bit). Each `CMakeLists.txt` ports the wscript next to it, with the same
sources, defines, include paths and dependencies for those two platforms.
Linux, BSD and the other waf targets stay waf-only. `./waf configure && ./waf`
is unchanged.

Requirements: CMake 3.31+, Ninja, Node (code generators in `scripts/`), and
pkg-config. No Python.

## macOS

```sh
brew install cmake ninja node pkgconf boost glibmm@2.66 cairomm@1.14 pangomm@2.46 \
    libsigc++@2 libsndfile libsamplerate curl libarchive liblo taglib vamp-plugin-sdk \
    rubberband fftw aubio lv2 lilv serd sord sratom libxml2 flac libogg libvorbis \
    pango jpeg-turbo libusb libwebsockets

just build        # configure (first time) + build into build-cmake/
just run          # build, then run Ardour from the build tree
```

Without `just`: `cmake -S . -B build-cmake -G Ninja && cmake --build build-cmake`,
then `build-cmake/gtk2_ardour/ardev`.

`-DCMAKE_BUILD_TYPE=Release` matches `./waf configure --optimize`. The default
(Debug) matches a plain `./waf configure`.

## Windows (MSYS2 UCRT64)

Ardour's dependencies (glibmm-2.4, gtk2-era cairomm/pangomm, lv2/lilv, ...)
exist prebuilt only for MinGW, via MSYS2, so the Windows build uses MSYS2's gcc:

```sh
pacman -S --needed mingw-w64-ucrt-x86_64-{gcc,cmake,ninja,pkgconf,nodejs,boost,glibmm,cairomm,pangomm,libsigc++,libsndfile,libsamplerate,curl,libarchive,liblo,taglib,vamp-plugin-sdk,rubberband,fftw,aubio,lv2,lilv,serd,sord,sratom,libxml2,flac,libogg,libvorbis,pango,libjpeg-turbo,libpng,libusb,libwebsockets,portaudio,gettext,readline}
# in a UCRT64 shell (with core.autocrlf=input so the .in templates stay LF):
cmake -S . -B build-cmake -G Ninja && cmake --build build-cmake -j 8
```

Keep `-j` moderate. On a 64-thread box, full parallelism made gcc fail
random `#include`s with "Invalid argument". That's a Windows filesystem
problem, not a build error, and `-j 8` builds cleanly.

MSVC/clang-cl isn't supported. The wscripts' MSVC path relies on a
dependency stack built with MSVC (glibmm-2.4, sigc++-2, cairomm-1.0 and
pangomm-1.4 among them). vcpkg and the other prebuilt sources ship only
the newer glibmm-2.68/sigc++-3 ABI, so MSVC would need that whole stack
built from source first.

## Layout

- `CMake/Ardour.cmake`: version, global flags, the configure answers (one
  ordered list per platform, which also generates the `lib*-config.h`
  headers) and `ardour_target()`, the one helper every CMakeLists.txt uses.
- `CMake/ArdourDeps.cmake`: one `Ardour::<USELIB>` target per waf uselib.
- `scripts/*.mjs`: the version/revision, the `gtk2ardour-version.h` codename
  (a port of the wscript's `enoify()`), and `ardour.keys` (the `--accelmap`
  mode of `tools/fmt-bindings.py`).
- Outputs mirror waf's `build/` layout under `build-cmake/`.

## Where the CMake build differs from waf

- **Configure probes are fixed answers.** CMake doesn't probe; it encodes
  the answers waf's configure gives on each platform, in waf's order. Every
  optional dependency is required instead, at the highest version any
  wscript asks for. The generated config headers match waf's byte for byte,
  except that two defines are dropped on macOS: `HAVE_X11` (waf only sets it
  because Homebrew happens to have libx11) and `HAVE_CPPUNIT` (tests aren't
  built). Neither is used by any source file.
- **macOS 12.0 deployment target.** waf builds for 11.0. Because of that,
  `MAC_OS_X_VERSION_MAX_ALLOWED` is 120000, not 110000: the SDK rejects a
  maximum below the minimum.
- **Windows:** `_WIN32_WINNT=0x0A00` (Windows 10) is set globally. It
  replaces the websockets surface's `0x0601`.
- **`-std=c++17` everywhere.** waf uses it only on macOS or with `--cxx17`.
  MSYS2's gcc 16 defaults to C++20, which libpbd doesn't compile under.
- **Globbed sources.** Where a wscript lists every file in its directory
  except a few, the CMake target globs the directory and lists those
  exceptions.
- **libpbd links ARCHIVE PUBLIC, and CAIRO adds cairo's `includedir`.**
  Ardour headers include `<archive.h>` and `<cairo/cairo.h>`. waf only finds
  those through a shared prefix on the global include path.
- **`DISABLE_VISIBILITY` on ydk/ytk (macOS).** glib >= 2.76 makes
  `gdkaliasdef.c` emit ELF aliases that Mach-O rejects. Against current
  Homebrew glib, waf needs `CFLAGS=-DDISABLE_VISIBILITY --keepflags` for the
  same reason.
- **Generated sources live in the build tree.** `revision.cc`
  (regenerated every build, like waf does) and `config_text.cc` go into the
  build directory, not the source tree. `config_text.cc` (the About-dialog
  build summary) names the CMake build instead of listing waf's flags.
- **Not ported:** tests, i18n, `install`, packaging, the JACK backend, and
  the opt-in wiimote and maschine2 surfaces.
