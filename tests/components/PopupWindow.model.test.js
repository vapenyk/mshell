const assert = require("node:assert/strict");
const test = require("node:test");
const { loadModel } = require("../load.js");

const { placement } = loadModel("components/PopupWindow.model.js");

test("placement aligns the popup to the nearer edge of the pill and leaves the bar gap", () => {
    const right = placement(1920, 1080, 1792, 120, 44, 400, 320, 8, 8);
    assert.equal(right.x, 1512);
    assert.equal(right.y, 52);
    assert.equal(right.width, 400);
    assert.equal(right.height, 320);

    assert.equal(placement(1920, 1080, 20, 120, 44, 400, 320, 8, 8).x, 20);
});

test("placement shrinks to fit a narrow output and caps the scroll viewport", () => {
    const compact = placement(360, 240, 280, 80, 44, 400, 320, 8, 8);
    assert.equal(compact.x, 8);
    assert.equal(compact.width, 344);
    assert.equal(compact.height, 180);
});
