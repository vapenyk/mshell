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
- [x] `Network`: `connected`, `kind` (`wifi`/`ethernet`), `ssid`, `strength` (0–1), `enabled`, `toggle()`. Prefer Ethernet when both connection types are active.
- [x] `Bluetooth`: `available`, `enabled`, `connectedCount`, `toggle()`
- [x] `Battery`: `present`, `percent` (0–100), `charging`, `low` (≤ 15)
- Done when: the services match the system's readings in the nested sandbox and the toggles and live updates work on a private test bus.

## 3.3 ClockPill
- Create: `modules/bar/pills/ClockPill.qml`, `modules/bar/pills/ClockPill.model.js`, test
- [ ] Model: `label(date, sizeClass, use24h)` → compact: time only; otherwise "13:15 Mon 12 Oct"
- [ ] Click → `UiState.toggle("calendar")` (popup arrives in 06; no-op until then)
- Done when: matches shot 12 left side; test passes

## 3.4 StatusPill
- Create: `modules/bar/pills/StatusPill.qml`, `modules/bar/pills/StatusPill.model.js`, test
- [ ] Model: `icons(state)` → ordered list of `{name, filled}` for **active only**: network (kind/strength), bluetooth connected, DND on (later), battery (with percent, charging)
- [ ] Empty list → pill hidden (width spring to 0 + fade)
- [ ] Click → `UiState.toggle("controlcenter")`; `active` while that popup is open
- [ ] Tests: nothing active → `[]`; wifi+bt → 2 icons in order; battery low flag; ethernet vs wifi
- Done when: matches shot 07 (wifi + battery %) ; hides when nothing is active

## 3.5 Bar layout
- Modify: `modules/bar/Bar.qml`
- [ ] Left: `ClockPill`. Right: `StatusPill` (other pills added by later steps in the order from the Bar anatomy)
- [ ] Margins, gaps, height from TOKENS; transparent window, exclusive zone = bar height
- [ ] Compact class: clock without date
- Done when: resize/scale matrix OK; `unused.sh` clean; tests pass
