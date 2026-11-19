# COMPONENTS — M3 component → our file

Spec dp values come from each M3 page's **Specs** tab; copy only what we use into `TOKENS.md`.
"Step" = plan file where it is built. Build a component in its step, not before (see `LEAN.md`).

## Base (shared, `components/`)
| Component | M3 page | Our file | Notes | Step |
|---|---|---|---|---|
| State layer | interaction/states | `StateLayer.qml` | overlay with content color, opacities from `Theme.state*`; used by everything clickable | 02 |
| Icon | Material Symbols | `Icon.qml` | font glyph by name, `filled` bool animates FILL | 02 |
| Text | typography | `Text.qml` | `role: "labelMedium"` → size/weight/line; color default `onSurface` | 02 |
| Surface | color/shape | `Surface.qml` | rectangle with `container` role + `shape` token + optional shadow | 02 |
| Pill | (shell) | `Pill.qml` | bar element: icon/text slot, active state, StateLayer, click/right-click signals | 02 |
| IconButton | icon-buttons | `IconButton.qml` | standard / tonal / filled, toggle variant | 04 (first use: TopControls) |
| Button | buttons | `Button.qml` | filled / tonal / outlined / text | 08 (first use: dialog) |
| ValueSlider | sliders | `ValueSlider.qml` + `.model.js` | thick, icon inside, vertical handle; value↔pos math in model | 04 |
| Tile | (shell, based on toggle button) | `Tile.qml` | `active, icon, title, subtitle`, signals `toggled`, `settingsRequested` | 04 |
| PageStack | (shell) | `PageStack.qml` | header (back, title, action) + animated pages | 04 |
| PopupWindow | menus/dialogs surface | `PopupWindow.qml` | layer-shell popup, anchor, open/close spring, outside-click close | 04 |
| WavyBar | progress-indicators | `WavyBar.qml` + `.model.js` | see MOTION.md | 06 |
| ListItem | lists | `ListItem.qml` | leading, headline, supporting, trailing; selected state | 06 (first use: keyboard popup) |
| SearchBar | search | `SearchBar.qml` | pill field, leading icon | 07 |
| Dialog | dialogs | `Dialog.qml` | scrim + centered surface + actions | 08 |
| Menu | menus | `Menu.qml` | only if tray/context menus are added | backlog |

## Module-local (stay inside their module until a 2nd module needs them)
| Component | Module | Reference screenshot |
|---|---|---|
| ClockPill, StatusPill, MediaPill, KeyboardPill, NotifPill | `modules/bar/pills/` | 10, 11, 12, 09, 08 |
| TopControls, TileGrid, TileSlot, tiles/*Tile | `modules/controlcenter/` | 01, 05, 07 |
| MainPage, NetworkPage, BluetoothPage, ModesPage, AudioPage | `modules/controlcenter/pages/` | 01, 06 |
| NotifCard, NotifCardContent, NotifGroup, NotifCenter, NotifPopup | `modules/notifications/` | 08, 17, 22 |
| MediaCard | `modules/media/` | 11 |
| CalendarPopup | `modules/calendar/` | 12 |
| Launcher, AppItem | `modules/launcher/` | 13 |
| Osd | `modules/osd/` | (none; use ValueSlider in a pill-shaped surface) |
| Lock, LockSurface | `modules/lock/` | 18 |
| PowerMenu | `modules/powermenu/` | (Dialog with 4 tonal buttons) |

## States every interactive component must implement
enabled · hovered · focused (keyboard ring) · pressed · disabled; toggles add checked. All visual change through `StateLayer` + token color swaps.
