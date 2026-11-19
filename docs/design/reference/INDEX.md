# reference/ — screenshots and what to take from each

Source: Googlebook OS (Android-based desktop), screenshots from YouTube videos. Light-themed shots are layout references only; **we are dark only**, so map colors through `TOKENS.md`, don't copy them.
Some images are blurry or photographed at an angle: trust structure, not pixels.

| # | File | Shows | Use for | Ignore |
|---|---|---|---|---|
| 01 | `01-control-center-full.png` | Full control center, blue accent. Top: edit-layout icon, settings icon, power with dropdown. Two thick sliders (brightness, volume) each with a round button. Tile grid: large tiles (icon chip + title + subtitle), on = filled with accent | Control center layout, tile anatomy, slider look, spacing | Light colors; Android-only tiles (Quick Share, Auto-rotate) |
| 02 | `02-settings-window.png` | Settings window, two columns. Left: search pill + grouped navigation cards with colored icon chips. Right: grouped list rows with title/subtitle, group corners larger at ends | `ListGroup` / `ListItem` corner logic, search pill | Whole window (backlog) |
| 03 | `03-desktop-widgets-dock.png` | Desktop widget (big scalloped "6 hours" countdown), dock at bottom, file manager window | Expressive scalloped shape idea | Dock, widgets (backlog) |
| 04 | `04-app-window-dock.png` | App window + dock | Nothing now | all |
| 05 | `05-control-center-mono-accent.png` | Control center with a **mono/near-black accent**: on-tiles are dark fill with light text | Proves accent swap works through roles; `mono` accent look | |
| 06 | `06-control-center-modes-page.png` | Sub-page "Modes": back arrow, centered title, settings icon, one list card "Do Not Disturb / Off" | `PageStack` header + sub-page content | |
| 07 | `07-control-center-tiles-closeup.png` | Close-up of tiles, slider handle (vertical bar), pill status in bar (wifi + battery %) | Tile icon chip, slider handle, status pill look | |
| 08 | `08-notification-center.png` | Dark. Notification cards (app icon, app name · time, title, body, expand chevron), "Silent" section with ✕, grouped counter "2 ⌄". Bottom row: history button, wide "Clear all", settings button | Notification center layout and sections, card anatomy, dark palette reference | |
| 09 | `09-keyboard-popup.png` | Dark. Small popup "Keyboard" with settings icon; rows: selected (light container) vs unselected (dark container) | `KeyboardPill` popup, selected list row | |
| 10 | `10-media-pill-collapsed.png` | Bar: media pill with pause button + scrolling title, next to GB / a modes-style icon / bell / wifi+battery | Media pill; bar item ordering (right side) | |
| 11 | `11-media-card-expanded.png` | Media card: album art as blurred background, source icon, cast button, title+artist, big pause button (rounded square), prev/next, **wavy seek bar with vertical handle** | `MediaCard`, `WavyBar` | Cast button |
| 12 | `12-calendar-popup.png` | Clock+date pill on the left of the bar; calendar popup: month title with dropdown, prev/next, weekday header, today = filled circle | `CalendarPopup`, ClockPill | |
| 13 | `13-launcher-app-grid.png` | Launcher: search pill on top (mic icon on right), app grid with labels, scrollbar | `Launcher`, `AppItem`, `SearchBar` | Web search copy, mic |
| 14 | `14-settings-network-page.png` | Settings page: list with leading icons, switch on the right | `Switch` look, list rows | |
| 15 | `15-settings-dark-widgets.png` | Dark settings window; dark list rows; widgets left; clock/date left of bar | Dark list palette | |
| 16 | `16-screenshot-toolbar.png` | Floating capsule toolbar: close, settings, mode toggles (window/area/screen), Record, Screenshot | Backlog (segmented buttons look) | |
| 17 | `17-notification-popup.png` | Light. Notification popup/expanded card under the bell: app icon, title, body, outlined action button ("Open link") | `NotifCard` expanded state, outlined button | |
| 18 | `18-lock-screen.png` | Lock screen: huge clock in two stacked lines (HH / MM), date under, lock icon + hint at bottom | `Lock` layout | Gradient wallpaper |

