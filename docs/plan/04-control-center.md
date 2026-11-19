# 04 — Control center
Goal: screenshot 01/05/06 behaviour. Fixed sliders on top, auto-laid-out tiles below, left click toggles, right click opens a page, user can reorder.

Common read: `../design/SPEC.md` (Control center rules), `../design/reference/INDEX.md` (shots 01, 05, 06, 07).

## 4.1 PopupWindow
- Read: `../design/MOTION.md` (Popup open/close), `../design/RESPONSIVE.md` (Popup placement)
- Create: `components/PopupWindow.qml`, `components/PopupWindow.model.js`, `tests/components/PopupWindow.model.test.js`, `modules/controlcenter/ControlCenter.qml`
- Update: `config/Sizing.qml` with the documented popup dimensions, `services/UiState.qml` with the popup anchor, `shell.qml` to connect the bar and control center, and `modules/bar/Bar.qml` and `modules/bar/pills/StatusPill.qml` to route pill and outside clicks.
- Record the verified layer and focus APIs in `../design/BEHAVIOR.md`.
- [x] Layer-shell popup under an anchor item. `LazyLoader` follows `UiState.openPopup` and releases the window after its exit animation.
- [x] Open: scale .92→1 + fade + 8 dp slide (spatial spring); close: faster
- [x] Close on outside click and Escape; only one popup at a time
- [x] Surface `surfaceContainer`, radius `extraLarge`, width 400 (compact: screen − 16, capped at 400)
- [x] IPC `controlcenter`: `toggle`, `close`
- Done when: StatusPill click opens/closes it, correctly placed on each screen

## 4.2 PageStack
- Read: `../design/MOTION.md` (shared axis)
- Create: `components/PageStack.qml`, `modules/controlcenter/pages/MainPage.qml` (root page for the upcoming controls and tiles)
- Update: `modules/controlcenter/ControlCenter.qml` to host the page stack.
- [x] Header: back button (only when depth > 1), centered title, trailing action; pages pushed/popped with slide+fade
- [x] `push(component, props)`, `pop()`, `depth`
- Done when: ControlCenter hosts it with `MainPage` as the root

