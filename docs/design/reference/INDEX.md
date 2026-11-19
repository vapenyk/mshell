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
