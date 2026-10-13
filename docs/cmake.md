# Building Ardour with CMake

The CMake build sits alongside waf. The wscripts stay the reference: every
`CMakeLists.txt` is a port of the wscript in the same directory, with the same
sources, defines, include paths and dependencies. `./waf configure && ./waf`
works exactly as before.

## Quick start (macOS, Homebrew)

```sh
brew install cmake ninja pkgconf boost glibmm@2.66 cairomm@1.14 pangomm@2.46 \
    libsigc++@2 libsndfile libsamplerate curl libarchive liblo taglib \
    vamp-plugin-sdk rubberband fftw aubio lv2 lilv serd sord sratom libxml2 \
    flac libogg libvorbis pango jpeg-turbo libusb libwebsockets cppunit

just build        # cmake -S . -B build-cmake -G Ninja && cmake --build build-cmake
just run          # build, then start Ardour from the build tree
```

Without `just`:

```sh
cmake -S . -B build-cmake -G Ninja            # Debug, like a plain ./waf configure
cmake --build build-cmake
build-cmake/gtk2_ardour/ardev                 # run from the build tree
```

Homebrew is found automatically, including the keg-only formulae Ardour needs
(curl, libarchive, libxml2). To use a private dependency stack instead (e.g.
Ardour's own `~/gtk/inst`), pass `-DARDOUR_DEPSTACK_ROOT=~/gtk/inst`. Any other
prefix can go on `CMAKE_PREFIX_PATH`.

## Build types

| CMake                            | waf                                  |
|----------------------------------|--------------------------------------|
| `-DCMAKE_BUILD_TYPE=Debug` (default) | `./waf configure`                |
| `-DCMAKE_BUILD_TYPE=Release`     | `./waf configure --optimize`         |
| `-DCMAKE_BUILD_TYPE=RelWithDebInfo` | `./waf configure --optimize --debug-symbols` |

CMake's own per-config flags are cleared, so the only optimisation and debug
flags are the ones ported from the root wscript's flag tables.

## Options

Options carry the `ARDOUR_` prefix and map to waf options:

| CMake option | waf option | default |
|---|---|---|
| `ARDOUR_PROGRAM_NAME` | `--program-name` | `Ardour` |
| `ARDOUR_BACKENDS` | `--with-backends` | auto: dummy, coreaudio (macOS), jack if found |
| `ARDOUR_NLS` | `--no-nls` | ON |
| `ARDOUR_PHONE_HOME` | `--no-phone-home` | ON |
| `ARDOUR_VST3` | `--no-vst3` | ON |
| `ARDOUR_LXVST` | `--no-lxvst` | ON (Linux only) |
| `ARDOUR_PTFORMAT` | `--ptformat` | OFF |
| `ARDOUR_THREADED_WAVEVIEWS` | `--no-threaded-waveviews` | ON |
| `ARDOUR_EXPORTS_HIDDEN` | `--exports-hidden` | OFF |
| `ARDOUR_FPU_OPTIMIZATION` | `--no-fpu-optimization` | ON |
| `ARDOUR_GTK_DEBUG` | `--gtk-debug` | OFF |
| `ARDOUR_ADDRESS_SANITIZER` / `ARDOUR_THREAD_SANITIZER` | `--address-sanitizer` / `--thread-sanitizer` | OFF |
| `ARDOUR_RT_ALLOC_DEBUG` | `--rt-alloc-debug` | OFF |
| `ARDOUR_DENORMAL_EXCEPTION` | `--denormal-exception` | OFF |
| `ARDOUR_MASCHINE` | `--maschine` | OFF |
| `ARDOUR_DEPSTACK_ROOT` | `--depstack-root` | empty |
| `ARDOUR_LV2DIR` | `--lv2dir` | `<libdir>/ardour<MAJOR>/LV2` |

## Layout

- `CMake/` holds the shared modules:
  - `ArdourVersion`: version from `git describe`
  - `ArdourDepStack`: where the dependencies are searched for
  - `ArdourCompilerFlags`: the root wscript's global flags, on one INTERFACE target
  - `ArdourConfig`: `conf.define()` and the generated `lib*-config.h` headers
  - `FindArdourDeps`: every configure check, in wscript order, one `Ardour::<USELIB>` target per waf uselib
  - `ArdourTargets`: helpers that map `use`, `uselib`, `includes` and `export_includes`
  - `ArdourConfigText`: `libs/ardour/config_text.cc`
  - `ArdourGtkResources`: menus, key bindings, rc files and the `ardev` launcher
  - `ArdourLV2`: the bundled LV2 plugin bundles
- `scripts/` holds the Python helpers CMake runs (version and revision, the
  `gtk2ardour-version.h` codename), plus `compare-compile-commands.py`.
- Build outputs land where waf puts them, mirrored under the build directory:
  `build-cmake/libs/pbd/libpbd.dylib`, `build-cmake/gtk2_ardour/ardour-<version>`,
  `build-cmake/libs/LV2/<bundle>/`, and so on.

## Checking parity with waf

Both builds write `compile_commands.json`. The script below diffs every file's
defines, in-tree include paths and flags, grouped by directory:

```sh
./waf configure --compile-database && ./waf
cmake -S . -B build-cmake && cmake --build build-cmake
scripts/compare-compile-commands.py build/compile_commands.json build-cmake/compile_commands.json
```

The generated config headers (`libpbd-config.h`, `libardour-config.h`,
`gtk2ardour-config.h`, `libvampplugins-config.h`, `gtk2ardour-version.h`) and
the generated run-time files (`ardour.menus`, `ardour.keys`, `clearlooks.rc`,
`default_ui_config`, the LV2 `.ttl` files) are byte-identical to waf's.

## Where the CMake build differs from waf

Each of these is also explained in a comment where it happens.

- **Target order.** waf resolves `use` lazily, so its `children` order is not
  a dependency order. CMake adds directories in dependency order. The
  configure checks still run in waf's order, because the config headers
  record that order.
- **Generated sources stay in the build tree.** `libs/ardour/revision.cc` is
  regenerated on every build, like waf does, and `config_text.cc` at
  configure time. Both go into the build directory, not the source tree.
- **`config_text.cc`** has the same titles. Its last three lines name the CMake
  build type and compilers instead of waf's raw flag lists.
- **`ARCHIVE` is PUBLIC on libpbd.** `pbd/file_archive.h` includes
  `<archive.h>` and reaches libardour and everything above it, none of which
  list ARCHIVE. waf only builds against Homebrew with an extra
  `--also-include`. As a side effect, libardour links libarchive directly.
- **The CAIRO uselib adds cairo's `includedir`.** The LV2 plugins include
  `<cairo/cairo.h>`, which waf only finds through a shared prefix on the
  global include path.
- **`DISABLE_VISIBILITY` on ydk/ytk (macOS).** glib >= 2.76 defines
  `G_HAVE_GNUC_VISIBILITY` everywhere, so the generated alias tables emit ELF
  aliases that Mach-O rejects. Against current Homebrew glib, waf needs
  `CFLAGS=-DDISABLE_VISIBILITY --keepflags` for the same reason.
- **Uselib scope.** waf uselibs are per-target and not transitive. They map to
  PRIVATE links, except the two above. Ardour's own shared libraries are
  linked PUBLIC, which matches waf's transitive `use`. Static helpers are
  linked privately and only re-export their include dirs, also like waf.
- **No dylib versioning.** waf ignores `vnum` on macOS, so neither build sets
  VERSION/SOVERSION. Install names are CMake's `@rpath` default rather than
  waf's absolute build path.
- **`ardev`** is generated into `build-cmake/gtk2_ardour/ardev`, with the
  `$TOP/build` paths in `ardev_common.sh.in` pointed at the CMake build
  directory. `gtk2_ardour/ardev` itself only knows waf's `build/`.
- **suil's Cocoa module** gets `-fPIC` from CMake, while waf compiles it
  without. On arm64 macOS all code is PIC anyway.

## Not ported yet

- MSVC and the `--dist-target=mingw` cross build. The flag tables are only
  ported for clang/gcc. See the Windows notes below.
- `--internal-static-libs`, unit tests (`--test`), `--freedesktop`, i18n
  (`.mo`) targets, `install` of the data files, and the macOS bundle/packaging
  in `tools/osx_packaging`.
- The jack, alsa, pulseaudio and portaudio backends (`ARDOUR_BACKENDS` fails
  loudly if asked for one).
