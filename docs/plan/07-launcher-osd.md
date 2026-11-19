# 07 — Launcher and OSD

## 7.1 Apps + fuzzy
- Create: `services/Apps.qml`, `utils/Fuzzy.js`, `tests/utils/Fuzzy.test.js`
- [ ] `Apps`: `DesktopEntries` → list `{id, name, icon, comment, exec}`; `launch(id)`
- [ ] `Fuzzy.js`: `rank(query, items, keyFn)` → sorted matches; prefix > word-start > substring > subsequence; stable
- [ ] Tests: empty query (all, alphabetical), exact, prefix beats substring, no match, case-insensitive
- Done when: tests pass; service lists apps

## 7.2 Launcher
- Read: shot 13; `../design/RESPONSIVE.md` (Launcher column)
- Create: `components/SearchBar.qml`, `modules/launcher/Launcher.qml`, `modules/launcher/AppItem.qml`
- [ ] Centered popup on the focused screen; search pill on top (focus on open); grid of results (columns by size class); arrows/Enter/Escape work; opening is instant (data prefetched)
- [ ] IPC `launcher`: `toggle`
- Done when: `qs ipc call launcher toggle` → type → Enter launches

## 7.3 OSD
- Create: `modules/osd/Osd.qml`
- [ ] Appears on volume/brightness change (not on first load), pill-shaped surface: icon + thin bar + value; hides after 1.5 s; spatial in / fade out; focused screen
- [ ] IPC `osd`: `show` (optional, only if needed)
- Done when: changing volume by key shows OSD and doesn't flicker on repeat