## 4.3 ValueSlider
- Read: `../design/COMPONENTS.md` (ValueSlider), the [M3 sliders page](https://m3.material.io/components/sliders/overview), and shot 01 in `../design/reference/`.
- Create: `components/ValueSlider.qml`, `components/ValueSlider.model.js`, `tests/components/ValueSlider.model.test.js`, and `tools/SliderPreview.qml`.
- Update: `config/Sizing.qml` with slider geometry tokens and `config/Theme.qml` with the documented disabled opacity.
- Verify the slider in a sandbox copy of MainPage using `SliderPreview` from `tools/` as its content. The preview holds its own interactive values.
- [x] Model: `valueFromPos(x, width, min, max, step)`, `posFromValue(...)`, clamp
- [x] Look: height 40, full radius, active track `primary`, rest `surfaceContainerHighest`, icon inside at the end, vertical handle bar
- [x] Drag follows pointer 1:1; release settles handle with spatial fast; keyboard arrows step
- [x] Tests: clamp, step rounding, round-trip pos↔value, zero width
- Done when: looks like shot 01 sliders (dark roles); tests pass

## 4.4 Top controls
- Read: `00-OVERVIEW.md` open-question answers, `../design/BEHAVIOR.md` (Keyboard and Pointer), and shot 01.
- Create: `components/IconButton.qml`, `services/Audio.qml`, `services/Brightness.qml`, `services/Brightness.model.js`, `services/NightLight.qml`, `services/NightLight.model.js`, `tests/services/Brightness.model.test.js`, `tests/services/NightLight.model.test.js`, and `modules/controlcenter/TopControls.qml`.
- Update: `modules/controlcenter/pages/MainPage.qml` to host TopControls, and `components/ValueSlider.qml` to step on mouse-wheel input.
- Remove `tools/SliderPreview.qml` when TopControls uses ValueSlider.
- Use `hyprsunset` for night light. Start it on demand if the session has no running instance. Enable the mixer button when AudioPage is added in 4.12.
- [x] `Audio`: `volume`, `muted`, `setVolume`, `toggleMute`, and source mute (for the mic tile) via PipeWire and `PwObjectTracker`.
- [x] `Brightness`: `value` 0..1 and `set` via `brightnessctl` (array commands, machine-readable output, tested parser). Clamp writes to at least 5% and refresh the visible slider when external tools make changes.
- [x] `IconButton` (standard/tonal/filled, toggle) with StateLayer.
- [x] Two fixed rows with a `ValueSlider` and a round `IconButton` for night light and mixer.
- Done when: moving sliders changes real volume/brightness; external changes reflect back

## 4.5 Tile
- Create: `components/Tile.qml`
- Update: `config/Sizing.qml` with tile height, chip size, and padding.
- [x] Props `active, icon, title, subtitle`; signals `toggled`, `settingsRequested`
- [x] Left click → `toggled`; right click → `settingsRequested`; icon chip on the left, texts elided
- [x] On = `primary`/`onPrimary`, off = `surfaceContainerHigh`; chip shape morph on toggle
- Done when: matches shot 07 tile anatomy; used by 4.6

## 4.6 Tile grid
- Read: `../design/RESPONSIVE.md` (Content robustness → Tile grid)
- Create: `modules/controlcenter/tiles/TileRegistry.qml`, `modules/controlcenter/TileGrid.qml`, `modules/controlcenter/TileGrid.model.js`, `tests/modules/controlcenter/TileGrid.model.test.js`.
- Update: `pages/MainPage.qml` to host the grid, `components/Tile.qml` for icon-only tiles, and `config/Sizing.qml` with grid spacing. The registry uses disabled tiles until 4.7 supplies live components and hardware availability.
- [x] Registry: id → `{ comp, span, available }` (span fixed in code)
- [x] Model: `visibleTiles(order, defs)` (order from `Config.tiles`; unknown ids dropped; missing ids appended; unavailable hidden), `columnsFor(width)`, `spanWidth(span, cols, cell, gap)`, `move(list, from, to)`
- [x] Grid = `Flow` + `ScriptModel` keyed by id; reorder animates with spatial spring
- [x] Tests for each model function incl. empty list and unknown ids
- Done when: grid renders from `Config.tiles` order (empty → default order from registry)

## 4.7 First tiles
- Create: `modules/controlcenter/tiles/WifiTile.qml`, `BluetoothTile.qml`, `ModesTile.qml`, `MicTile.qml`, `services/Modes.qml`
- [ ] Each: bind to its service, `onToggled` → service action, `onSettingsRequested` → push page (pages come in 4.9–4.12; until then, no-op)
- [ ] `Modes`: `dndOn`, `toggleDnd()` (the notification service honours it in step 05)
- Done when: toggling works and reflects external changes; matches shot 01 look

## 4.8 Reorder (edit mode)
- Create: nothing new except `TileSlot.qml` if needed
- [ ] Edit button in the header toggles `UiState.editMode`; in edit mode tiles show move arrows (left/right); drag-and-drop is a later improvement, not this step
- [ ] Reorder writes `Config.tiles`; persisted; survives restart
- [ ] Left/right click behaviour disabled in edit mode
- Done when: order changes persist and animate

## 4.9 ModesPage (first right-click page)
- Read: shot 06
- Create: `modules/controlcenter/pages/ModesPage.qml`
- [ ] Header "Modes", list card "Do Not Disturb / Off|On" with switch; right-click on ModesTile pushes it
- Done when: matches shot 06 structure; back button works

## 4.10 NetworkPage
- Create: `modules/controlcenter/pages/NetworkPage.qml` (+ service additions: network list, connect)
- [ ] List of networks, connect/disconnect, switch for Wi-Fi
- Done when: can connect to a known network

## 4.11 BluetoothPage
- Create: `modules/controlcenter/pages/BluetoothPage.qml` (+ service additions: devices)
- [ ] Paired devices with connect/disconnect
- Done when: can connect a paired device

## 4.12 AudioPage
- Create: `modules/controlcenter/pages/AudioPage.qml`
- [ ] Output device selection + per-app stream volume (mixer button in TopControls opens it)
- Done when: switching output works

End-of-step: tests, unused check, matrix, compare with 01/05/06.
