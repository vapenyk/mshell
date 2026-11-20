# CODE-STYLE — QML in this project

Items marked **verify** depend on your Quickshell version; check once on first use, then record the result in the line and remove the mark.

## Files
- Imports in this order, blank line between groups: local (`import qs.config`, `import qs.services`, `import qs.components`), then `Quickshell.*`, then `Qt*`. Quickshell 0.3.2 resolves both `import qs.config` and `import "../config"` for a config singleton. Use `qs.<folder>` for shared project directories.
- Add `pragma ComponentBehavior: Bound` to any file with `component` definitions or delegates that reference outer ids.
- Singletons: `pragma Singleton`, root `Singleton {}`, capitalized filename.
- ≤ 200 lines per QML file, ≤ 150 per model, ≤ 30 per function. If it grows, move logic to a model or split a part out.

## Logic vs UI
- A binding longer than ~3 lines of logic, any loop, sort, filter, grouping, formatting, geometry or date math → function in the `*.model.js`. QML only binds and calls it.
- Import a model with `import "Foo.model.js" as Model` and call it with `Model.fn(x)`. Relative JavaScript imports with `.pragma library` resolve under Quickshell 0.3.2.
- Model files start with `.pragma library` and use only `function` declarations and `var` (so the Node test harness can load them). No state in models; pass everything in as arguments.

## Typing and null safety
- Annotate all function parameters and return types: `function setVolume(v: real): void`.
- Use `?.` and `??` on every nullable Quickshell object (`sink?.audio?.volume ?? 0`).
- `required property` for delegate data, `readonly property` for derived values.

## Signals and reactions
- `Connections { target: X; function onY(): void { } }` — the function form, not `onY:`.
- Avoid two-way bindings; break loops with explicit handlers.
- `HoverHandler` → `hovered`. `MouseArea` → `containsMouse`. Not interchangeable.

## System access
- `Process.command` is always an array. Read output in `StdioCollector.onStreamFinished` or `SplitParser.onRead`.
- All `Process`, `Timer` polling, DBus, Pipewire access lives in `services/`, instantiated once. Never inside a `Variants` delegate.
- Pipewire: add `PwObjectTracker { objects: [...] }` for nodes you hold.
- Fire-and-forget: `Quickshell.execDetached([...])`.
- Anything needing platform menus: `//@ pragma UseQApplication` and a restart.

## Windows and loading
- Per-screen things: `Variants { model: Quickshell.screens }` with `required property ShellScreen modelData`.
- Windows (`PanelWindow`, `PopupWindow`) created on demand: `LazyLoader { active: … }`. Plain items: `Loader`.
- Lists from JS arrays: `ScriptModel { values: … ; objectProp: "id" }` so delegates survive updates.
- Persist across `--reload` only if a step says so: `PersistentProperties { reloadableId: "…" }`.

## Don'ts
- No commented-out code. No TODO comments (TODOs live in `docs/plan`).
- No "just in case" properties, signals, or config keys.
- No console.log left behind (use during work, remove before ticking the step).
- No duplicated token values anywhere outside `config/`.