## Bar anatomy (from 10, 12, 07, 08)
Left: `ClockPill` (time + date). Right, in order: `MediaPill` (only if playing) · `KeyboardPill` (layout code e.g. GB) · modes/DND icon (the sparkle-flag icon next to GB; ours shows only when DND is on) · `NotifPill` (bell, dot when unread) · `StatusPill` (only active services + battery). Each is its own rounded pill; the active popup's pill gets a filled container.

## Newer shots (19–27)

Source: Googlebook OS review screenshots (9to5google, October 2026), final build, real screen captures, **dark theme**, blue accent. Prefer these over the older shots where both cover the same surface. Files are `.webp`. The green rectangles are redacted private text: ignore them. Same rules as above: layout and behaviour only, map colors through `TOKENS.md`, do not copy assets or branding.

| # | File | Shows | Use for | Ignore |
|---|---|---|---|---|
| 19 | `19-control-center-final.webp` | Control center open under the bar, over desktop widgets. Header: edit-layout, settings, power with dropdown. Two sliders (brightness, volume), each with a round button (night light, mixer). Two wide tiles (Wi‑Fi, Bluetooth: icon chip + title + subtitle), then a 4-column grid of **icon-only** tiles. On = light accent fill with dark glyph, off = darker step of the panel | Control center in dark; tile on/off look; wide vs icon-only tile spans; slider anatomy (see notes) | Widgets behind it; "My Googlebook" / "Pixel Buds" labels; Android-only tiles |
| 20 | `20-control-center-edit-tiles.webp` | Edit mode page inside the same popup: back arrow, centered title "Edit tiles", tonal "Remove" button on the right. Current layout in an accent-outlined box with dimmed tiles and one selected tile; below, available tiles grouped by section (Connectivity, Utilities, Display) with "+" badges | `PageStack` header look; what edit mode looks like | Add/remove and sections: out of scope, we only reorder (`SPEC.md`, step 4.8) |
| 21 | `21-desktop-bar-widgets-dock.webp` | Whole 16:10 desktop. Bar over the wallpaper: clock + date as plain text on the left; right cluster: media pill (pause button + truncated title), sparkle-flag icon, bell, status pill (DND glyph, Wi‑Fi, battery %). Desktop widgets (calendar agenda, weather, media, health, sports, up next). Full-width dock strip with centered icons | Bar anatomy, spacing and order; collapsed media pill; overall proportions | Widget contents. Dock and desktop widgets are backlog |
| 22 | `22-notification-center-final.webp` | Notification center under the active bell (bell sits in a filled circle). Cards share one grouped container. First card expanded: app icon, app · time, title, body, text-button actions. Second collapsed: one line + thumbnail. Round chevron chips toggle expand. "Silent" section label, then its card. Bottom row: history button, wide "Clear all", notification settings button | `NotifCard` (collapsed, expanded), `NotifGroup`, sections, bottom action row; battery charging look in the bar (green number + bolt) | Content of the notifications |
| 23 | `23-launcher-and-app-window.webp` | Launcher as a compact popup above the dock, left side: accent-tinted translucent container, dark search pill with a round dropdown button, 4-column icon grid with labels. Right: a floating app window with title bar (app icon, title, minimize / maximize / close) | `Launcher`, `AppItem`, `SearchBar` look; window chrome for later | Phone-app source dropdown, app icons, the Messages content |
| 24 | `24-menu-context.webp` | Right-click context menu: text-only rows, groups separated by thin dividers, disabled rows dimmed, large rounded container | `Menu` text-only variant (backlog) | Browser content behind it |
| 25 | `25-menu-overflow.webp` | Overflow menu: leading icon + label, trailing chevron for submenus, dividers between groups. Top of screen shows the status icons (sparkle-flag, bell, DND, Wi‑Fi, battery 100 charging) and window controls | `Menu` with icons and submenu chevrons (backlog); charging battery look | Browser items |
| 26 | `26-settings-window-dark.webp` | Settings-style window, two panes. Left: nav list, section labels in accent color, selected row = filled accent shape. Right: search pill, breadcrumb title, preview card, grouped list cards: switch row, radio rows with leading icon + title + supporting text. Bar: clock + date on the left, status icons on the right | `ListGroup` / `ListItem`, `Switch` look (ModesPage in 4.9), search pill; settings window layout (backlog) | Chrome-specific content |
| 27 | `27-app-windows-snackbar-fab.webp` | Three floating app windows over the desktop with title bars and window controls. Tasks window: FAB bottom-right, light snackbar with "Undo". Desktop media widget top-right (album art, two text lines, note icon, prev / play / next) | Window chrome, FAB, snackbar (all backlog); compact media widget layout | App contents (a Health window uses its own darker palette) |

