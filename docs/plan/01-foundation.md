# 01 — Foundation
Goal: shell starts, settings load, tokens exist, a themed clock shows. Nothing else.

## 1.1 Skeleton
- Read: `../conventions/STRUCTURE.md`, `../conventions/CODE-STYLE.md` (imports section)
- Create: `shell.qml`, `.qmlls.ini` (empty)
- [ ] Start a nested Hyprland in the development sandbox described in `AGENTS.md`. Record the commands to start and stop it in the `Commands` section there.
- [ ] `shell.qml`: `ShellRoot {}` with nothing in it
- [ ] In the same sandbox, `qs -c mshell` connects to the nested Hyprland display, stays alive, and emits no stderr
- [ ] Check which import style works (`import qs.config` vs relative) and whether a relative `import "x.js" as X` works; write the result into the **verify** lines of `CODE-STYLE.md`
- Done when: the sandbox startup and shutdown commands are documented, Quickshell runs on the nested Hyprland display, and the CODE-STYLE verify lines are updated

## 1.2 Config
- Read: `../design/SPEC.md` (behaviour rules → Accent), `../conventions/NAMING.md` (IPC)
- Create: `config/Config.qml`
- [ ] Singleton; `FileView` + `JsonAdapter` on `~/.config/mshell/settings.json` with `accent: "blue"`, `tiles: []`
- [ ] Missing file → create with defaults (`onLoadFailed` / FileNotFound)
- [ ] `IpcHandler { target: "config"; function setAccent(name: string): void }` writes the value
- [ ] Watch the file so manual edits apply live
- Done when: `qs -c mshell ipc call config setAccent green` changes the file and `Config.accent`

## 1.3 Theme
- Read: `../design/TOKENS.md` (Color, State layers), `../design/RESPONSIVE.md` (size classes)
- Create: `config/Theme.qml`, `config/Theme.model.js`, `tests/config/Theme.model.test.js`
- [ ] Model: `pickScheme(accents, name)` (unknown name → `blue`), `sizeClass(width)` per RESPONSIVE
- [ ] Theme loads `config/accents.json` (`FileView`, `blockLoading: true`, path via `Quickshell.shellPath` — **verify**)
- [ ] One `readonly property color` per role in TOKENS (all roles, from the picked scheme)
- [ ] `stateHover/Focus/Pressed/Dragged` opacity properties
- [ ] Tests: unknown accent fallback, all roles present, size class boundaries (599/600/839/840/1199/1200/1599/1600)
- Done when: tests pass; changing `Config.accent` changes `Theme.primary` live

## 1.4 Typography, Shape, Motion
- Read: `../design/TOKENS.md` (Typography, Shape), `../design/MOTION.md`
- Create: `config/Typography.qml`, `config/Shape.qml`, `config/Motion.qml`, `assets/fonts/` (only if fonts are not installed system-wide)
- [ ] Typography: every role as an object `{ size, lineHeight, weight }` + `family`
- [ ] Shape: radius scale as properties
- [ ] Motion: durations, easing curves as `[x1,y1,x2,y2,1,1]` arrays, spring presets (`spring`, `damping`, `mass`) for the six tokens (rough values; tuned in step 09)
- [ ] Fonts present (see open questions); fallbacks set
- Done when: files load without errors; every token in the docs has a property; no value in the docs is missing

## 1.5 Time + first bar
- Read: `../conventions/NAMING.md` (feature map: Bar), `../design/TOKENS.md` (Sizing)
- Create: `services/Time.qml`, `utils/Format.js`, `tests/utils/Format.test.js`, `modules/bar/Bar.qml`
- [ ] `Time`: `SystemClock`, exposes `date` (updates per minute)
- [ ] `Format.js`: `clock(date, use24h)`, `dateShort(date)` (e.g. "Mon 12 Oct") — pure, tested
- [ ] `Bar.qml`: `Variants` over screens, `PanelWindow` top, transparent, height per TOKENS, shows the formatted time with `Theme.onSurface` (temporary plain text; replaced by `ClockPill` in 02/03)
- [ ] `shell.qml` loads `Bar`
- Done when: bar window on every screen shows the time; `setAccent` does not break it; tests pass; `sh tools/unused.sh` clean
