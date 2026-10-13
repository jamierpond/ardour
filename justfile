# CMake build shortcuts. See docs/cmake.md. waf (./waf configure && ./waf)
# is unaffected.

build_dir := "build-cmake"
build_type := "Debug"

# Configure (first time only) and build everything.
build:
    @[ -f {{build_dir}}/build.ninja ] || cmake -S . -B {{build_dir}} -G Ninja -DCMAKE_BUILD_TYPE={{build_type}}
    cmake --build {{build_dir}}

# Build, then run Ardour from the build tree (arguments go to Ardour).
run *args: build
    {{build_dir}}/gtk2_ardour/ardev {{args}}
