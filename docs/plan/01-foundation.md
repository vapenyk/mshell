# 01 — Foundation
Goal: shell starts, settings load, tokens exist, a themed clock shows. Nothing else.

## 1.1 Skeleton
- Read: `../conventions/STRUCTURE.md`, `../conventions/CODE-STYLE.md` (imports section)
- Create: `shell.qml`, `.qmlls.ini` (empty)
- Update: `tools/unused.sh` to skip source directories that later steps have yet to create.
- [x] Start a nested Hyprland in the development sandbox described in `AGENTS.md`. Record the commands to start and stop it in the `Commands` section there.
- [x] `shell.qml`: `ShellRoot {}` with nothing in it
- [x] In the same sandbox, `qs -c mshell` connects to the nested Hyprland display, stays alive, and emits no stderr
- [x] Check which import style works (`import qs.config` vs relative) and whether a relative `import "x.js" as X` works; write the result into the **verify** lines of `CODE-STYLE.md`
- Done when: the sandbox startup and shutdown commands are documented, Quickshell runs on the nested Hyprland display, and the CODE-STYLE verify lines are updated

## 1.2 Config
- Read: `../design/SPEC.md` (behaviour rules → Accent), `../conventions/NAMING.md` (IPC)
- Create: `config/Config.qml`
- Update: `shell.qml` to initialize Config at startup so its IPC handler is available.
- [x] Singleton; `FileView` + `JsonAdapter` on `~/.config/mshell/settings.json` with `accent: "blue"`, `tiles: []`. Honor `XDG_CONFIG_HOME` for the development sandbox.
- [x] Missing file → create with defaults (`onLoadFailed` / FileNotFound)
- [x] `IpcHandler { target: "config"; function setAccent(name: string): void }` writes the value
- [x] Watch the file so manual edits apply live
- Done when: `qs -c mshell ipc call config setAccent green` changes the file and `Config.accent`

## 1.3 Theme
- Read: `../design/TOKENS.md` (Color, State layers), `../design/RESPONSIVE.md` (size classes)
- Create: `config/Theme.qml`, `config/Theme.model.js`, `tests/config/Theme.model.test.js`
- Update: `shell.qml` to initialize Theme at startup and load Config through it.
- [x] Model: `pickScheme(accents, name)` (unknown name → `blue`), `sizeClass(width)` per RESPONSIVE
- [x] Theme loads `config/accents.json` via `FileView` with `blockLoading: true`. Verified `Quickshell.shellPath` under Quickshell 0.3.2 from outside the shell directory.
- [x] Expose each color role in TOKENS as a read-only color from the selected scheme. Use aliases for the `on*` roles to avoid QML's signal handler syntax.
- [x] `stateHover/Focus/Pressed/Dragged` opacity properties
- [x] Tests: unknown accent fallback, all roles present, size class boundaries (599/600/839/840/1199/1200/1599/1600)
- Done when: tests pass; changing `Config.accent` changes `Theme.primary` live

## 1.4 Typography, Shape, Motion
- Read: `../design/TOKENS.md` (Typography, Shape), `../design/MOTION.md`
- Create: `config/Typography.qml`, `config/Shape.qml`, `config/Motion.qml`, `assets/fonts/` (only if fonts are not installed system-wide)
- Update: `shell.qml` to load the token singletons at startup and `../design/MOTION.md` to record the verified Qt easing enum.
- [x] Typography: every role as an object `{ size, lineHeight, weight }` + `family`
- [x] Shape: radius scale as properties
- [x] Motion: durations, easing curves as `[x1,y1,x2,y2,1,1]` arrays, spring presets (`spring`, `damping`, `mass`) for the six tokens (rough values; tuned in step 09)
- [x] Fonts present (see open questions); fallbacks set
- Done when: files load without errors; every token in the docs has a property; no value in the docs is missing

## 1.5 Time + first bar
- Read: `../conventions/NAMING.md` (feature map: Bar), `../design/TOKENS.md` (Sizing)
- Create: `services/Time.qml`, `utils/Format.js`, `tests/utils/Format.test.js`, `modules/bar/Bar.qml`
- [ ] `Time`: `SystemClock`, exposes `date` (updates per minute)
- [ ] `Format.js`: `clock(date, use24h)`, `dateShort(date)` (e.g. "Mon 12 Oct") — pure, tested
- [ ] `Bar.qml`: `Variants` over screens, `PanelWindow` top, transparent, height per TOKENS, shows the formatted time with `Theme.onSurface` (temporary plain text; replaced by `ClockPill` in 02/03)
- [ ] `shell.qml` loads `Bar`
- Done when: bar window on every screen shows the time; `setAccent` does not break it; tests pass; `sh tools/unused.sh` clean
