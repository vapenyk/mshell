# 11 — Polish and cleanup

Follow the order in the [overview](00-OVERVIEW.md#how-to-work-a-step). Verify each behavior and change the implementation where the check reveals a problem. If a split requires a new file, list it and its consumer in the relevant sub-step first.

## 11.1 Motion and Control Center stutter

**Read** [MOTION.md](../design/MOTION.md), `config/Motion.qml`, `components/{PageStack,PopupWindow,AnchoredPopup}.qml`, `modules/controlcenter/{ControlCenter,TileGrid}.qml`, and `modules/controlcenter/pages/{MainPage,ModesPage}.qml`. Use the motion references linked from `MOTION.md`.

- [ ] Review the animation table for the implemented surfaces and tune the shared spring presets against the available references where needed.
- [ ] Reproduce Control Center stutter with real input when moving between the main page and Modes and when leaving tile edit mode. Inspect frame timing, panel resizing, and tile reflow. The prior height animation alone did not resolve the stutter.

**Done when** the motion pass covers the implemented surfaces and the affected Control Center paths run smoothly when repeated with the same input.

## 11.2 Responsive layout and keyboard navigation

**Read** [RESPONSIVE.md](../design/RESPONSIVE.md), sections 1–6 of [BEHAVIOR.md](../design/BEHAVIOR.md), and the [component catalogue](../design/COMPONENTS.md). Open the window and input files linked from the catalogue for any affected surface.

- [ ] Run the full output and scale matrix. Check output removal and reconnection with each implemented popup open.
- [ ] Test Tab order, visible focus, Escape dismissal, and arrow navigation in lists and grids.

**Done when** the tested popups fit the documented outputs, survive output changes, and follow their documented keyboard behavior.

## 11.3 Typography, accents, and optional shape

**Read** the typography, color, and shape sections of [TOKENS.md](../design/TOKENS.md), the scope table in [SPEC.md](../design/SPEC.md), `config/{Typography,Theme,Shape}.qml`, `components/{Text,Pill,Tile}.qml`, `modules/calendar/CalendarMonthGrid.qml`, and `modules/lock/LockSurface.qml`.

- [ ] Investigate text that appears above the visual center next to icons. Check fixed line height, font ascent and descent, and alignment in pills, icon-and-label rows, and calendar cells. Compare Latin and Cyrillic labels and digits. Address the shared cause where the comparison confirms a problem, then verify across typography roles and display scales.
- [ ] Switch through all nine existing presets in the sandbox. Check `onPrimary` on `primary` tiles and content contrast in the active pill state. Keep the dark scheme in use throughout.
- [ ] Optional. Try one scalloped or cookie accent on the lock clock or calendar's today marker if it suits the reference and context.

**Done when** the text alignment and contrast checks cover the stated cases and the optional shape has been evaluated.

## 11.4 Verification notes and cleanup

**Read** [TOKENS.md](../design/TOKENS.md), [MOTION.md](../design/MOTION.md), [RESPONSIVE.md](../design/RESPONSIVE.md), [BEHAVIOR.md](../design/BEHAVIOR.md), [REFERENCES.md](../design/REFERENCES.md), and [CODE-STYLE.md](../conventions/CODE-STYLE.md) for open verification notes. Read [LEAN.md](../conventions/LEAN.md), [NAMING.md](../conventions/NAMING.md), and [TESTING.md](../conventions/TESTING.md) for cleanup and completion. Inspect the specific files reported by the idle, size, and unused-file checks.

- [ ] Search the design and style files listed above for `verify` markers. Check design values against the linked M3 references and platform behavior against the documented API version or the nested compositor. Update each verified entry and remove its marker.
- [ ] Measure idle cost with all panels closed and verify CPU use is near zero. Check that hidden `FrameAnimation`s stop and that polling runs only where the feature needs it. Recheck after any correction.
- [ ] Check file budgets and unused files. Remove dead tokens and keep any split focused on the code that needs it. Update the feature map in `NAMING.md` where relationships changed.

**Done when** the verification results are recorded, the idle checks are complete, and the cleanup checks pass.

## Completion

- [ ] Run the runtime checks in the nested Hyprland sandbox described in [AGENTS.md](../../AGENTS.md). Confirm clean QML startup and recheck the affected reference, input, and output cases.
- [ ] Run `node --test "tests/**/*.test.js"` and `sh tools/unused.sh`. Confirm the file budgets and complete the checklist in `LEAN.md`.
- [ ] Tick the completed checks, update [00-OVERVIEW.md](00-OVERVIEW.md), and commit the step.