## On-device captures (28–44)

Source: screenshots supplied by the user from a Googlebook OS device, 2026-11-19. Prefer them for the surfaces and states shown. Use project behavior for interactions and project tokens for colors. Some captures contain on-device labels and desktop content.

| # | File | Shows | Use for |
|---|---|---|---|
| 28 | [28-device-control-center.png](28-device-control-center.png) | Main control center with header actions, two sliders, and labeled tiles. | Header, slider rows, and leading icon chips. |
| 29 | [29-device-clock-calendar-closed.png](29-device-clock-calendar-closed.png) | Clock and date in the bar with the calendar closed. Desktop widgets underneath. | Idle clock placement. Desktop widgets are backlog. |
| 30 | [30-device-calendar-open.png](30-device-calendar-open.png) | Calendar open below the active clock, with month navigation and today highlighted. | Calendar anchoring, grid, and current-day emphasis. |
| 31 | [31-device-notifications-empty.png](31-device-notifications-empty.png) | Notification center open with an empty state and two bottom actions. | Empty notification center layout. |
| 32 | [32-device-keyboard-layouts.png](32-device-keyboard-layouts.png) | Keyboard popup with English (US) selected and Russian available. | Selected layout row, language codes, and popup placement. |
| 33 | [33-device-bluetooth-connected.png](33-device-bluetooth-connected.png) | Bluetooth page with adapter switch on and a connected headset row. | Switch, connected device row, and header. |
| 34 | [34-device-bluetooth-page.png](34-device-bluetooth-page.png) | Alternate capture of the Bluetooth page with a connected device and a pairing action. | Device row and action placement. Pairing is outside the current step. |
| 35 | [35-device-network-connected.png](35-device-network-connected.png) | Internet page with Wi-Fi enabled and the connected network highlighted. | Network switch and selected row. |
| 36 | [36-device-modes-dnd-off.png](36-device-modes-dnd-off.png) | Modes page with a single Do Not Disturb row in the off state. | Page header and DND row. |
| 37 | [37-device-audio-headset-output.png](37-device-audio-headset-output.png) | Audio page with a headset as the current output. | Output device, volume row, and input section. |
| 38 | [38-device-audio-local-output.png](38-device-audio-local-output.png) | Audio page with the built-in device as the current output. | How the output row changes between devices. |
| 39 | [39-device-edit-tiles.png](39-device-edit-tiles.png) | Tile editor with the current layout above available tile categories. | Header and current layout. Adding and removing tiles is outside step 4.8. |
| 40 | [40-device-power-dropdown.png](40-device-power-dropdown.png) | Power dropdown open below the header action, over the control center. | Menu placement and action grouping. |
| 41 | [41-device-osd-volume.png](41-device-osd-volume.png) | Volume OSD below the right side of the bar, with a filled track and mixer icon. | Volume OSD position and track anatomy. |
| 42 | [42-device-osd-brightness.png](42-device-osd-brightness.png) | Brightness OSD at a middle level, with a brightness glyph and moon icon. | Brightness OSD at an intermediate value. |
| 43 | [43-device-osd-volume-muted.png](43-device-osd-volume-muted.png) | Muted volume OSD with the handle at the left edge and a muted glyph. | Muted glyph and empty track state. |
| 44 | [44-device-control-center-wifi-tooltip.png](44-device-control-center-wifi-tooltip.png) | Wi-Fi tooltip above the connected tile, beside a connected Bluetooth tile. | Tooltip placement and connection chip appearance. |

## On-device notification captures (45–51)

Source: user-supplied screenshot and cropped frames from the 2026-11-19 screen recording. Times are offsets into that recording.

