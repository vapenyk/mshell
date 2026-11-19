# NAMING — names and how features relate

## Files
| Kind | Pattern | Example |
|---|---|---|
| QML type / component | `PascalCase.qml`, noun | `ValueSlider.qml` |
| Singleton | `PascalCase.qml`, domain noun, `pragma Singleton` | `Audio.qml`, `UiState.qml` |
| Logic for a QML file | `<SameName>.model.js` next to it | `TileGrid.model.js` |
| Shared pure JS | `PascalCase.js` in `utils/` | `Format.js`, `Fuzzy.js` |
| Test | `tests/<same path>/<Name>.model.test.js` (models) or `<Name>.test.js` (utils) | `tests/modules/controlcenter/TileGrid.model.test.js`, `tests/utils/Fuzzy.test.js` |
| Plan step | `NN-name.md`, two digits | `04-control-center.md` |

## Suffix = role (so a name tells you where it lives)
| Suffix | Meaning | Lives in |
|---|---|---|
| `*Pill` | element of the bar | `modules/bar/pills/` |
| `*Tile` | control-center toggle tile | `modules/controlcenter/tiles/` |
| `*Page` | sub-page of a `PageStack` | `modules/<feature>/pages/` |
| `*Card` | content card (notification, media) | its module |
| `*Popup` | a popup window of a feature | its module |
| `*Item` | one row/cell of a list or grid | its module |
| `*.model.js` | pure logic | next to the QML it serves |
Components that exist in M3 keep the M3 name: `Button`, `IconButton`, `Switch`, `Card`, `Menu`, `Dialog`, `SearchBar`, `ListItem`, `Tooltip`.

## Inside files
- Root element `id: root`. Other ids camelCase, descriptive. Never `rect1`.
- Private properties/functions: leading `_` (`_pressed`, `_commit()`).
- Properties: camelCase. Booleans read as state: `active`, `enabled`, `playing`, `hasDevice`. Not `isX` unless needed.
- Signals: past participle or event noun: `toggled`, `settingsRequested`, `seeked`. Handlers `onToggled`.
- Services expose **state as readonly properties** and **actions as verbs**: `Audio.volume`, `Audio.setVolume(v)`, `Network.toggle()`.
- Token access always through the singleton: `Theme.primary`, `Shape.full`, `Typography.labelMedium`, `Motion.spatialDefault`. Names equal M3 token names.
- IPC targets: lowercase module/service name: `config`, `controlcenter`, `launcher`, `osd`, `lock`, `powermenu`, `notifs`. Functions are verbs: `toggle`, `open`, `close`, `setAccent`.
- Config keys: lowercase camelCase, only those in SPEC (`accent`, `tiles`).
- Icons: Material Symbols names exactly as in the font (`wifi`, `bluetooth_connected`, `do_not_disturb_on`).

## Feature map — how a feature connects to everything
One row = one feature. If you add a feature, add its row here first.

| Feature | Module folder | Service(s) | Model(s) | IPC target | Persisted | Reference |
|---|---|---|---|---|---|---|
| Bar | `modules/bar` | `Time`, `Network`, `Bluetooth`, `Battery`, `Media`, `Keyboard`, `Modes`, `Notifs` (read-only) | `StatusPill.model.js`, `ClockPill.model.js` | — | — | 07, 10, 12 |
| Control center | `modules/controlcenter` | `Audio`, `Brightness`, `Network`, `Bluetooth`, `Modes`, `UiState` | `TileGrid.model.js` | `controlcenter` | tiles order in `Config` | 01, 05, 06, 07 |
| Notifications | `modules/notifications` | `Notifs`, `Modes` | `Grouping` (utils or local) | `notifs` | — | 08, 17 |
| Media | `modules/media` | `Media` | `MediaCard.model.js`, `WavyBar.model.js` | — | — | 10, 11 |
| Calendar | `modules/calendar` | `Time` | `Calendar.model.js` | — | — | 12 |
| Launcher | `modules/launcher` | `Apps` | `Fuzzy.js` (utils) | `launcher` | — | 13 |
| OSD | `modules/osd` | `Audio`, `Brightness` | — | `osd` | — | — |
| Lock | `modules/lock` | `Time`, `UiState`, `Quickshell.Services.Pam` | — | `lock` | — | 57, 18 |
| Power menu | `modules/powermenu` | `UiState`, `Power`, `Compositor` | `Power.model.js` | `powermenu` | — | 40 |

### Relations between features (allowed ways to talk)
```
Bar pill click ──► UiState.open("controlcenter")  ──► ControlCenter reacts
Notifs service ──► Bar NotifPill (badge)  /  NotifPopup (card)  /  NotifCenter (list)
Modes service  ──► ModesTile, DND icon in bar, Notifs (suppress popups)
Audio/Brightness ──► TopControls sliders  and  Osd (shows on change)
```
Features read services; features never read each other's components.
