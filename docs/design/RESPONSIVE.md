# RESPONSIVE — what "responsive" means for a shell

A shell does not reflow like a web page. It must survive: different screen sizes and scale factors, multiple monitors, hot-plug, and long/short content. M3 window size classes are used as the vocabulary.

## Units
1 dp = 1 logical px. Never read `devicePixelRatio`. Never use screen-percent sizes for popups; use dp from `TOKENS.md`.
Icons and fonts are scaled by the compositor. Raster assets: avoid; use Material Symbols.

## Size classes (by the **screen's logical width**) `verify`
| Class | Width dp |
|---|---|
| compact | < 600 |
| medium | 600 – 839 |
| expanded | 840 – 1199 |
| large | 1200 – 1599 |
| extraLarge | ≥ 1600 |

`Theme.sizeClass(screen)` returns the name (logic in `Theme.model.js`, tested). Only a few things depend on it:

| Element | compact | medium | expanded+ |
|---|---|---|---|
| Bar | pills shrink: media pill icon-only, clock without date | media pill text capped 160 dp | media pill text capped 240 dp |
| Control center width | screen width − 16 (max 400) | 400 | 400 |
| Notification popup width | screen width − 16 (max 400) | 400 | 400 |
| Launcher | 1 column list, no grid | grid 4 cols | grid 6 cols, 560 dp wide |
| Calendar | 320 wide | 360 | 360 |
| OSD width | screen width − 16 (max 296) | 296 | 296 |
| Lock clock | headlineLarge-ish scale 0.5 | 0.75 | 1.0 |

If a screen is wider than `extraLarge`, do not grow anything; popups stay the same size.

## Multi-monitor
- `Bar` is a `Variants` over `Quickshell.screens`; one bar per screen.
- Popups, launcher, and notification popups appear on the **focused** screen (from `Compositor`), anchored to the pill that opened them where applicable.
- The OSD resolves the focused display for each IPC action or ASUS keyboard backlight event that opens or extends it.
- Lock covers every screen.
- Hot-plug must not crash or duplicate: all per-screen state lives in the per-screen component, all system state in services.

## Popup placement
1. Anchor under the pill, aligned to the pill's nearer screen edge. Center the keyboard layout picker under its pill.
2. If it would overflow horizontally, shift to fit with 8 dp margin.
3. If it would overflow vertically, cap height at `screen height − bar − 16` and scroll the content (`Flickable`), never shrink typography.
4. Popup content has `implicitWidth` from tokens and grows in height by content.
5. The OSD is horizontally centered with a 16 dp margin from the bottom edge of the focused screen.

## Content robustness (the "responsive" that actually breaks)
- Every `Text` that can be long: `elide: Text.ElideRight`, `maximumLineCount`, and a fixed container width.
- Media title in the pill: fixed max width, marquee scroll only while hovered (optional), otherwise elide.
- Lists use `ListView`/`Repeater` with `ScriptModel`; empty states are designed (notification center empty, no tiles, no Bluetooth device).
- Tile grid: column count is fixed at 4; if popup width < 320 (extreme compact) drop to 2 columns (large span stays 2 → full width, small span 1). Logic in `TileGrid.model.js` (`columnsFor(width)`, `spanWidth(span, cols, cell, gap)`).
- Missing hardware/service → element hidden, never shown broken.

## Test matrix (manual, at each step's "Done when")
Run with these outputs/scales; check nothing clips or overlaps:
- 1920×1080 @1.0
- 2560×1440 @1.5
- 1366×768 @1.0 (small laptop)
- A second monitor plugged/unplugged while a popup is open
