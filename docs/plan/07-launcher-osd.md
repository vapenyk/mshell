# 07 — Launcher and OSD

Before starting launcher work (7.1 or 7.2), contact the user to discuss how it should work. Wait for that discussion before implementing it. The launcher should follow the agreed design and behavior.

## 7.1 Apps + fuzzy
- Create: `services/Apps.qml`, `utils/Fuzzy.js`, `tests/utils/Fuzzy.test.js`
- [ ] `Apps`: `DesktopEntries` → list `{id, name, icon, comment, exec}`; `launch(id)`
- [ ] `Fuzzy.js`: `rank(query, items, keyFn)` → sorted matches; prefix > word-start > substring > subsequence; stable
- [ ] Tests: empty query (all, alphabetical), exact, prefix beats substring, no match, case-insensitive
- Done when: tests pass; service lists apps

## 7.2 Launcher
- Read: `../design/RESPONSIVE.md` (Launcher column) and confirm which layout and sizing rules apply after discussing the design with the user.
- Create: `components/SearchBar.qml`, `modules/launcher/Launcher.qml`, `modules/launcher/AppItem.qml`
- [ ] Centered popup on the focused screen; search pill on top (focus on open); grid of results (columns by size class); arrows/Enter/Escape work; opening is instant (data prefetched)
- [ ] IPC `launcher`: `toggle`
- Done when: `qs ipc call launcher toggle` → type → Enter launches

## 7.3 OSD
- Read: on-device references [41](../design/reference/41-device-osd-volume.png), [42](../design/reference/42-device-osd-brightness.png), [43](../design/reference/43-device-osd-volume-muted.png) for normal volume, brightness, and muted volume.
- Read: Material 3 slider [specs](https://m3.material.io/components/sliders/specs) and [guidelines](https://m3.material.io/components/sliders/guidelines).
- Read: `../design/BEHAVIOR.md` sections 1, 2, 4, 5 and the OSD row in section 6, `../design/MOTION.md`, `../design/COMPONENTS.md`, and `../conventions/TESTING.md`.
- Create: `modules/osd/Osd.qml`, `modules/osd/Osd.model.js`, and `tests/modules/osd/Osd.model.test.js`.
- Move `ValueSlider.qml` and its model to `components/sliders/` and move the model test to `tests/components/sliders/`. Update its Control Center consumers and catalogue links.
- Update: `shell.qml`, `services/Brightness.qml` and its model and tests, `services/Audio.qml`, `modules/controlcenter/TopControls.qml`, `config/Sizing.qml`, `config/Motion.qml`, and the design docs.
- [x] Observe output volume/mute, display brightness, and keyboard backlight changes after the initial device readings. Show one click-through pill under the bar on the focused screen, with a horizontal track, handle, and current state icon. Restart the 1.5 s timeout on each change.
- [x] Render keyboard backlight with stop indicators from its reported integer range, including off. The shared slider supports both continuous and stepped tracks. Keep the existing interactive Control Center sliders working.
- [x] Use the Control Center sliders themselves as feedback for adjustments made there. Keep the OSD available for external changes while Control Center is open.
- Done when: volume, mute, display brightness, and stepped keyboard backlight update in the nested session. Verify repeated input, hidden startup, timeout, and layer placement.
- Verified in nested Hyprland with two outputs, a test PipeWire sink, and simulated brightness devices. Checked output changes and removal, click-through, slider writes without OSD, and external changes with Control Center open.
