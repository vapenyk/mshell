# COMPONENTS — M3 component → our file

Spec dp values come from each [M3 page](REFERENCES.md)'s **Specs** tab; copy only what we use into `TOKENS.md`.
"Step" = plan file where it is built. Build a component in its step, not before (see `LEAN.md`).

Check this catalogue before creating a UI component. Look for a shared component first, then for a component local to the feature. Keep the catalogue current when components are added, moved, or removed. See [the rule of two](../conventions/LEAN.md).

## Shared components

| Component | File | Use | M3 reference | Step |
|---|---|---|---|---|
| State layer | [StateLayer.qml](../../components/StateLayer.qml) | Hover, press, and focus overlay with `Theme.state*` opacity | Interaction states | 02 |
| Icon | [Icon.qml](../../components/Icon.qml) | Material Symbols glyph by name, with animated `filled` state | Material Symbols | 02 |
| Text | [Text.qml](../../components/Text.qml) | Text with a typography role and theme color | Typography | 02 |
| Surface | [Surface.qml](../../components/Surface.qml) | Themed container with shape and optional shadow | Color, shape, elevation | 02 |
| Pill | [Pill.qml](../../components/Pill.qml) | Icon, label, and trailing slot with active state and click signals | Shell component | 02 |
| Icon button | [IconButton.qml](../../components/IconButton.qml) | Standard, tonal, and filled icon buttons, including toggles | Icon buttons | 04 |
| Switch / toggle | [ToggleSwitch.qml](../../components/ToggleSwitch.qml) | Labeled on/off switch used by Modes, Wi-Fi, and Bluetooth | Switch | 04 |
| Slider | [ValueSlider.qml](../../components/ValueSlider.qml) and [model](../../components/ValueSlider.model.js) | Volume, brightness, and input level track with a vertical handle | Sliders | 04 |
| Tile | [Tile.qml](../../components/Tile.qml) | Icon-only or labeled control center tile with toggle and settings actions | Toggle buttons | 04 |
| Page stack | [PageStack.qml](../../components/PageStack.qml) | Animated page navigation with a back button, title, and header actions | Shell component | 04 |
| Popup window | [PopupWindow.qml](../../components/PopupWindow.qml) and [model](../../components/PopupWindow.model.js) | Anchored layer-shell window with outside-click close | Menus and dialogs | 04 |
| Anchored popup | [AnchoredPopup.qml](../../components/AnchoredPopup.qml) | Lazy popup content with open and close transitions anchored to its pill | Menus and dialogs | 06 |

## Module components

| Component | File | Use or reference |
|---|---|---|
| Bar and pills | [Bar.qml](../../modules/bar/Bar.qml), [ClockPill.qml](../../modules/bar/pills/ClockPill.qml), [StatusPill.qml](../../modules/bar/pills/StatusPill.qml), [NotifPill.qml](../../modules/bar/pills/NotifPill.qml) | Clock, status indicators, and notification bell |
| Calendar | [CalendarPopup.qml](../../modules/calendar/CalendarPopup.qml) | Month grid with the current day highlighted, shots 12 and 30 |
| Control center and sliders | [ControlCenter.qml](../../modules/controlcenter/ControlCenter.qml), [TopControls.qml](../../modules/controlcenter/TopControls.qml) | Popup, page navigation, brightness, and volume |
| Tile grid and registry | [TileGrid.qml](../../modules/controlcenter/TileGrid.qml), [TileRegistry.qml](../../modules/controlcenter/tiles/TileRegistry.qml) | Tile layout, order, and availability |
| Individual tiles | [WifiTile.qml](../../modules/controlcenter/tiles/WifiTile.qml), [BluetoothTile.qml](../../modules/controlcenter/tiles/BluetoothTile.qml), [ModesTile.qml](../../modules/controlcenter/tiles/ModesTile.qml), [MicTile.qml](../../modules/controlcenter/tiles/MicTile.qml) | Bind shared Tile to the respective service |
| Control center pages | [MainPage.qml](../../modules/controlcenter/pages/MainPage.qml), [NetworkPage.qml](../../modules/controlcenter/pages/NetworkPage.qml), [BluetoothPage.qml](../../modules/controlcenter/pages/BluetoothPage.qml), [ModesPage.qml](../../modules/controlcenter/pages/ModesPage.qml), [AudioPage.qml](../../modules/controlcenter/pages/AudioPage.qml) | Main controls and device settings |
| Connection row | [ConnectionRow.qml](../../modules/controlcenter/pages/ConnectionRow.qml) | Icon, title, status, and trailing action reused by Wi-Fi, Bluetooth, and Audio |
| Notification card and group | [NotifCard.qml](../../modules/notifications/NotifCard.qml), [NotifCardContent.qml](../../modules/notifications/NotifCardContent.qml), [NotifGroup.qml](../../modules/notifications/NotifGroup.qml) | Two-column cards, avatar badges, attachment previews, and app grouping |
| Notification input and actions | [NotifReply.qml](../../modules/notifications/NotifReply.qml), [NotifActions.qml](../../modules/notifications/NotifActions.qml), [NotifActionButton.qml](../../modules/notifications/NotifActionButton.qml) | Inline reply field, text actions, and outlined Open link action |
| Notification center and history | [NotifCenter.qml](../../modules/notifications/NotifCenter.qml), [NotifHistory.qml](../../modules/notifications/NotifHistory.qml) | Grouped lists, empty state, and session history |
| Notification popup and toast | [NotifPopup.qml](../../modules/notifications/NotifPopup.qml), [NotifToast.qml](../../modules/notifications/NotifToast.qml) | On-screen stack, timeout, hover pause, and transitions |

## Planned components

| Component | Planned location | Plan or reference |
|---|---|---|
| WavyBar | `components/WavyBar.qml` and its model | 06, progress indicators, [motion](MOTION.md) |
| ListItem | `components/ListItem.qml` | 06, keyboard popup |
| MediaPill, KeyboardPill | `modules/bar/pills/` | 06, shots 10, 32 |
| MediaCard | `modules/media/` | 06, shot 11 |
| SearchBar, Launcher, AppItem | `components/SearchBar.qml`, `modules/launcher/` | 07, discuss launcher before implementation |
| Osd | `modules/osd/` | 07, shots 41–43, use ValueSlider |
| Button, Dialog | `components/Button.qml`, `components/Dialog.qml` | 08, text, outlined, filled, and tonal buttons for dialogs |
| Lock, LockSurface, PowerMenu | `modules/lock/`, `modules/powermenu/` | 08, shots 18, 40 |
| Menu | `components/Menu.qml` | Backlog, shots 24, 25 |

## States every interactive component must implement
enabled · hovered · focused (keyboard ring) · pressed · disabled; toggles add checked. All visual change through `StateLayer` + token color swaps.
