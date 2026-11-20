# BEHAVIOR — windows, panels, focus, navigation

What M3 does **not** define for a shell. M3 covers look, states, transitions and in-panel navigation; this file covers how surfaces behave as part of a desktop. Sources: Quickshell docs, wlr-layer-shell, freedesktop notification spec (`REFERENCES.md`).
Names of Quickshell/Hyprland properties below are from memory of the API — **verify** against the 0.3.2 docs on first use and record the result here.

## 1. Surfaces and layers
| Surface | Layer | Keyboard focus | Input | Per screen | Notes |
|---|---|---|---|---|---|
| Bar | Top | none | whole bar | every screen | exclusive zone = bar height |
| Popup (control center, notification center, calendar, media, keyboard) | Overlay | on demand (only while open) | whole popup | screen of the pill that opened it | closes on outside click via focus grab |
| Notification popups | Overlay | none on arrival, on demand during an explicitly opened inline reply | **only over the cards** (input mask), rest click-through | focused screen | stack under the bar, top-right |
| Launcher | Overlay | exclusive while open | whole | focused screen | |
| OSD | Overlay | none | **none** (fully click-through) | focused screen at each OSD action | one pill, bottom center |
| Power dropdown | Inside Control Center | menu focus while open | dropdown and outside dismissal within Control Center | screen of the Control Center | anchored under the Power button |
| Confirmation dialog | Overlay | exclusive while open | whole + scrim | screen where the action was chosen | |
| Lock | session lock | exclusive | whole | every screen | nothing else is visible |

Quickshell 0.3.2 popup APIs verified in nested Hyprland. Set `WlrLayershell.layer: WlrLayer.Overlay` and use `WlrKeyboardFocus.OnDemand` while open. `ExclusionMode.Ignore` places the layer relative to the output edges, so the popup accounts for the bar's reserved space itself. A `Region` input mask restricts clicks to the surface, and `HyprlandFocusGrab.cleared()` handles clicks outside the popup and the bar windows. The bar handles its own outside clicks so pills can still toggle or swap popups.

Notification popups use the same overlay and exclusion settings with `WlrKeyboardFocus.None` on arrival. Opening the inline reply editor temporarily uses `WlrKeyboardFocus.Exclusive`. The window's input mask combines the visible card regions, while each card owns its hover timer. Verified in nested Hyprland with two outputs. In Quickshell 0.3.2, a 1400 ms `notify-send` timeout arrives as `expireTimeout: 1400`.

Verify `WlrKeyboardFocus.Exclusive` for the other surfaces on first use.

Z-order (low → high): bar, popups, notification popups, OSD, dialogs, lock.

## 2. Popup lifecycle
Interactive popups opened by a pill click or a Hyprland IPC action use `UiState.open` or `UiState.openAt`. The OSD owns its display state and accounts for Control Center and session lock through `UiState`.

**Rules**
1. One popup at a time. Opening another **swaps** it (fade-through, no close-then-open gap).
2. Same pill clicked again → closes.
3. Popups anchored to a pill open on that pill's screen. Launcher, OSD, and notification popups use `Compositor.focusedScreen`. Power confirmations use the dropdown's screen.
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
- Titles use the page name and `titleLarge`. The control center root header shows Edit tiles, Settings, and Power actions in place of its title.
- Edit mode (control center): the edit button toggles it; `Esc` leaves edit mode first, then closes.

## 4. Keyboard
**Global (Hyprland binds → IPC).** Names are fixed here; the user wires keys in `hyprland.conf`:
| Target | Functions |
|---|---|
| `launcher` | `toggle` |
| `controlcenter` | `toggle`, `close` |
| `notifs` | `toggleDnd`, `clear` |
| `osd` | `volumeUp`, `volumeDown`, `toggleMute`, `brightnessUp`, `brightnessDown`, `keyboardBrightnessUp`, `keyboardBrightnessDown` |
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
| Hover | state layer and a tooltip after 500 ms on Control Center tiles and icon buttons with a tooltip label |
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
| Keyboard popup | KeyboardPill | outside, Esc, pill, swap, layout selection | fade through when swapping |
| Notification popup | arrival | timeout, dismiss, action, DND | fade + slide / fade + slide |
| Launcher | IPC | Esc, outside, launch | fade + scale / fade |
| OSD | volume, mute, or brightness IPC action or ASUS keyboard backlight hardware event | 1.5 s timeout from the last action, Control Center opens, session locks, or output is removed | fade + slide / fade on timeout |
| Power menu | Power button on the Control Center main page | Esc, outside, button, action | fade through |
| Power confirmation | Restart or Power off | Esc, outside, Cancel, confirm | |
| Lock | Power menu, IPC, future idle trigger | successful PAM auth | fade in |

