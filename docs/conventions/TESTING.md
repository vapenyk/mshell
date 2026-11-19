# TESTING — QML is hard to test, so keep logic out of it

## The pattern
`Thing.qml` = layout, bindings, animation. `Thing.model.js` = every decision and calculation. The model is plain JS, tested with Node. QML is verified by running the shell and comparing with the reference screenshot.

### What must be a model (with a test)
- Tile visibility, order, move, columns/spans (`TileGrid.model.js`)
- Slider value ↔ position, clamping, stepping (`ValueSlider.model.js`)
- Wave geometry (`WavyBar.model.js`)
- Notification grouping/sorting/sections (`Grouping.js` / local model)
- Calendar grid (weeks, padding days, today) (`Calendar.model.js`)
- Fuzzy search ranking (`Fuzzy.js`)
- Clock/date/duration/percent formatting (`Format.js`)
- Which status icons are visible (`StatusPill.model.js`)
- Accent pick + fallback, size class from width (`Theme.model.js`)

### What does not need a model
Pure layout and bindings with no branching. Don't create a model for `Item { width: 24 }`.

## Model file rules
```js
.pragma library
// pure functions only; no imports from Quickshell/QtQuick; no state
function clamp(v, lo, hi) { return Math.max(lo, Math.min(hi, v)); }
```
- Only top-level `function` and `var` (no `const`/`let`/`class`/`import`/`export`).
- Inputs → output. No `Date.now()` inside: pass `now` as an argument.
- Return plain data (arrays/objects/numbers/strings).

## Using a model from QML
```qml
import "TileGrid.model.js" as Model
...
readonly property var visibleTiles: Model.visibleTiles(Config.tiles, TileRegistry.defs, Hardware.flags)
```

## Test harness (already in `tests/load.js`)
```js
const { test } = require("node:test");
const assert = require("node:assert/strict");
const { loadModel } = require("../../load.js");           // adjust depth to the test's location
const m = loadModel("modules/controlcenter/TileGrid.model.js");

test("moves a tile left", () => {
  assert.deepEqual(m.move(["a", "b", "c"], 2, 0), ["c", "a", "b"]);
});
```
Run all: `node --test "tests/**/*.test.js"` (Node 22+).
`loadModel` strips `.pragma library` and evaluates the file in a sandbox; functions become properties of the returned object.

## Test file layout
`tests/<same relative path as the model>/<Name>.model.test.js`. One test file per model. Cover: normal case, empty input, boundary, one bad input.

## Manual checks for QML (every step's "Done when")
1. `qs -c mshell` starts with no errors on stderr.
2. Compare with the named screenshot in `design/reference/`.
3. Hover, press, focus (Tab), disabled look right.
4. Resize/scale matrix from `RESPONSIVE.md`.
5. `sh tools/unused.sh` prints nothing.
6. Tests pass.

## Optional
- `qmllint` over changed files if installed.
- IPC smoke: `qs -c mshell ipc call <target> <fn>` for modules with IPC.
