# 05 — Notifications
Goal: shots 08 and 17. Popups on arrival, a center grouped by app with sections, DND respected.
Precondition: other notification daemons stopped (open questions).

Common read: `../design/SPEC.md` (Notifications), `../design/reference/INDEX.md` (shots 08, 17).

## 5.1 Notifs service + grouping
- Create: `services/Notifs.qml`, `utils/Grouping.js`, `tests/utils/Grouping.test.js`
- Update: `shell.qml` to start the notification service with the shell.
- [x] `NotificationServer`; keep notifications as objects in a list (inline component, `ComponentBehavior: Bound`); `dismiss`, `clearAll`, `invoke(action)`
- [x] `Grouping.js`: `groupByApp(list)` (newest group first, newest item first), `sections(list)` → Alerting (normal/critical) and Silent (low urgency or arrived during DND), counts
- [x] DND: when `Modes.dndOn`, new notifications go to Silent. Critical notifications still request a popup.
- [x] Tests: grouping order, sections, DND routing, empty
- Done when: `notify-send` produces entries in the service; tests pass
- Verified delivery, replacement, DND routing, actions, and clearing with `notify-send` on the nested session bus.

## 5.2 NotifCard
- Create: `modules/notifications/NotifCard.qml`. The first production consumer is NotifPopup in 5.3.
- Update: `utils/Format.js`, its tests, and `config/Sizing.qml` for the outlined action stroke.
- [x] Collapsed: app icon, `app · time`, title, one-line body, chevron; expanded: full body, action buttons (outlined)
- [x] Time via `Format.relative(date, now)` (add to `Format.js` + test)
- Done when: both states match shot 08 / 17 structure
- Verified both states and action delivery from a temporary preview in nested Hyprland.

## 5.3 NotifPopup
- Create: `modules/notifications/NotifPopup.qml`, `services/Compositor.qml`
- [ ] `Compositor` (thin, Hyprland only): `focusedScreen` (map `Hyprland.focusedMonitor` to a `ShellScreen` by name) — reused later by launcher/OSD
- [ ] Layer window on the focused screen, top-right under the bar; stack up to 3; auto-dismiss by urgency (critical never)
- [ ] In: spatial default from top; out: fade + slide short4
- Done when: `notify-send` shows and dismisses correctly; DND suppresses

## 5.3b Pill + center
- Create: `modules/notifications/NotifCenter.qml`, `modules/notifications/NotifGroup.qml`, `modules/bar/pills/NotifPill.qml`
- [ ] `NotifCenter` popup: sections ("Silent" with ✕ to clear the section), grouped cards with counter, bottom row: history, wide **Clear all**, settings (opens nothing yet → omit button until it has an action)
- [ ] Empty state designed
- [ ] `NotifPill`: bell icon, dot when unread, click toggles `UiState` popup `notifications`; added to the bar before `StatusPill`
- [ ] IPC `notifs`: `toggleDnd`, `clear`
- Done when: matches shot 08; bell dot appears and clears; `unused.sh` clean
