# Makefile for Ardour development on macOS

.PHONY: configure build run debug check-port sdk rebuild

# XDAW server port
XDAW_PORT := 50051

# Clean PATH excluding broken swiftly toolchain
export PATH := /usr/bin:/bin:/usr/sbin:/sbin:/opt/homebrew/bin
export PKG_CONFIG_PATH := /opt/homebrew/opt/libarchive/lib/pkgconfig:$(PKG_CONFIG_PATH)
export CPATH := /opt/homebrew/include:/opt/homebrew/opt/libarchive/include:/opt/homebrew/opt/fftw/include:/opt/homebrew/opt/jack/include:/opt/homebrew/Cellar/cairo/1.18.4/include/cairo:$(CPATH)
export LIBRARY_PATH := /opt/homebrew/opt/libarchive/lib:/opt/homebrew/opt/fftw/lib:$(LIBRARY_PATH)

# Use Cellar path to avoid lua header conflicts
BOOST_INCLUDE := /opt/homebrew/Cellar/boost/1.90.0/include

# Build the XDAW SDK shared library (what Ardour links against)
sdk:
	@echo "=== Building XDAW SDK ==="
	cd ../.. && bazel build //sdk:libxdaw_shared.dylib

# Rebuild SDK then Ardour (use when SDK changes)
rebuild: sdk configure build

# Check if XDAW port is available
check-port:
	@if lsof -i :$(XDAW_PORT) -sTCP:LISTEN >/dev/null 2>&1; then \
		echo "ERROR: Port $(XDAW_PORT) is already in use!"; \
		echo "Kill the existing process: lsof -ti :$(XDAW_PORT) | xargs kill"; \
		exit 1; \
	fi

# Configure with WAF (run once after clean or when deps change)
configure:
	./waf configure --boost-include=$(BOOST_INCLUDE)

# Build with WAF (auto-configure if needed)
build:
	@if [ ! -f .lock-waf_darwin_build ]; then $(MAKE) configure; fi
	./waf build

# Run from build directory (builds first)
# OS_ACTIVITY_MODE=disable suppresses noisy macOS system log messages (CG warnings, etc)
run: build check-port
	cd gtk2_ardour && OS_ACTIVITY_MODE=disable ./ardev

# Debug from build directory with lldb (builds first, bypass gdb which is broken on ARM)
# OS_ACTIVITY_MODE=disable suppresses noisy macOS system log messages (CG warnings, etc)
debug: build check-port
	@TOP=$$(pwd) && \
	. build/gtk2_ardour/ardev_common_waf.sh && \
	OS_ACTIVITY_MODE=disable lldb -- $$TOP/$$EXECUTABLE
