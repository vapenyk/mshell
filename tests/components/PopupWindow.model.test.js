const assert = require("node:assert/strict");
const test = require("node:test");
const { loadModel } = require("../load.js");

const { placement } = loadModel("components/PopupWindow.model.js");
const shadow = { blur: 24, offsetY: 8 };
const slideDistance = 8;

test("placement aligns the popup to the nearer edge of the pill and leaves the bar gap", () => {
    const right = placement(1920, 1080, 1792, 120, 44, 400, 320, 8, 8, false, shadow, slideDistance);
    assert.equal(right.x, 1512);
    assert.equal(right.y, 52);
    assert.equal(right.width, 400);
    assert.equal(right.height, 320);

    const left = placement(1920, 1080, 20, 120, 44, 400, 320, 8, 8, false, shadow, slideDistance);
    assert.equal(left.x, 20);
});

test("placement caps the visible panel and fits its shadow window on a narrow output", () => {
    const compact = placement(360, 240, 280, 80, 44, 400, 320, 8, 8, false, shadow, slideDistance);
    assert.equal(compact.x, 8);
    assert.equal(compact.width, 344);
    assert.equal(compact.height, 180);
    assert.deepEqual({ ...compact.window }, { x: 0, y: 28, width: 360, height: 212 });
});

test("centered placement aligns to the pill center and clamps to the screen margin", () => {
    const center = placement(1920, 1080, 1720, 32, 44, 296, 180, 8, 8, true, shadow, slideDistance);
    const edge = placement(1920, 1080, 1840, 32, 44, 296, 180, 8, 8, true, shadow, slideDistance);
    assert.equal(center.x, 1588);
    assert.equal(edge.x, 1616);
});

test("the shadow window preserves the panel position and reserves available space for blur and slide", () => {
    const left = placement(1920, 1080, 8, 100, 44, 400, 320.4, 8, 8, false, shadow, slideDistance);
    const right = placement(1920, 1080, 1792, 120, 44, 400, 320, 8, 8, false, shadow, slideDistance);
    const center = placement(1920, 1080, 944, 32, 44, 400, 320, 8, 8, true, shadow, slideDistance);

    assert.deepEqual({ ...left.window }, { x: 0, y: 28, width: 432, height: 376 });
    assert.deepEqual({ ...right.window }, { x: 1488, y: 28, width: 432, height: 376 });
    assert.deepEqual({ ...center.window }, { x: 736, y: 28, width: 448, height: 376 });
});
