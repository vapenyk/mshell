# STRUCTURE — where every file goes

```
mshell/
├── AGENTS.md
├── shell.qml                 entry point only: ShellRoot + Variants/Loader per module. No logic.
├── .qmlls.ini                empty; Quickshell fills it (editor LSP)
├── config/                   tokens + settings. Singletons.
│   ├── Config.qml            settings.json (accent, tiles order) via FileView+JsonAdapter; IPC `config`
│   ├── Theme.qml (+ .model.js)  colors of the selected accent, state opacities, sizeClass()
│   ├── Typography.qml        type roles
│   ├── Shape.qml             radius scale
│   ├── Motion.qml            springs, easing, durations
│   └── accents.json          generated once by tools/gen-accents.mjs
├── services/                 singletons that talk to the system. No UI, no layout.
├── components/               shared M3 building blocks. No `services` imports.
├── modules/                  features. One folder per feature. Own UI + local components + local models.
│   └── <feature>/
│       ├── <Feature>.qml          the module root (popup / window)
│       ├── *.qml                  parts local to this feature
│       ├── *.model.js             logic local to this feature
│       └── (pages/, tiles/, pills/ …)  only when a feature has many parts
├── utils/                    pure JS used by ≥2 models (Format.js, Fuzzy.js …). No QML.
├── tests/                    mirrors source paths: tests/<path>/<Name>.model.test.js
├── tools/                    dev scripts. Never imported by the shell.
├── assets/                   fonts (Roboto Flex, Material Symbols). Nothing else unless required.
└── docs/
```

User data (outside the repo): `~/.config/mshell/settings.json`. Nothing else is persisted unless a plan step says so.

## Dependency rules (hard)
```
modules  ──►  components  ──►  config
modules  ──►  services    ──►  config
modules  ──►  utils / own *.model.js
services ──►  utils
```
- `components/` never imports `services/` or `modules/`. Data comes in through properties, events go out through signals.
- `services/` never import `components/` or `modules/`.
- A module never imports another module. To affect another module: write to `UiState` or call IPC.
- `*.model.js` imports nothing from Quickshell/QtQuick. Only other pure JS (`utils/`).
- `shell.qml` composes modules and supplies their public properties, including content components. The host manages placement and gives focus to the content. The supplied component owns its internal actions and focus.
- `config/` supplies the shared container tokens. `Surface.qml` paints the background, shape, and optional shadow. Shared window components own placement and input, and modules supply the content and role. See the [container role catalogue](../design/COMPONENTS.md#container-roles).

## Decision table — "where does this go?"
| I'm writing… | Goes in |
|---|---|
| A number, color, radius, duration, font size | `config/` token file |
| Reading/writing system state (audio, wifi, battery, mpris, notifications) | `services/<Domain>.qml` |
| A reusable visual element with no system knowledge | `components/` (after a 2nd consumer, see LEAN) |
| A visual element used by one feature | that feature's folder |
| Which tiles are visible, sorting, grouping, formatting, fuzzy match, geometry math, date math | `<Name>.model.js` next to its QML (or `utils/` if shared) |
| "Which popup is open", edit mode, page stack state | `services/UiState.qml` |
| Calling an external program | `services/` via `Process`, argument array, never in a component |
| A one-off script for developers | `tools/` |

## One thing, one place
- One source of truth per fact. If `Network.enabled` exists, a tile never runs `nmcli` itself.
- A service is instantiated **once** (singleton). Never put `Process`/`Timer` polling inside something that is created per screen (`Variants`).
- Persisted settings only in `Config`. Transient UI state only in `UiState` or the component itself.