On the lock surface the bar displays its live indicators. Clicking the bar focuses the password input. The native Wayland session lock keeps the desktop and its popups behind the lock surfaces. The Power menu and IPC share the lock request in `UiState`, which is also the entry point for the future idle trigger.

The OSD opens and extends its timeout on key actions delivered through IPC or an ASUS keyboard backlight hardware event. The ASUS adapter watches `brightness_hw_changed` and requests a fresh reading from `Brightness`. The ASUS driver performs the hardware write. An action selects the focused screen and updates the contents of the same pill. A visible pill follows the live system level. Control Center sliders and ordinary software writes only update that level. Opening Control Center or locking the session hides the OSD immediately. The keys continue to change levels in both states. Muted output displays an empty track. Keyboard backlight uses discrete stops from off through the reported hardware maximum.

## 7. Notifications (freedesktop semantics, not M3)
- Low urgency goes to Silent. Normal urgency opens a toast for 5 s or the sender's `expire_timeout` in milliseconds. Critical urgency opens a toast without a timeout.
- Hovering or expanding a toast pauses its timeout. Collapsing and moving the pointer away resumes the remaining time.
- The Reply button opens the editor when the sender advertises inline reply. Clicking elsewhere releases reply focus and keeps the draft. Esc discards it. Enter or Send submits a nonblank reply. When a persistent notification closes with an unsent draft, it can be copied from history.
- A `replaces_id` update that changes a property exposed to QML refreshes the notification's arrival time, unread state, group order, and toast timeout. A live toast updates in place. After it has exited, an eligible update opens a new toast.
- The center groups notifications by desktop entry or app name. Notifications with neither get their own cards.
- Clicking the card body invokes the sender's default action when available and toggles expansion otherwise. Expanded center cards can copy the message text. The Open link tooltip shows the destination host.
- DND routes persistent notifications to Silent and suppresses ordinary toasts. Critical notifications still request a toast.
- The stack holds up to three toasts. A new critical notification can move the oldest toast out of a full critical stack. Persistent notifications remain available in the center.
- Transient notifications bypass the center, unread indicator, and history. They expire when their toast exits or when delivery cannot show one.
- History holds the latest 100 closed persistent notifications for the session.
- The center never auto-closes while notifications arrive.
- Clearing: per-notification ✕ (on expand), per-section ✕, "Clear all".

## 8. Multi-monitor and hot-plug
- Popups follow the pill's screen; if that screen disappears, the popup closes.
- Bar instances are created/destroyed by `Variants`; no state lives in them except hover/open visuals.
- Launcher and notification popups resolve the focused screen when opening. The OSD resolves it on each action that opens or extends the pill.
- Lock covers all screens, including ones plugged in while locked (`WlSessionLock` handles it; **verify**).

## 9. Fullscreen and special cases
- Overlay-layer surfaces (popups opened by keybind, notifications, OSD) appear above fullscreen windows; the Top-layer bar is hidden under them by the compositor — accepted, do not fight it. **verify** on Hyprland.
- No popup opens while locked.
- Notification popups are suppressed (but stored) while a fullscreen window is focused **only if** a later step adds that rule; default is to show them.

## 10. Performance behaviour
- Closed = unloaded: no timers, no `FrameAnimation`, no polling.
- Services poll only while something observes them where practical (e.g. network scan only while `NetworkPage` is open).
- Animations stop when the surface is hidden.
