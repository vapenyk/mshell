# BEHAVIOR — windows, panels, focus, navigation

What M3 does **not** define for a shell. M3 covers look, states, transitions and in-panel navigation; this file covers how surfaces behave as part of a desktop. Sources: Quickshell docs, wlr-layer-shell, freedesktop notification spec (`REFERENCES.md`).
Names of Quickshell/Hyprland properties below are from memory of the API — **verify** against the 0.3.2 docs on first use and record the result here.

## 1. Surfaces and layers
| Surface | Layer | Keyboard focus | Input | Per screen | Notes |
|---|---|---|---|---|---|
| Bar | Top | none | whole bar | every screen | exclusive zone = bar height |
| Popup (control center, notification center, calendar, media, keyboard) | Overlay | on demand (only while open) | whole popup | screen of the pill that opened it | closes on outside click via focus grab |
| Notification popups | Overlay | none (never steal focus) | **only over the cards** (input mask), rest click-through | focused screen | stack under the bar, top-right |
| Launcher | Overlay | exclusive while open | whole | focused screen | |
| OSD | Overlay | none | **none** (fully click-through) | focused screen | |
| Dialog / power menu | Overlay | exclusive while open | whole + scrim | focused screen | |
| Lock | session lock | exclusive | whole | every screen | nothing else is visible |

Quickshell hints (**verify**): `WlrLayershell.layer`, `WlrLayershell.keyboardFocus` (`None` / `OnDemand` / `Exclusive`), `exclusiveZone`, window `mask: Region {}` for click-through, `HyprlandFocusGrab { windows: [...]; onCleared: UiState.close() }` for outside-click dismissal.

Z-order (low → high): bar, popups, notification popups, OSD, dialogs, lock.

## 2. Popup lifecycle
**Open sources:** pill click, IPC call, Hyprland keybind (which is an IPC call). All go through `UiState.open(name)`.

**Rules**
1. One popup at a time. Opening another **swaps** it (fade-through, no close-then-open gap).
2. Same pill clicked again → closes.
3. Popups anchored to a pill open on that pill's screen. Launcher, OSD, dialogs, notification popups use `Compositor.focusedScreen`.
4. Popup opens at the root page every time (no remembered sub-page, no remembered scroll).
5. While a popup is open, the pill that owns it shows the active container (`secondaryContainer`).

**Close triggers (all must work):**
- click outside (focus grab cleared)
- `Esc` — if `PageStack.depth > 1` it goes back one page first, otherwise closes
- same pill clicked again
- another popup opens (swap)
- the popup's screen is removed
- lock starts
- action completed where it makes sense (launcher after launching an app, power menu after an action)

**Never closes on:** hover leaving, brightness/volume changes, notification arrival, tile toggles.

**Destroy:** after the close animation ends, the `LazyLoader` is deactivated so nothing runs while closed.

## 3. Navigation inside a panel
- A panel with sub-pages uses `PageStack`: header = back button (when depth > 1) + title + optional trailing action.
- Pages are entered from the main page: tile right-click, "mixer" button, list row with chevron. Max depth 2 (main → sub). No deeper trees.
- Transition: **shared axis X** (see `MOTION.md`). Back = reverse.
- Header back, `Esc`, `Backspace` (when no text field focused), and mouse back button all pop.
- Title text = the page's name, `titleLarge`.
- Edit mode (control center): the edit button toggles it; `Esc` leaves edit mode first, then closes.

## 4. Keyboard
**Global (Hyprland binds → IPC).** Names are fixed here; the user wires keys in `hyprland.conf`:
| Target | Functions |
|---|---|
| `launcher` | `toggle` |
| `controlcenter` | `toggle`, `close` |
| `notifs` | `toggleDnd`, `clear` |
| `osd` | `show` (only if needed) |
| `powermenu` | `toggle` |
| `lock` | `lock` |
| `config` | `setAccent <name>` |
Example: `bind = SUPER, Space, exec, qs -c mshell ipc call launcher toggle`

**Inside popups**
| Key | Action |
|---|---|
| `Esc` | back one page / leave edit mode / close |
| `Tab` / `Shift+Tab` | next / previous focusable; focus ring visible only for keyboard focus |
| Arrow keys | move in grids (tiles, apps), lists (keyboard layouts, notifications), calendar days, sliders (step) |
| `Enter` / `Space` | activate (tile = toggle, list row = select, button = click) |
| `Shift+F10` or `Menu` | same as right click (tile → its page) |
| `PageUp/PageDown`, `Home/End` | scroll / jump in long lists and the launcher |
Opening a popup via keyboard puts focus on its first focusable element (launcher: the search field).

## 5. Pointer
| Input | Behaviour |
|---|---|
| Left click | primary action (toggle, open, select) |
| Right click | secondary: tile → settings page; pill → none unless defined in its step |
| Middle click | none (don't invent) |
| Hover | state layer only; tooltip after 500 ms where an icon has no label |
| Scroll over a `ValueSlider` | changes value by one step; over a list → scrolls |
| Drag | slider handle; (later) tile reorder |
| Pressed + move off the target | cancels the click (standard) |

## 6. Per-surface summary
| Surface | Opens by | Closes by | Transition in/out |
|---|---|---|---|
| Control center | StatusPill, IPC | outside, Esc, pill, swap | container-ish from pill / fast out |
| Notification center | NotifPill | same | same |
| Calendar | ClockPill | same | same |
| Media card | MediaPill | same | container transform from pill |
| Keyboard popup | KeyboardPill | same | fade through when swapping |
| Notification popup | arrival | timeout, dismiss, action, DND | fade + slide / fade |
| Launcher | IPC | Esc, outside, launch | fade + scale / fade |
| OSD | volume/brightness change | 1.5 s timeout (resets on change) | fade + slide / fade |
| Power menu | CC power dropdown, IPC | Esc, outside, action | fade through |
| Lock | IPC, idle | successful auth | fade |

## 7. Notifications (freedesktop semantics, not M3)
- Urgency: low → Silent section, no popup; normal → popup, timeout 5 s (or the sender's `expire_timeout` if given); critical → popup, no timeout, stays until dismissed.
- Hovering a popup pauses its timeout.
- `replaces_id` updates the existing notification in place (no new card/animation).
- Click on the card body = default action if the sender provided one, else dismiss. Action buttons call `invoke`.
- DND on: everything goes to Silent, no popups, **critical still shows**.
- Max 3 popups visible; older ones wait in the center.
- The center never auto-closes while notifications arrive.
- Clearing: per-notification ✕ (on expand), per-section ✕, "Clear all".

## 8. Multi-monitor and hot-plug
- Popups follow the pill's screen; if that screen disappears, the popup closes.
- Bar instances are created/destroyed by `Variants`; no state lives in them except hover/open visuals.
- Focused screen for launcher/OSD/notifications is read at the moment of opening, not cached.
- Lock covers all screens, including ones plugged in while locked (`WlSessionLock` handles it; **verify**).

## 9. Fullscreen and special cases
- Overlay-layer surfaces (popups opened by keybind, notifications, OSD) appear above fullscreen windows; the Top-layer bar is hidden under them by the compositor — accepted, do not fight it. **verify** on Hyprland.
- No popup opens while locked.
- Notification popups are suppressed (but stored) while a fullscreen window is focused **only if** a later step adds that rule; default is to show them.

## 10. Performance behaviour
- Closed = unloaded: no timers, no `FrameAnimation`, no polling.
- Services poll only while something observes them where practical (e.g. network scan only while `NetworkPage` is open).
- Animations stop when the surface is hidden.
