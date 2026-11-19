const assert = require("node:assert/strict");
const test = require("node:test");
const { loadModel } = require("../load.js");

const { posFromValue, valueFromPos, stepValue } = loadModel("components/ValueSlider.model.js");

test("clamps positions and values to the range", () => {
    assert.equal(valueFromPos(-10, 100, 20, 80, 5), 20);
    assert.equal(valueFromPos(110, 100, 20, 80, 5), 80);
    assert.equal(posFromValue(10, 100, 20, 80), 0);
    assert.equal(posFromValue(90, 100, 20, 80), 100);
});

test("rounds from the minimum and can select a maximum between ticks", () => {
    assert.equal(valueFromPos(44, 100, -10, 10, 5), 0);
    assert.equal(valueFromPos(37.5, 100, -10, 10, 5), 0);
    assert.equal(valueFromPos(98, 100, 0, 10, 3), 10);
    assert.equal(valueFromPos(91, 100, 0, 10, 3), 9);
});

test("round-trips every selectable value", () => {
    for (const value of [-2, -0.5, 1, 2.5, 4, 5]) {
        const position = posFromValue(value, 320, -2, 5);
        assert.equal(valueFromPos(position, 320, -2, 5, 1.5), value);
    }
});

test("supports continuous values without a positive step", () => {
    assert.equal(valueFromPos(25, 100, 5, 15, 0), 7.5);
    assert.equal(stepValue(8, 5, 15, 0, 1), 8.1);
});

test("handles a zero width or a collapsed range", () => {
    assert.equal(valueFromPos(50, 0, 20, 80, 5), 20);
    assert.equal(posFromValue(50, 0, 20, 80), 0);
    assert.equal(valueFromPos(50, 100, 20, 20, 5), 20);
    assert.equal(posFromValue(50, 100, 20, 20), 0);
    assert.equal(stepValue(50, 20, 20, 5, 1), 20);
});

test("steps between adjacent ticks and endpoints", () => {
    assert.equal(stepValue(5, 5, 10, 2, -1), 5);
    assert.equal(stepValue(7, 5, 10, 2, 1), 9);
    assert.equal(stepValue(9, 5, 10, 2, 1), 10);
    assert.equal(stepValue(10, 5, 10, 2, -1), 9);
    assert.equal(stepValue(10, 5, 10, 2, 1), 10);
    assert.ok(Math.abs(stepValue(0.3, 0, 1, 0.1, 1) - 0.4) < Number.EPSILON);
    assert.ok(Math.abs(stepValue(0.30000000000000004, 0, 1, 0.1, -1) - 0.2) < Number.EPSILON);
    assert.equal(stepValue(50.3, 50, 55, 0.1, 1), 50.4);
});
