const assert = require("node:assert/strict");
const test = require("node:test");
const { loadModel } = require("../../load.js");

const { changed, presentation } = loadModel("modules/osd/Osd.model.js");

test("ignores initial readings, unavailable devices and unchanged polls", () => {
    const reading = { device: "backlight", current: 50, max: 100 };
    assert.equal(changed(undefined, reading), false);
    assert.equal(changed(reading, null), false);
    assert.equal(changed(reading, { ...reading }), false);
    assert.equal(changed(reading, { ...reading, max: 200 }), false);
    assert.equal(changed(reading, { ...reading, device: "other", current: 1 }), false);
    assert.equal(changed(reading, { ...reading, current: 51 }), true);
});

test("shows mute changes at zero even when the stored volume stays the same", () => {
    const volume = { device: 5, current: 0.3, max: 1, muted: false };
    const muted = { ...volume, muted: true };
    assert.equal(changed(volume, muted), true);
    assert.equal(changed(muted, { ...muted, current: 0.4 }), true);
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
