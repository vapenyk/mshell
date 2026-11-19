# TOKENS — the only source of numbers

Units: **1 dp = 1 logical pixel** (Wayland already scales; never multiply by devicePixelRatio).
Anything marked `verify` was written from memory of the M3 spec; check once against `REFERENCES.md`, then delete the mark.
Anything marked `project` is our decision, not M3.

## Color
Dark scheme, role names identical to M3. Values come from `config/accents.json` (generated once by `tools/gen-accents.mjs`, one object per accent). `Theme.qml` exposes the selected accent's roles as `Theme.<role>`.

Roles in use: `primary onPrimary primaryContainer onPrimaryContainer secondary onSecondary secondaryContainer onSecondaryContainer tertiary onTertiary tertiaryContainer onTertiaryContainer error onError errorContainer onErrorContainer background onBackground surface onSurface surfaceVariant onSurfaceVariant surfaceDim surfaceBright surfaceContainerLowest surfaceContainerLow surfaceContainer surfaceContainerHigh surfaceContainerHighest outline outlineVariant inverseSurface inverseOnSurface inversePrimary shadow scrim surfaceTint`.

Accents: `blue violet pink red orange yellow green teal mono`. Default `blue`.

### Which role for what (shell mapping, `project`)
| Thing | Container | Content |
|---|---|---|
| Popup / panel background | `surfaceContainer` | `onSurface` |
| Card inside popup | `surfaceContainerHigh` | `onSurface` |
| Bar pill (idle) | `surfaceContainerHigh` | `onSurface` |
| Bar pill (popup open / pressed) | `secondaryContainer` | `onSecondaryContainer` |
| Tile off | `surfaceContainerHigh` | `onSurface`, subtitle `onSurfaceVariant` |
| Tile on | `primary` | `onPrimary` |
| Tile icon chip on | `primaryContainer`-ish darker/lighter step of `primary` | `onPrimary` (see screenshot 01, 07) |
| Slider active track | `primary` | handle marker `primary` |
| Slider inactive track | `surfaceContainerHighest` | icon `onSurfaceVariant` |
| Selected list row | `secondaryContainer` | `onSecondaryContainer` (screenshot 09) |
| Filled button | `primary` | `onPrimary` |
| Tonal button | `secondaryContainer` | `onSecondaryContainer` |
| Outlined button | transparent, border `outline` | `primary` |
| Destructive | `errorContainer` | `onErrorContainer` |
| Scrim behind dialogs | `scrim` @ 32% | |
| Notification unread dot | `tertiary` | |

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

## Shape (`Shape.qml`) — corner radius scale, dp `verify`
`none 0 · extraSmall 4 · small 8 · medium 12 · large 16 · largeIncreased 20 · extraLarge 28 · extraLargeIncreased 32 · extraExtraLarge 48 · full 9999`

| Thing | Radius |
|---|---|
| Popup / panel | extraLarge |
| Card | large |
| Tile, Pill, Button, IconButton, Search bar | full (pill) — tiles may use `extraLarge` if 64 dp tall looks too round |
| Tile icon chip | `large` square-ish (screenshot 07) |
| List group, first/last item | large; inner items `extraSmall` (screenshot 02) |
| Dialog | extraLarge |
| Tooltip | small |

## Elevation
Dark theme: express elevation with **surface container steps**, not shadows.
Popup `surfaceContainer` over wallpaper; cards `surfaceContainerHigh`. A soft shadow (`shadow` @ 24%, blur 24, y 8) is allowed on popups only. `project`

## Sizing (`project`)
| Thing | Size |
|---|---|
| Bar window height | 44 (4 margin around pills) |
| Pill height | 32; min width 32 (icon only) |
| Pill gap | 6 |
| Bar side margin | 8 |
| Popup gap below bar | 8 |
| Control center width | 400 (see RESPONSIVE) |
| Popup inner padding | 16 |
| Tile height | 64 |
| Tile grid | 4 columns, gap 8; large = 2 cols, small = 1 col |
| Slider height | 40 |
| Icon size | 24 (inside pills/buttons: 20) |
| Min pointer target | 32 |
| Icon set | Material Symbols Rounded, variable font, FILL 0/1 for off/on |

## Z-order of layers
`background < bar < popups < notification popups < osd < lock`.
