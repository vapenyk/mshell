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
- Create: `modules/notifications/NotifCard.qml`, `NotifActionButton.qml`, `NotifCard.model.js`, and `tests/modules/notifications/NotifCard.model.test.js`. The first production consumer is NotifPopup in 5.3.
- Update: `utils/Format.js`, its tests, and `config/Sizing.qml` for the outlined action stroke.
- [x] Collapsed: fixed app icon column, then `app · time`, title, one-line body, and chevron. Expanded: full-width text within the content column, text-only notification actions, and an outlined Open link button with a browser icon when the body contains a web URL
- [x] Time via `Format.relative(date, now)` (add to `Format.js` + test)
- Done when: both states match shot 08 / 17 structure
- Verified both states and action delivery from a temporary preview in nested Hyprland.

## 5.3 NotifPopup
- Create: `modules/notifications/NotifPopup.qml`, `NotifToast.qml`, `NotifPopup.model.js`, `tests/modules/notifications/NotifPopup.model.test.js`, and `services/Compositor.qml`.
- Update: `shell.qml` to mount the popup stack, `config/Sizing.qml` and `config/Motion.qml` for popup tokens, and `../design/BEHAVIOR.md` with the verified window settings.
- [x] `Compositor` (thin, Hyprland only): `focusedScreen` (map `Hyprland.focusedMonitor` to a `ShellScreen` by name) — reused later by launcher/OSD
- [x] Layer window on the focused screen, top-right under the bar; stack up to 3; auto-dismiss by urgency (critical never)
- [x] In: spatial default from top; out: fade + slide short4
- Done when: `notify-send` shows and dismisses correctly; DND suppresses
- Verified focused-screen placement, sender timeout, hover pause, three-card limit, real click dismissal, replacement, and DND in nested Hyprland.

## 5.3b Pill + center
- Create: `modules/notifications/NotifCenter.qml`, `modules/notifications/NotifGroup.qml`, `modules/notifications/NotifHistory.qml`, `modules/bar/pills/NotifPill.qml`
- Update: `shell.qml`, `Bar.qml`, `Notifs.qml`, `NotifCard.qml`, and `NotifPopup.qml` to connect the center, unread state, grouping, and IPC. Add the unread indicator size in `config/Sizing.qml`.
- History shows notifications cleared or closed during the current session.
- [x] `NotifCenter` popup: sections ("Silent" with ✕ to clear the section), grouped cards with counter, bottom row: history, wide **Clear all**, settings (opens nothing yet → omit button until it has an action)
- [x] Empty state designed
- [x] `NotifPill`: bell icon, dot when unread, click toggles `UiState` popup `notifications`; added to the bar before `StatusPill`
- [x] IPC `notifs`: `toggleDnd`, `clear`
- Done when: matches shot 08; bell dot appears and clears; `unused.sh` clean
- Verified bell and unread state, group expansion, section clearing, empty state, session history, and IPC on the nested session bus.
