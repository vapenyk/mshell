const assert = require("node:assert/strict");
const test = require("node:test");
const { loadModel } = require("../../load.js");

const { visibleTiles, columnsFor, spanWidth, move, reorderVisible } = loadModel("modules/controlcenter/TileGrid.model.js");

const defs = {
    wifi: { available: true },
    bluetooth: { available: false },
    modes: { available: true },
    mic: { available: true },
};

test("uses the default order for an empty config and hides unavailable tiles", () => {
    assert.deepEqual(visibleTiles([], defs), ["wifi", "modes", "mic"]);
    assert.deepEqual(visibleTiles([], {}), []);
});

test("honors the saved order, drops unknown and duplicate IDs, and appends missing tiles", () => {
    assert.deepEqual(visibleTiles(["mic", "unknown", "mic", "toString", "bluetooth"], defs), [
        "mic", "wifi", "modes",
    ]);
});

test("uses two columns below the compact popup threshold", () => {
    assert.equal(columnsFor(319), 2);
    assert.equal(columnsFor(320), 4);
});

test("tile widths include the gaps within a span", () => {
    assert.equal(spanWidth(1, 4, 86, 8), 86);
    assert.equal(spanWidth(2, 4, 86, 8), 180);
    assert.equal(spanWidth(2, 2, 140, 8), 288);
    assert.equal(spanWidth(4, 2, 140, 8), 288);
});

test("moves in either direction without changing the input", () => {
    const order = ["wifi", "modes", "mic"];
    assert.deepEqual(move(order, 0, 2), ["modes", "mic", "wifi"]);
    assert.deepEqual(move(order, 2, 0), ["mic", "wifi", "modes"]);
    assert.deepEqual(move(order, 0, 3), order);
    assert.deepEqual(move([], 0, 1), []);
    assert.deepEqual(order, ["wifi", "modes", "mic"]);
});

test("reordering visible tiles preserves saved positions for unavailable hardware", () => {
    const order = ["mic", "bluetooth", "wifi", "modes"];
    const moved = reorderVisible(order, defs, 0, 1);

    assert.deepEqual(moved, ["wifi", "bluetooth", "mic", "modes"]);
    assert.deepEqual(visibleTiles(moved, defs), ["wifi", "mic", "modes"]);
    assert.deepEqual(order, ["mic", "bluetooth", "wifi", "modes"]);
});
