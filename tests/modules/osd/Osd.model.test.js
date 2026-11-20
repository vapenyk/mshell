const assert = require("node:assert/strict");
const test = require("node:test");
const { loadModel } = require("../../load.js");

const { presentation } = loadModel("modules/osd/Osd.model.js");

test("has no presentation for an unavailable device", () => {
    assert.equal(presentation("volume", null), null);
    assert.equal(presentation("keyboard", null), null);
});

test("renders mute at zero even when the stored volume is nonzero", () => {
    const volume = { current: 0.3, max: 1, muted: false };
    const muted = { ...volume, muted: true };
    assert.deepEqual({ ...presentation("volume", muted) }, {
        value: 0, maximum: 1, discrete: false, icon: "volume_off",
    });
    assert.equal(presentation("volume", volume).icon, "volume_down");
    assert.equal(presentation("volume", { ...volume, current: 0.9 }).icon, "volume_up");
});

test("uses a normalized display level and preserves the keyboard hardware stops", () => {
    assert.deepEqual({ ...presentation("display", { current: 100, max: 400 }) }, {
        value: 0.25, maximum: 1, discrete: false, icon: "brightness_6",
    });
    assert.deepEqual({ ...presentation("keyboard", { current: 0, max: 3 }) }, {
        value: 0, maximum: 3, discrete: true, icon: "keyboard_off",
    });
    assert.deepEqual({ ...presentation("keyboard", { current: 2, max: 7 }) }, {
        value: 2, maximum: 7, discrete: true, icon: "keyboard",
    });
});
