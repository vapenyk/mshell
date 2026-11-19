# SPEC — what we are building

Target: Arch Linux, Hyprland, Quickshell 0.3.2, brightness via brightnessctl.

A desktop shell on Quickshell, styled as a **cut-down Material 3 Expressive**.
Visual and behavioural reference: `reference/` (screenshots of Googlebook OS, used for layout and behaviour only; do not copy their assets or branding).

## Principles
1. **Ready-made, not invented.** Every visual decision comes from M3 (`REFERENCES.md`) or the screenshots. If neither answers it, pick the simplest M3-consistent option and write it in `TOKENS.md`.
2. **One look.** Dark scheme only. The user picks one accent color from presets. Nothing else is configurable.
3. **Expressive where it pays.** Springs, large rounded shapes, wavy progress/seek bars. Not decoration everywhere.
4. **Lean.** Every line has a consumer. See `../conventions/LEAN.md`.
5. **The shell is the shell.** It does not theme other apps, does not run matugen, does not generate palettes at runtime.

## Scope
| In | Out (not planned) | Later (backlog, no plan file yet) |
|---|---|---|
| Bar (pills) | Light theme | Dock |
| Control center | Dynamic wallpaper palette | Screenshot / record toolbar |
| Notifications (popup + center) | Tile add/remove/resize | Settings window |
| Media pill + card | Theming other apps | Desktop widgets |
| Calendar popup | Multi-compositor abstraction until needed | Expressive cookie/scalloped shapes beyond one |
| Launcher | Per-module config | |
| OSD (volume, brightness) | | |
| Lock screen, power menu | | |

## Behaviour rules (decided)
- **Accent:** `accent` in `~/.config/mshell/settings.json`, one of the names in `config/accents.json`. Changing it recolors live. Also settable via `qs ipc call config setAccent <name>`.
- **Control center:**
  - Fixed top block: brightness slider + volume slider, each with one round button next to it (night mode, mixer). These never move.
  - Below: tile grid. The set of tiles and their sizes are defined in code (`TileRegistry`). The user can change **order only**. Layout is automatic (`Flow`).
  - Tile **left click** toggles the service. Tile **right click** opens that tile's settings page inside the same popup (`PageStack`, back button in the header).
  - Tiles whose hardware is missing are not shown.
- **Bar:** pills along the top, not a solid strip. Status icons (Wi-Fi, Ethernet, Bluetooth, DND, battery) show **only when active/relevant** (connected, on, charging...). Wi-Fi and Ethernet each have their own icon and can both appear at once. Bluetooth appears when at least one Bluetooth device is connected, so all three connection icons can appear together. Nothing active → status pill hidden. Media pill appears only while a player exists.
- **Popups** open under their pill, close on outside click or Escape, one open at a time (`UiState`).
- **Notifications:** popup card on arrival; center groups by app, sections Alerting/Silent, "Clear all", DND respected.

## Definition of done for any element
- Matches its reference screenshot in structure and M3 token usage.
- Uses only tokens (`TOKENS.md`), no literals.
- Hover / focus / press states via `StateLayer`.
- Open/close/toggle transitions follow `MOTION.md`.
- Works at the sizes in `RESPONSIVE.md`.
- Logic lives in a `*.model.js` with a passing test; `sh tools/unused.sh` is clean.
