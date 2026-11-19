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
- Create: `modules/osd/Osd.qml`
- [ ] Appears on volume/brightness change (not on first load), pill-shaped surface below the right side of the bar, with a horizontal level track, visible handle, and a glyph for the current state (including mute); hides after 1.5 s; spatial in / fade out; focused screen
- [ ] IPC `osd`: `show` (optional, only if needed)
- Done when: changing volume by key shows OSD and doesn't flicker on repeat
