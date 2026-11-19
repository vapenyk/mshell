# 03 — Bar
Goal: the bar as in screenshots 07/10/12, with clock and status pills working. Other pills arrive with their features (05 bell, 06 media + keyboard).

Common read: `../design/reference/INDEX.md` (Bar anatomy), `../design/RESPONSIVE.md` (Bar column).

## 3.1 UiState
- Read: `../conventions/NAMING.md` (Relations between features)
- Create: `services/UiState.qml`
- Update: `modules/bar/Bar.qml` to route the existing clock click through UiState.
- [x] `openPopup: string` (`""` = none), `open(name)`, `close()`, `toggle(name)`; `editMode: bool`
- Done when: the existing clock pill toggles the calendar state. The dedicated clock and status pills use UiState in 3.3 and 3.4.

## 3.2 Status services (minimal)
- Read: `00-OVERVIEW.md` open-question answers (Quickshell 0.3.2, Hyprland); the 0.3.2 docs for `Quickshell.Networking` / `Quickshell.Bluetooth` / `Quickshell.Services.UPower`
- Create: `services/Network.qml`, `services/Bluetooth.qml`, `services/Battery.qml`
- Create: `services/Network.model.js`, `services/Bluetooth.model.js`, `services/Battery.model.js` and their tests in `tests/services/` for device selection, counting, and charge conversion.
- Update: `shell.qml` to start each service once.
- [x] Use the native Networking, Bluetooth, and UPower modules in Quickshell 0.3.2.
- [x] `Network`: independent `wifiConnected` and `ethernetConnected` flags, Wi-Fi `ssid` and `strength` (0–1), `enabled`, `toggle()`.
- [x] `Bluetooth`: `available`, `enabled`, `connectedCount`, `toggle()`
- [x] `Battery`: `present`, `percent` (0–100), `charging`, `low` (≤ 15)
- Done when: the services match the system's readings in the nested sandbox and the toggles and live updates work on a private test bus.

## 3.3 ClockPill
- On-device reference: [29](../design/reference/29-device-clock-calendar-closed.png), [30](../design/reference/30-device-calendar-open.png) for the idle clock and active clock with calendar.
- Visual reference: shots [21](../design/reference/21-desktop-bar-widgets-dock.webp) and [26](../design/reference/26-settings-window-dark.webp) for clock and date placement.
- Create: `modules/bar/pills/ClockPill.qml`, `modules/bar/pills/ClockPill.model.js`, `tests/modules/bar/pills/ClockPill.model.test.js`
- Update: `modules/bar/Bar.qml` to use ClockPill, `config/Theme.qml` to handle a detached screen during teardown, and `tests/load.js` to load the model's relative JavaScript import.
- [x] Model: `label(date, sizeClass, use24h)` shows time only on compact screens and time plus the short date on larger screens.
- [x] Click toggles `UiState.toggle("calendar")`. The calendar popup arrives in 06.
- Done when: matches shot 12 left side; test passes

## 3.4 StatusPill
- On-device reference: [28](../design/reference/28-device-control-center.png), [44](../design/reference/44-device-control-center-wifi-tooltip.png) for Wi-Fi and Bluetooth shown together.
- Visual reference: shot [21](../design/reference/21-desktop-bar-widgets-dock.webp) for placement and shots [22](../design/reference/22-notification-center-final.webp) and [25](../design/reference/25-menu-overflow.webp) for the charging indicator.
- Read: `../design/MOTION.md` (status pill hide/show), `../design/reference/07-control-center-tiles-closeup.png`
- Create: `modules/bar/pills/StatusPill.qml`, `modules/bar/pills/StatusPill.model.js`, `tests/modules/bar/pills/StatusPill.model.test.js`
- Update: `modules/bar/Bar.qml` to load the status pill at the right edge.
- [x] Model: `icons(state)` displays active DND, Ethernet, Wi-Fi, Bluetooth, and battery in that order. Ethernet and Wi-Fi can appear together. Wi-Fi uses signal bars. The battery descriptor carries its percentage and low-charge state, with a distinct charging icon.
- [x] Empty list → pill hidden (width spring to 0 + fade)
- [x] Click → `UiState.toggle("controlcenter")`; `active` while that popup is open
- [x] Tests: empty state, Wi-Fi signal levels, DND on its own, all active connections together, and battery state.
- Done when: matches shot 07 (wifi + battery %) ; hides when nothing is active

- Verified the DND indicator with the live service in nested Hyprland. A device fixture in the same sandbox also verified Wi-Fi, Ethernet, and Bluetooth together and the removal of each network icon independently.

## 3.5 Bar layout
- Visual reference: shot [21](../design/reference/21-desktop-bar-widgets-dock.webp) for spacing and order of the bar items.
- Modify: `modules/bar/Bar.qml`
- [x] Left: `ClockPill`. Right: `StatusPill` (other pills added by later steps in the order from the Bar anatomy)
- [x] Margins, gaps, and height use the documented tokens. The transparent window reserves its full height at the top and leaves keyboard focus with the current window.
- [x] Compact class: clock without date
- Done when: the resize and scale checks cover all five classes and the 599/600 boundary, monitor hot-plug preserves one bar per output, `unused.sh` is clean, and tests pass.
