const assert = require("node:assert/strict");
const test = require("node:test");
const { loadModel } = require("../load.js");

const { percent, isLow } = loadModel("services/Battery.model.js");

test("percent converts charge to a rounded percentage bounded by 0 and 100", () => {
    assert.equal(percent(0.076), 8);
    assert.equal(percent(0.5), 50);
    assert.equal(percent(-0.02), 0);
    assert.equal(percent(1.02), 100);
    assert.equal(percent(NaN), 0);
});

test("isLow includes 15 percent and ignores an absent battery", () => {
    assert.equal(isLow(true, 15), true);
    assert.equal(isLow(true, 16), false);
    assert.equal(isLow(false, 0), false);
});
