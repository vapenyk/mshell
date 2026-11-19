const assert = require("node:assert/strict");
const test = require("node:test");
const { loadModel } = require("../../../load.js");

const { label } = loadModel("modules/bar/pills/ClockPill.model.js");
const date = new Date(2026, 9, 12, 13, 15);

test("label shows only the time in the compact class", () => {
    assert.equal(label(date, "compact", true), "13:15");
    assert.equal(label(date, "compact", false), "1:15 PM");
});

test("label includes the short date in larger classes", () => {
    for (const sizeClass of ["medium", "expanded", "large", "extraLarge"])
        assert.equal(label(date, sizeClass, true), "13:15 Mon 12 Oct", sizeClass);

    assert.equal(label(date, "medium", false), "1:15 PM Mon 12 Oct");
});
