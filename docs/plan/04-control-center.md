# 04 — Control center
Goal: screenshot 01/05/06 behaviour. Fixed sliders on top, auto-laid-out tiles below, left click toggles, right click opens a page, user can reorder.

Common read: `../design/SPEC.md` (Control center rules), `../design/reference/INDEX.md` (shots 01, 05, 06, 07).

## 4.1 PopupWindow
- Visual reference: shot [19](../design/reference/19-control-center-final.webp) for placement under the bar.
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
- Visual reference: shot [19](../design/reference/19-control-center-final.webp) for the two tracks and the gap around the handle.
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
- On-device reference: [28](../design/reference/28-device-control-center.png), [44](../design/reference/44-device-control-center-wifi-tooltip.png) for the slider and action button rows.
- Visual reference: shot [19](../design/reference/19-control-center-final.webp) for the slider and round button rows.
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
- On-device reference: [28](../design/reference/28-device-control-center.png), [44](../design/reference/44-device-control-center-wifi-tooltip.png) for icon chips and the Wi-Fi tooltip. Follow `TOKENS.md` for color roles.
- Visual reference: shot [19](../design/reference/19-control-center-final.webp) for the dark active and inactive tile styles.
- Create: `components/Tile.qml`
- Update: `config/Sizing.qml` with tile height, chip size, and padding.
- [x] Props `active, icon, title, subtitle`; signals `toggled`, `settingsRequested`
- [x] Left click → `toggled`; right click → `settingsRequested`; icon chip on the left, texts elided
- [x] On = `primary`/`onPrimary`, off = `surfaceContainerHigh`; chip shape morph on toggle
- Done when: matches shot 07 tile anatomy; used by 4.6

## 4.6 Tile grid
- Read: shot [19](../design/reference/19-control-center-final.webp) for the two-column labeled tiles and one-column icon-only tiles.
- Read: `../design/RESPONSIVE.md` (Content robustness → Tile grid)
- Create: `modules/controlcenter/tiles/TileRegistry.qml`, `modules/controlcenter/TileGrid.qml`, `modules/controlcenter/TileGrid.model.js`, `tests/modules/controlcenter/TileGrid.model.test.js`.
- Update: `pages/MainPage.qml` to host the grid, `components/Tile.qml` for icon-only tiles, and `config/Sizing.qml` with grid spacing. The registry uses disabled tiles until 4.7 supplies live components and hardware availability.
- [x] Registry: id → `{ comp, span, available }` (span fixed in code)
- [x] Model: `visibleTiles(order, defs)` (order from `Config.tiles`; unknown ids dropped; missing ids appended; unavailable hidden), `columnsFor(width)`, `spanWidth(span, cols, cell, gap)`, `move(list, from, to)`
- [x] Grid = `Flow` + `ScriptModel` keyed by id; reorder animates with spatial spring
- [x] Tests for each model function incl. empty list and unknown ids
- Done when: grid renders from `Config.tiles` order (empty → default order from registry)

## 4.7 First tiles
- Read: shot [19](../design/reference/19-control-center-final.webp) for the labeled Wi-Fi and Bluetooth tiles and the icon-only tiles.
- Create: `modules/controlcenter/tiles/WifiTile.qml`, `BluetoothTile.qml`, `ModesTile.qml`, `MicTile.qml`, `services/Modes.qml`
- Update: `TileRegistry.qml` to use live tiles and hide unavailable hardware. Update `services/Network.qml`, `services/Network.model.js`, and its model tests so the Wi-Fi tile can identify its adapter and SSID independently of the preferred connection.
- [x] Each: bind to its service, `onToggled` → service action, `onSettingsRequested` → push page (pages come in 4.9–4.12; until then, no-op)
- [x] `Modes`: `dndOn`, `toggleDnd()` (the notification service honours it in step 05)
- Done when: toggling works and reflects external changes; matches shot 01 look

