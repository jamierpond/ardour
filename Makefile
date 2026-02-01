# Makefile for Ardour development

.PHONY: configure build run debug check-port sdk rebuild

# XDAW server port
XDAW_PORT := 50051

# Platform detection
UNAME_S := $(shell uname -s)

ifeq ($(UNAME_S),Darwin)
    # macOS: Clean PATH excluding broken swiftly toolchain
    export PATH := /usr/bin:/bin:/usr/sbin:/sbin:/opt/homebrew/bin
    export PKG_CONFIG_PATH := /opt/homebrew/opt/libarchive/lib/pkgconfig:$(PKG_CONFIG_PATH)
    export CPATH := /opt/homebrew/include:/opt/homebrew/opt/libarchive/include:/opt/homebrew/opt/fftw/include:/opt/homebrew/opt/jack/include:/opt/homebrew/Cellar/cairo/1.18.4/include/cairo:$(CPATH)
    export LIBRARY_PATH := /opt/homebrew/opt/libarchive/lib:/opt/homebrew/opt/fftw/lib:$(LIBRARY_PATH)
    # Use Cellar path to avoid lua header conflicts
    BOOST_INCLUDE := /opt/homebrew/Cellar/boost/1.90.0/include
    WAF_CONFIGURE_FLAGS := --boost-include=$(BOOST_INCLUDE)
    LOCK_FILE := .lock-waf_darwin_build
else
    # Linux: trust the environment (nix, system packages, etc.)
    WAF_CONFIGURE_FLAGS :=
    LOCK_FILE := .lock-waf_linux_build
endif

# SDK library name varies by platform
ifeq ($(UNAME_S),Darwin)
    SDK_LIB := libxdaw_shared.dylib
    DEBUGGER := lldb --
    RUN_ENV := OS_ACTIVITY_MODE=disable
else
    SDK_LIB := libxdaw_shared.so
    DEBUGGER := gdb --args
    RUN_ENV :=
endif

# Build the XDAW SDK shared library (what Ardour links against)
sdk:
	@echo "=== Building XDAW SDK ==="
	cd ../.. && bazel build //sdk:$(SDK_LIB)

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
	./waf configure $(WAF_CONFIGURE_FLAGS)

# Build with WAF (auto-configure if needed)
build:
	@if [ ! -f $(LOCK_FILE) ]; then $(MAKE) configure; fi
	./waf build

# Run from build directory (builds first)
run: build check-port
	cd gtk2_ardour && $(RUN_ENV) ./ardev

# Debug from build directory (builds first)
debug: build check-port
	@TOP=$$(pwd) && \
	. build/gtk2_ardour/ardev_common_waf.sh && \
	$(RUN_ENV) $(DEBUGGER) $$TOP/$$EXECUTABLE
