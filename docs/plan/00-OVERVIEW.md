# PLAN — overview

Work in **small steps**. One step = one sitting = one commit. Read only the files the step lists.

## How to work a step
1. Open the first step below that is not ✅. Open its file; do the first unchecked sub-step.
2. Read only that sub-step's **Read** list.
3. Create only the files in its **Create** list.
4. Run its **Done when** checks. Fix, don't extend.
5. Tick the checkboxes, update this table, run the end-of-step checklist in `../conventions/LEAN.md`, commit, stop.

## Progress
| # | File | What | Status |
|---|---|---|---|
| 01 | `01-foundation.md` | skeleton, config, tokens, clock | ✅ |
| 02 | `02-base-components.md` | StateLayer, Icon, Text, Surface, Pill | ✅ |
| 03 | `03-bar.md` | bar, clock pill, status pill, services | ✅ |
| 04 | `04-control-center.md` | popup, sliders, tiles, pages, reorder | ✅ |
| 05 | `05-notifications.md` | service, popup, center, bell pill | ✅ |
| 06 | `06-media-calendar-keyboard.md` | media, wavy bar, calendar, keyboard | ✅ Calendar and keyboard · media deferred |
| 07 | `07-launcher-osd.md` | launcher, OSD | 7.3 IPC OSD ✅ · launcher pending |
| 08 | `08-lock-powermenu.md` | lock, power menu | ✅ |
| 09 | `09-polish.md` | motion tuning, responsive pass, cleanup | ⬜ |

Backlog (no plan yet, don't start): dock, screenshot toolbar, settings window, desktop widgets.

Media steps 6.1–6.4 remain deferred. Launcher work starts with the design discussion in step 07.

Backlog references: dock and desktop widgets [21](../design/reference/21-desktop-bar-widgets-dock.webp), menus [24](../design/reference/24-menu-context.webp) and [25](../design/reference/25-menu-overflow.webp), settings window [26](../design/reference/26-settings-window-dark.webp), window chrome and snackbars [27](../design/reference/27-app-windows-snackbar-fab.webp).

## Open questions (answer before the step that needs them)
| Question | Needed by | Answer |
|---|---|---|
| Which compositor do you run (Hyprland / Niri / Sway / other)? | 05.3 (focused screen), 06.6 (keyboard layout) | **Hyprland 0.57.2** (Arch). Use `Quickshell.Hyprland`; no compositor abstraction |
| Quickshell version? Native `Networking` / `Bluetooth` modules available? | 03.2 | **Quickshell 0.3.2.** Verified `Quickshell.Networking`, `Quickshell.Bluetooth`, and `Quickshell.Services.UPower` in the nested sandbox. |
| Are Roboto Flex and Material Symbols Rounded installed? | 01.4 | **Yes.** Both are system fonts and available to Quickshell. Text falls back to Roboto, then system sans-serif. |
| Brightness backend? Night-light tool? | 04.4 | **brightnessctl** for the backlight and **hyprsunset** for night light. |
| Notification daemons already running (mako, dunst, swaync)? They must be stopped | 05 | |

## Extra reading by step type
- Any step that creates a window or popup (04.1, 05.3, 05.3b, 06.2, 06.4, 06.5, 06.6, 07.2, 07.3, 08.2, 08.3): also read `../design/BEHAVIOR.md` sections 1, 2 and the row for that surface in 6.
- Any step with page navigation (04.2, 04.9+): `../design/BEHAVIOR.md` section 3.
- Any step with keyboard or pointer input: sections 4 and 5.
- Notification steps (05): section 7.

## Rules for everyone
`../../AGENTS.md` hard rules + `../conventions/LEAN.md`. When in doubt, do less.
