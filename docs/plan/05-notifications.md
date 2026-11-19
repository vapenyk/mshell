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
- [x] `NotifCenter` popup: sections ("Silent" with ✕ to clear the section), grouped cards with counter, bottom row: history and wide **Clear all** at the same height, settings (opens nothing yet → omit button until it has an action)
- [x] Empty state designed
- [x] `NotifPill`: bell icon, dot when unread, click toggles `UiState` popup `notifications`; added to the bar before `StatusPill`
- [x] IPC `notifs`: `toggleDnd`, `clear`
- Done when: matches shot 08; bell dot appears and clears; `unused.sh` clean
- Verified bell and unread state, group expansion, section clearing, empty state, session history, and IPC on the nested session bus.

## Follow-up: inline reply
- Create: `modules/notifications/NotifReply.qml` and `NotifActions.qml`.
- Update: enable Quickshell inline replies and show an editor in expanded cards when the sender supplies a reply action. On a toast, request keyboard focus only while replying and pause its timeout.
- History remains in memory for the lifetime of the notification service. Closing the center keeps it. Reloading or restarting the shell clears it.
- Verified keyboard entry and D-Bus reply delivery from both the toast and the center in nested Hyprland.

## Follow-up: notification layout and reply editor
- Create: `modules/notifications/NotifCardContent.qml`, the two-column layout shared by all cards. Update `NotifCard.qml`, `NotifReply.qml`, `NotifActions.qml`, `NotifActionButton.qml`, `NotifCard.model.js` and its tests, `IconButton.qml`, sizing and design tokens, `BEHAVIOR.md`, and the component catalogue.
- Read: on-device captures shot 45, shot 46, shot 47, shot 48, and shot 49 for the card, reply editor, and Discord update. Use shot 50 and shot 51 for attachment previews.
- Before implementation, open the official Material 3 specs in a web browser. Check [Text fields](https://m3.material.io/components/text-fields/specs) for input states, [Icon buttons](https://m3.material.io/components/icon-buttons/specs) for Send, [Buttons](https://m3.material.io/components/buttons/specs) for text and outlined actions, and [Cards](https://m3.material.io/components/cards/specs) for the card. Check [Color roles](https://m3.material.io/styles/color/the-color-system/) and use the project tokens for the implementation.
- [x] Apply the same card layout to every sender. Give images a fixed left column and align the app name, time, title, and message in the right column. For a conversation avatar, use the supplied avatar as the main image with the app icon as a small badge when both are available. Use the app icon on its own when there is no avatar.
- [x] Show content previews separately from the app icon and conversation avatar. Use a small thumbnail on the right in the collapsed card and an aspect-ratio-preserving preview below the body in the expanded card, within the content column. See shot 50 and shot 51. Use square images with the standard instant-message category as conversation avatars. Use the content preview layout for other supplied images.
- [x] When the sender offers inline reply, replace the action row while editing with a full-width footer under both columns. Use a dark, pill-shaped text field with the sender's placeholder when provided. Put the send arrow to its right, outside the field. Use project color, shape, and typography tokens for the default, focused, and disabled states.
- [x] Disable sending while the field is blank. Enter or the send arrow submits. Esc discards the draft, restores the action row, and releases reply focus while keeping the notification visible.
- [x] After sending, close the editor and restore the normal actions for notifications that remain open. At 0:18 the original message is still visible with the actions restored (shot 48). By 0:20.5 Discord shows the reply as another message (shot 49). Render subsequent sender updates in place. Show the sent message when it arrives in a sender update, and honor the sender’s decision to keep or close the notification.
- [x] Verify the same layout and interactions in the toast and notification center with and without avatars, attachment previews, and reply capability. Use the Telegram capture as a payload example. Verified in nested Hyprland with keyboard and pointer input, including a same-ID update from the test sender.

### Quickshell payload check
- Verified on Quickshell 0.3.2 using synthetic `Notify` calls on the nested Hyprland session bus. Both `image-data` and `image-path` load through [`Notification.image`](https://quickshell.org/docs/v0.3.2/types/Quickshell.Services.Notifications/Notification/). When both hints are present, the binary image takes precedence and the path remains available in `hints`.
- Telegram Desktop sends `category: im.received` and a 64×64 image. QML can read that category in `Notification.hints` and resolve the app badge from `desktopEntry` even when `appIcon` is empty. The standard image hints carry an image source. Image purpose depends on sender metadata and layout policy.
- Inline reply exposes the sender's action caption through `inlineReplyPlaceholder`. Reply delivery and replacement with the same notification ID both worked. Reproduced a Quickshell 0.3.2 issue where a same-sender replacement that drops the reply action leaves `hasInlineReply` and the old caption set. Include this case when testing reply state after sender updates.
