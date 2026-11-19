# AGENTS.md

Quickshell shell, Material 3 Expressive, dark only, one user-picked accent.
Read this file, then ONLY the files your current task points to. Do not read all of `docs/`.

## Start here
1. `docs/plan/00-OVERVIEW.md` — find the first unchecked step.
2. Open that step file. Do that step only. Its "Read" list is your whole reading list.
3. When done: tick the TODOs, update the table in `00-OVERVIEW.md`, stop.

## Where things are
| Need | File |
|---|---|
| What we are building, what we are NOT | `docs/design/SPEC.md` |
| Colors, type, shape, motion, state numbers | `docs/design/TOKENS.md` |
| Springs, wavy bars, animation rules | `docs/design/MOTION.md` |
| Window sizes, scaling, popup placement | `docs/design/RESPONSIVE.md` |
| Layers, focus, open/close, keyboard, navigation, notification semantics | `docs/design/BEHAVIOR.md` |
| Component → M3 link → our file | `docs/design/COMPONENTS.md` |
| M3 links | `docs/design/REFERENCES.md` |
| Visual reference (screenshots) | `docs/design/reference/INDEX.md` |
| Folder layout, dependency rules | `docs/conventions/STRUCTURE.md` |
| Names, feature relations | `docs/conventions/NAMING.md` |
| QML style | `docs/conventions/CODE-STYLE.md` |
| Testing (`*.model.js`) | `docs/conventions/TESTING.md` |
| Anti-bloat rules | `docs/conventions/LEAN.md` |

## Hard rules
- Create only files listed in the current plan step. Need another file? Add it to the plan first.
- Every file must have a consumer by the end of its step. No speculative code.
- Logic that is not UI goes in `Name.model.js` with a test. QML only binds.
- Never hardcode color / radius / duration / font size. Use `Theme`, `Shape`, `Motion`, `Typography`.
- `components/` never imports `services/`. Modules never import other modules.
- Never touch matugen, light theme, or theming of other apps. Out of scope.

## Runtime sandbox
- Run Hyprland as a nested compositor in a dedicated development sandbox. Launch Quickshell inside the same sandbox and connect it to the nested Hyprland display.
- Give the sandbox its own writable configuration and runtime directories. Run `hyprctl` and Quickshell IPC commands from the sandbox so they target its instances.

## Commands
- Run in the sandbox: `qs -c mshell` (logs in the terminal; QML errors go to stderr)
- Tests: `node --test "tests/**/*.test.js"` (Node 22+)
- Unused-file check: `sh tools/unused.sh`
- IPC in the sandbox: `qs -c mshell ipc call <target> <fn>`