| # | File | Time | Shows | Use for |
|---|---|---|---|---|
| 45 | [45-device-notification-discord-actions.png](45-device-notification-discord-actions.png) | 0:04 | Expanded Discord toast with a conversation image, small Discord badge, separate author avatar, and text actions. | Leading image column, text column, and action row. |
| 46 | [46-device-notification-reply-empty.png](46-device-notification-reply-empty.png) | Screenshot | Discord reply editor open with an empty text field and a dimmed send arrow. | Full-width pill-shaped field, placeholder, and trailing send button. |
| 47 | [47-device-notification-reply-draft.png](47-device-notification-reply-draft.png) | 0:16 | A draft is visible in the reply field and the send arrow is active. | Editing layout and enabled send state. |
| 48 | [48-device-notification-actions-restored.png](48-device-notification-actions-restored.png) | 0:18 | The editor is gone, the regular actions are visible, and the original message remains. | State after the editor closes. |
| 49 | [49-device-notification-discord-reply-visible.png](49-device-notification-discord-reply-visible.png) | 0:20.5 | The reply appears in the Discord notification as a second message with its own avatar. | Sender-updated multi-message layout. |
| 50 | [50-device-notification-preview-collapsed.png](50-device-notification-preview-collapsed.png) | 0:29 | The saved-screen-recording card shows its app icon on the left and a small attachment thumbnail on the right. | Collapsed attachment preview placement. |
| 51 | [51-device-notification-preview-expanded.png](51-device-notification-preview-expanded.png) | 0:31 | The same card shows a larger preview below its text and the Share action below the preview. | Expanded attachment preview, aspect ratio, and action placement. |

## Which shot for which surface
Use the first one listed; the rest are fallbacks.
| Surface | Shots |
|---|---|
| Bar (all pills) | 21, then 10, 12, 07 |
| Media pill (collapsed) | 21, 10 |
| Media card (expanded, wavy seek bar) | 11 only |
| Clock + calendar popup | 29 (closed), 30 (open), then 12 |
| Control center | 28, 44 (Wi-Fi tooltip), then 19, 01, 05, 07 |
| Control center subpages | 36 (Modes), 35 (Network), 33–34 (Bluetooth), 37–38 (Audio); 06 for Modes fallback |
| Control center edit mode | 39, then 20 |
| Notification center | 31 (empty), 22 and 08 (populated) |
| Notification popup and inline reply | 45–49 for content, editing, and the sender update; 17 for the outlined Open link action |
| Notification attachment preview | 50 (collapsed), 51 (expanded); 22 for another collapsed example |
| Keyboard popup | 09 only |
| Launcher | 23, then 13 |
| Lock screen | 18 only |
| OSD | 41 (volume), 42 (brightness), 43 (muted) |
| Power menu | 40, then 01 |
| Menus (backlog) | 24, 25 |
| Settings window (backlog) | 26, then 02, 14, 15 |
| Dock, desktop widgets, app windows (backlog) | 21, 23, 27, then 03, 04 |
| Screenshot toolbar (backlog) | 16 only |

## What the newer shots clarify
- **Slider (19):** the handle is a vertical bar with a visible gap on both sides, so the active and inactive tracks are separate shapes. The icon sits at the inactive end, and the round button is outside the track.
- **Tiles (19):** only Wi‑Fi and Bluetooth are wide in the default layout. Everything else is a 1-column icon-only tile. This matches the span 2 / span 1 rule in `SPEC.md`; small tiles have no title or subtitle on screen.
- **Status pill (19, 21, 22):** a dark capsule with the DND glyph, Wi‑Fi and the battery number. Charging shows the number in green with a bolt (22, 25, 26).
- **Sparkle-flag icon (19, 21, 22, 25):** it sits between the media pill and the bell and is separate from the DND glyph in the status pill. What it does is not visible in any shot, so the "modes/DND icon" line in the bar anatomy above needs a decision before step 06.
- **Keyboard pill:** not visible in any of 19–27. Keep shot 09 for its popup.
- **Clock (21, 26):** shown as plain text on the wallpaper, with no visible container. Shot 12 shows it as a pill.
- **Launcher (23):** a compact, accent-tinted popup next to the dock, not a centered panel. `BEHAVIOR.md` currently places it on the focused screen; this shot is a look reference, not a position rule.
- **Notifications (22):** actions are plain text buttons, not outlined buttons (shot 17). Cards sit in one grouped container with small inner corners.
