# TOKENS — the only source of numbers

Units: **1 dp = 1 logical pixel**. Qt and Wayland apply display scaling to logical geometry.
Anything marked `verify` was written from memory of the M3 spec; check once against `REFERENCES.md`, then delete the mark.
Anything marked `project` is our decision, not M3.

## Color
Dark scheme, role names identical to M3. Values come from `config/accents.json` (generated once by `tools/gen-accents.mjs`, one object per accent). `Theme.qml` exposes the selected accent's roles as `Theme.<role>`.

Roles in use: `primary onPrimary primaryContainer onPrimaryContainer secondary onSecondary secondaryContainer onSecondaryContainer tertiary onTertiary tertiaryContainer onTertiaryContainer error onError errorContainer onErrorContainer background onBackground surface onSurface surfaceVariant onSurfaceVariant surfaceDim surfaceBright surfaceContainerLowest surfaceContainerLow surfaceContainer surfaceContainerHigh surfaceContainerHighest outline outlineVariant inverseSurface inverseOnSurface inversePrimary shadow scrim surfaceTint`.

Accents: `blue violet pink red orange yellow green teal mono`. Default `blue`.

### Which role for what (shell mapping, `project`)
The [component catalogue](COMPONENTS.md#container-roles) maps roles to their implementation. [Behavior](BEHAVIOR.md#1-surfaces-and-layers) covers layers, focus, and dismissal.

| Role | Container | Shape | Content |
|---|---|---|---|
| Panel | `surfaceContainer`. The inline power dropdown adds an `outlineVariant` border at `Sizing.outlineWidth`. | `Shape.extraLarge` | `onSurface` |
| Card | `surfaceContainerHigh` | `Shape.large`. Joined corners in expanded notification groups use `Shape.extraSmall`. | `onSurface`. Notification toasts use the same Card. |
| Tile | Inactive `surfaceContainerHigh`, active `primary` | `Shape.extraLarge` | Inactive `onSurface` with `onSurfaceVariant` subtitle, active `onPrimary` |
| Bar Pill | Idle `transparent`, active or pressed `secondaryContainer` | `Shape.full` | Idle `onSurface`, active or pressed `onSecondaryContainer` |
| OSD | `surfaceContainer` | `Shape.full` | Shared slider tokens |
| Dialog | `surfaceContainerHigh` with a separate `scrim` at 32% | `Shape.extraLarge` | `onSurface`, with `onSurfaceVariant` supporting text |

| Element | Container | Content |
|---|---|---|
| Tile icon chip on | `primaryContainer` | `onPrimaryContainer` ([Material 3 color roles](https://m3.material.io/styles/color/the-color-system/)) |
| Slider active track | `primary` | handle marker `primary` |
| Slider inactive track | `surfaceContainerHighest` | icon `onSurfaceVariant` |
| Selected list row | `secondaryContainer` | `onSecondaryContainer` (screenshot 09) |
| Filled button | `primary` | `onPrimary` |
| Tonal button | `secondaryContainer` | `onSecondaryContainer` |
| Outlined button | transparent, border `outline` | `primary` |
| Plain tooltip | `inverseSurface` | `inverseOnSurface` |
| Destructive | `errorContainer` | `onErrorContainer` |
| Notification unread dot | `tertiary` | |
| Shared text field | `surfaceContainerLowest` | `onSurface`, placeholder `onSurfaceVariant`, focus outline `primary` |

## State layers (`State.qml` values live in `Theme.qml`)
| State | Opacity of content-color overlay |
|---|---|
| hover | 0.08 |
| focus | 0.10 |
| pressed | 0.10 |
| dragged | 0.16 |
| disabled content | 0.38 (container 0.12) |

Overlay color = the component's **content** color (`onSurface`, `onPrimary`, ...).

## Typography (`Typography.qml`)
Family: Roboto Flex if installed (variable, enables expressive weights), else Roboto, else system sans. Size/line height in dp. `verify`
| Role | Size / line | Weight |
|---|---|---|
| displayLarge | 57 / 64 | 400 |
| displayMedium | 45 / 52 | 400 |
| displaySmall | 36 / 44 | 400 |
| headlineLarge | 32 / 40 | 400 |
| headlineMedium | 28 / 36 | 400 |
| headlineSmall | 24 / 32 | 400 |
| titleLarge | 22 / 28 | 400 |
| titleMedium | 16 / 24 | 500 |
| titleSmall | 14 / 20 | 500 |
| bodyLarge | 16 / 24 | 400 |
| bodyMedium | 14 / 20 | 400 |
| bodySmall | 12 / 16 | 400 |
| labelLarge | 14 / 20 | 500 |
| labelMedium | 12 / 16 | 500 |
| labelSmall | 11 / 16 | 500 |

Lock-screen clock (screenshot 18) uses a project role `clockHuge`: 120 / 112, weight 500, two stacked lines (HH over MM).

Bar pills use `labelLarge`.

Lock uses an opaque gradient from `surfaceContainer` to `surface` as its fallback. A supplied wallpaper uses the `lockBackgroundBlur` radius and `lockWallpaperScrimOpacity` over the image.

## Shape (`Shape.qml`) — corner radius scale, dp `verify`
`none 0 · extraSmall 4 · small 8 · medium 12 · large 16 · largeIncreased 20 · extraLarge 28 · extraLargeIncreased 32 · extraExtraLarge 48 · full 9999`

| Thing | Radius |
|---|---|
| Button, IconButton, Search bar | full (pill) |
| Tile icon chip | `large` square-ish (screenshot 07) |
| Tooltip | small |

## Elevation
Cards, Tiles, and bar Pills establish hierarchy through their container fills. Popup shadows use `Theme.popupShadow` (`shadow` at 24%, blur 24, y offset 8). `project`

## Sizing (`project`)
| Thing | Size |
|---|---|
| Bar window height | 44 |
| Pill height | 32; min width 32 (icon only) |
| Pill horizontal padding | 8 (pills with text or trailing content) |
| Pill gap | 6 |
| Bar side margin | 8 |
| Popup gap below bar | 8 |
| Control Center, notification center, and toast max width | 400 (see RESPONSIVE) |
| Power menu width | 184 |
| Confirmation dialog max width | 360 |
| Popup inner padding | 16 |
| Notification avatar and app badge | 40 and 18 |
| Notification thumbnail and expanded preview | 56 × 40 thumbnail, preview max height 200 |
| Notification reply field and Send target | 48 high, field radius full |
| Calendar day row height and marker size | 44 and 36 |
| Keyboard layout row height | 52 |
| Lock password field | 320 max width × 48 high |
| Tile height and icon chip size | 64 and 48 |
| Tile grid | 4 columns, gap 8; large = 2 cols, small = 1 col |
| Slider and default button height | 40 |
| Slider handle and track gap | 4 wide, 2 while pressed, 4 gap on each side at rest |
| Stepped track and stops | 16 track height, 4 stop diameter, 12 minimum spacing between displayed stops |
| OSD pill | 296 max width, 56 height, 8 padding, 16 bottom margin |
| Switch track | 52 × 32 |
| Icon size | 24 (inside pills/buttons: 20) |
| Min pointer target | 32 |
| Icon set | Material Symbols Rounded, variable font, FILL 0/1 for off/on |

## Z-order of layers
`background < bar < popups < notification popups < osd < lock`.