## 4.8 Reorder (edit mode)
- On-device reference: [39](../design/reference/39-device-edit-tiles.png) for the edit layout and [28](../design/reference/28-device-control-center.png), [40](../design/reference/40-device-power-dropdown.png) for the main header actions.
- [x] Remove the “Control center” title from the main page header. Use the layout from [shot 07](../design/reference/07-control-center-tiles-closeup.png): Edit tiles and Settings on the left, Power with a dropdown chevron on the right. Keep page titles on subpages.
  - Edit tiles is wired in this step.
  - Settings opens the settings window once it is implemented ([backlog](00-OVERVIEW.md#progress)).
  - Power opens the [PowerMenu](08-lock-powermenu.md#82-powermenu) once it is implemented in 8.2.
  - Keep Settings and Power disabled until their destinations are available. Discuss any additional buttons with the user before adding them.
- Read: shot [20](../design/reference/20-control-center-edit-tiles.webp) for the edit page header and tile layout. This step uses the reorder controls specified below.
- Update: `MainPage.qml` and `PageStack.qml` for the root header, `../design/BEHAVIOR.md` for the header rule, `ControlCenter.qml` for edit-mode reset, `TileGrid.qml` and its model and tests for reorder, and `Config.qml` for persistence. Apply the documented `onPrimaryContainer` color to the active chip icon in `Tile.qml`.
- [x] Edit button in the header toggles `UiState.editMode`; in edit mode tiles show move arrows (left/right); drag-and-drop is a later improvement, not this step
- [x] Reorder writes `Config.tiles`; persisted; survives restart
- [x] Left/right click behaviour disabled in edit mode
- Done when: order changes persist and animate

## 4.9 ModesPage (first right-click page)
- On-device reference: [36](../design/reference/36-device-modes-dnd-off.png) for the Do Not Disturb row in the off state.
- Read: shot [26](../design/reference/26-settings-window-dark.webp) for grouped rows and the switch. Use shot 06 for the Modes page layout.
- Read: shot 06
- Create: `modules/controlcenter/pages/ModesPage.qml`
- Update: `TileGrid.qml`, `MainPage.qml`, and `ControlCenter.qml` to route tile settings requests. Add switch sizing tokens in `config/Sizing.qml`.
- [x] Header "Modes", list card "Do Not Disturb / Off|On" with switch; right-click on ModesTile pushes it
- Done when: matches shot 06 structure; back button works

## 4.10 NetworkPage
- Read: [35](../design/reference/35-device-network-connected.png) for the Wi-Fi switch and connected network row.
- Create: `modules/controlcenter/pages/NetworkPage.qml` and `components/ToggleSwitch.qml`, shared with ModesPage.
- Update: `ControlCenter.qml` for navigation, `ModesPage.qml` to use the shared switch, and `services/Network.qml` and its model and tests for scanning and connection actions.
- [x] List of networks, connect/disconnect, switch for Wi-Fi
- Done when: can connect to a known network
- Verified page navigation and live scanning in nested Hyprland. Connection and disconnection commands were tested with fixtures. The active host Wi-Fi connection was left in place.

## 4.11 BluetoothPage
- Read: [33](../design/reference/33-device-bluetooth-connected.png), [34](../design/reference/34-device-bluetooth-page.png) for the adapter switch and connected device row.
- Create: `modules/controlcenter/pages/BluetoothPage.qml` and `ConnectionRow.qml`, shared by the Wi-Fi and Bluetooth pages.
- Update: `ControlCenter.qml` for navigation, `NetworkPage.qml` to use the shared row, and `services/Bluetooth.qml` and its model and tests for paired-device actions.
- [x] Paired devices with connect/disconnect
- Done when: can connect a paired device
- Verified the live paired-device list, and exercised connect/disconnect in nested Hyprland against an isolated BlueZ fixture.

## 4.12 AudioPage
- Read: [37](../design/reference/37-device-audio-headset-output.png), [38](../design/reference/38-device-audio-local-output.png) for the headset and built-in output states.
- Create: `modules/controlcenter/pages/AudioPage.qml`, `services/Audio.model.js`, and `tests/services/Audio.model.test.js`.
- Update: `services/Audio.qml` for PipeWire output selection and playback stream controls, and route the mixer action through `TopControls.qml`, `MainPage.qml`, and `ControlCenter.qml`.
- [x] Show the current output and its volume, the current microphone with the same selected styling as the current output, a mute control, and an input level slider when available, and playback stream volumes. The Effects section and spatial audio controls are out of scope.
- [x] Output device selection + per-app stream volume (mixer button in TopControls opens it)
- Done when: switching output works
- Verified output switching, microphone mute, and per-app volume with an isolated PipeWire session in nested Hyprland.

## Follow-up — tooltips

- Read: [44](../design/reference/44-device-control-center-wifi-tooltip.png), Tooltips in `../design/REFERENCES.md`, and the tooltip motion row.
- Create: `components/Tooltip.qml` using the existing tooltip in `IconButton.qml`. Use it from `IconButton.qml` and `Tile.qml`.
- [x] Show one shared style for Control Center hover labels. Place labels above their controls when they fit, otherwise below. Apply the 500 ms hover delay and fade.
- Verified above the Wi-Fi tile and below the Edit tiles button in nested Hyprland.

End-of-step: tests, unused check, matrix, compare with 01/05/06.
