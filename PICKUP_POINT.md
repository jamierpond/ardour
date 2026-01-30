# PICKUP POINT: Undo System Investigation

## Problem
Cross-track clip moves have broken undo behavior. When undoing:
- Single clip moves: **might work** (need to verify after fix)
- Two separate clip moves then undo: **both clips move back** when only one should

This suggests multiple operations are being grouped into a single undo step, or undo is somehow cascading.

## Changes Made

### 1. Fixed RAII destruction order for cross-track moves (xdaw_server.cc:1240-1247)

**Before:**
```cpp
auto change_old = playlist_change(current_playlist);  // Destroyed 2nd
auto change_new = playlist_change(new_playlist);      // Destroyed 1st
```

**After:**
```cpp
auto change_new = playlist_change(new_playlist);      // Destroyed 2nd
auto change_old = playlist_change(current_playlist);  // Destroyed 1st
```

This ensures undo commands execute in correct order: remove from new first, then add back to old.

### 2. Added debug logging (xdaw_server.cc)

Added `[XDAW UNDO]` prefixed logging at:
- `begin_reversible_command` (line ~613)
- `commit_reversible_command` (line ~631)
- `abort_reversible_command` (destructor ~623, finish ~634)
- `rdiff_and_add_command` (playlist_change destructor ~649)

## Next Steps

1. **Run Ardour** with `make run`
2. **Move a clip cross-track**, watch terminal for:
   ```
   [XDAW UNDO] BEGIN reversible command: "XDAW Edit"
   [XDAW UNDO] Recording playlist diff for: <playlist1>
   [XDAW UNDO] Recording playlist diff for: <playlist2>
   [XDAW UNDO] COMMIT reversible command
   ```
3. **Move another clip cross-track**, should see another BEGIN/COMMIT pair
4. **Press Cmd+Z** - only the second clip should move back

## Hypotheses if still broken

1. **Batching on client side**: Client might be sending multiple MoveClip ops in one EditBatch
2. **`pump_ui_thread()` interference**: Line 1635 runs GLib main loop inside undo group, could allow Ardour callbacks to corrupt undo state
3. **Ardour's internal grouping**: Some Ardour mechanism might be combining undo steps

## Key Files
- `/Users/jamiepond/projects/xdaw/examples/ardour/libs/ardour/xdaw_server.cc` - Main server implementation
- Undo logic is in `apply_edits()` starting around line 588
