# Plan: Add XDAW to Headed Ardour

## Goal
Add XDAW support to **regular Ardour with GUI**. The DAW runs normally with its full UI, but can also be controlled via XDAW gRPC API.

This is NOT a headless server - it's the normal DAW with remote control capability added.

## Philosophy
We are **Ardour developers** adding XDAW to our DAW:
- "I can do this in an afternoon!"
- Minimal code, minimal build changes
- XDAW runs alongside the existing UI, not instead of it

## Architecture

```
┌─────────────────────────────────────────┐
│              Ardour (headed)            │
│  ┌─────────────────┐  ┌──────────────┐  │
│  │   GTK UI        │  │  XDAW Server │  │
│  │   (normal)      │  │  (background)│  │
│  └────────┬────────┘  └──────┬───────┘  │
│           │                  │          │
│           └───────┬──────────┘          │
│                   │                     │
│           ┌───────▼───────┐             │
│           │   Session     │             │
│           │   (shared)    │             │
│           └───────────────┘             │
└─────────────────────────────────────────┘
                    │
                    │ gRPC :50051
                    ▼
            ┌───────────────┐
            │  XDAW Client  │
            │  (yapi, etc)  │
            └───────────────┘
```

## What We Add to Ardour

```
examples/ardour/
├── libs/ardour/ardour/
│   └── xdaw_server.h           # XDAWServer class (NEW ~50 lines)
├── libs/ardour/
│   └── xdaw_server.cc          # Implementation (NEW ~300 lines)
├── gtk2_ardour/
│   └── (modify startup to create XDAWServer)
├── wscript                     # Add xdaw SDK dependency (MODIFY)
└── yapi/                       # Test files (NEW)
    ├── create_track.yapi.yml
    ├── create_audio_clip.yapi.yml
    └── render.yapi.yml
```

## Implementation Steps

### Step 1: XDAWServer class (libs/ardour/)
Same as before - the XDAWServer class that wraps xdaw::Server and provides handlers for session state, edits, and rendering.

Key difference: The `run()` method should NOT block. Instead it should:
- Start the gRPC server in background
- Return immediately
- Let the normal GTK main loop continue
- Process pending tasks via GTK idle callback

```cpp
class XDAWServer {
public:
  XDAWServer(Session& session);
  ~XDAWServer();

  auto start() -> void;  // Non-blocking - starts server
  auto stop() -> void;

private:
  // Called from GTK idle to process gRPC tasks
  auto process_tasks() -> bool;

  Session& session_;
  xdaw::Server server_;
  sigc::connection idle_connection_;
};
```

### Step 2: Integrate into Ardour startup (gtk2_ardour/)
Find where Ardour creates the Session and add XDAWServer creation there.

Look for:
- `ARDOUR_UI::load_session()` or similar
- Session creation/loading code

Add:
```cpp
// After session is created/loaded
xdaw_server_ = std::make_unique<ARDOUR::XDAWServer>(*session);
xdaw_server_->start();
```

### Step 3: GTK idle callback for gRPC tasks
Instead of a blocking run loop, use GTK's idle mechanism:

```cpp
auto XDAWServer::start() -> void {
  server_.start();

  // Register idle callback to process gRPC tasks
  idle_connection_ = Glib::signal_idle().connect(
    sigc::mem_fun(*this, &XDAWServer::process_tasks)
  );
}

auto XDAWServer::process_tasks() -> bool {
  if (tasks_pending_.exchange(false)) {
    server_.process_pending_tasks();
  }
  return true;  // Keep calling
}
```

### Step 4: Add XDAW SDK to build
Modify wscript to:
- Find/configure xdaw SDK
- Link libardour against xdaw
- Add xdaw headers to include path

### Step 5: YAPI test files
Same as before - test files that exercise the API.

## Key Files to Investigate

Need to find:
1. Where Session is created in gtk2_ardour/
2. How other background services are started (OSC, MIDI control surfaces)
3. How to add a dependency to wscript

## Integration Points (from exploration)

### Where to hook in:
**`ARDOUR_UI::set_session()`** in `gtk2_ardour/ardour_ui_dialogs.cc` (lines 105-235)

This is called after every session load/create. It wires up all components:
```cpp
void ARDOUR_UI::set_session (Session *s)
{
    SessionHandlePtr::set_session (s);

    // ... existing wiring ...

    // ADD XDAW HERE:
    if (_xdaw_server) {
        _xdaw_server->stop();
    }
    _xdaw_server = std::make_unique<ARDOUR::XDAWServer>(*s);
    _xdaw_server->start();
}
```

### GTK idle pattern:
Use `Glib::signal_idle().connect()` for processing gRPC tasks:
```cpp
auto XDAWServer::start() -> void {
    server_.start();
    idle_connection_ = Glib::signal_idle().connect(
        sigc::mem_fun(*this, &XDAWServer::process_tasks)
    );
}
```

### Existing pattern to follow:
Control protocols in `libs/ardour/control_protocol_manager.cc` show how to:
- Start/stop background services with session lifecycle
- Integrate with GTK main loop
- Handle thread safety with `Glib::Threads::RWLock`

## Key Files to Modify

1. **`gtk2_ardour/ardour_ui.h`** - Add `std::unique_ptr<ARDOUR::XDAWServer> _xdaw_server;`
2. **`gtk2_ardour/ardour_ui_dialogs.cc`** - Start XDAWServer in `set_session()`
3. **`libs/ardour/ardour/xdaw_server.h`** - XDAWServer class
4. **`libs/ardour/xdaw_server.cc`** - Implementation
5. **`wscript`** - Add xdaw SDK dependency

## Implementation Status - COMPLETE

### libs/ardour/
- `ardour/xdaw_server.h` - XDAWServer class with SessionHandlePtr (~90 lines)
- `xdaw_server.cc` - Full implementation (~490 lines)

### gtk2_ardour/
- `ardour_ui.h:80` - `#include "ardour/xdaw_server.h"`
- `ardour_ui.h:475-477` - `_xdaw_server`, `_xdaw_idle_connection`, `xdaw_idle_handler()`
- `ardour_ui_dialogs.cc:217-225` - Server creation and session binding in `set_session()`
- `ardour_ui_dialogs.cc:255-257` - Session cleanup in `unload_session()`
- `ardour_ui_dialogs.cc:1143-1150` - GTK idle handler for gRPC task processing

### Build system
- `wscript:1179-1186` - XDAW SDK paths configured
- `libs/ardour/wscript:279` - `xdaw_server.cc` in source list
- `libs/ardour/wscript:401` - `XDAW` in uselib

### Test files
- `yapi/create_track.yapi.yml`
- `yapi/get_session_state.yapi.yml`
- `yapi/render.yapi.yml`
- `yapi/transport.yapi.yml`

## Features Implemented
- Get session state (tracks, clips, tempo, time signature)
- Get transport state (playing, recording, loop, position)
- Create/delete/rename audio and MIDI tracks
- Set mixer state (mute, solo, volume)
- Transport control (play, stop, jump to beat, loop)
- Render to file using SimpleExport

## Out of Scope (Future Work)
- CreateClip (audio file import)
- DeleteClip (region deletion)
- Plugin loading/browsing
- Real-time monitoring
- MIDI note editing
