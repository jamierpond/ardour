# Ardour XDAW Example

## Building

**NEVER run `./waf` directly. ALWAYS use the Makefile.**

```bash
cd examples/ardour
make build
```

The Makefile sets up the correct environment (PKG_CONFIG_PATH, etc.) that waf needs.

## Running

```bash
make run
```

## Available Targets

| Target | Description |
|--------|-------------|
| `make build` | Build Ardour |
| `make run` | Run Ardour |
| `make clean` | Clean build artifacts |
