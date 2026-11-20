const assert = require("node:assert/strict");
const test = require("node:test");
const { loadModel } = require("../../load.js");

const { levelChange, presentation } = loadModel("modules/osd/Osd.model.js");

test("ignores initial readings, unavailable devices and unchanged polls", () => {
    const reading = { device: "backlight", current: 50, max: 100 };
    assert.equal(levelChange(undefined, reading), "");
    assert.equal(levelChange(reading, null), "");
    assert.equal(levelChange(reading, { ...reading }), "");
    assert.equal(levelChange(reading, { ...reading, max: 200 }), "");
    assert.equal(levelChange(reading, { ...reading, device: "other", current: 1 }), "");
    assert.equal(levelChange(reading, { ...reading, current: 51 }), "external");
});

test("shows mute changes at zero even when the stored volume stays the same", () => {
    const volume = { device: 5, current: 0.3, max: 1, muted: false };
    const muted = { ...volume, muted: true };
    assert.equal(levelChange(volume, muted, true), "external");
    assert.equal(levelChange(muted, { ...muted, current: 0.4 }), "external");
    assert.deepEqual({ ...presentation("volume", muted) }, {
        value: 0, maximum: 1, discrete: false, icon: "volume_off",
    });
    assert.equal(presentation("volume", volume).icon, "volume_down");
    assert.equal(presentation("volume", { ...volume, current: 0.9 }).icon, "volume_up");
});

test("distinguishes slider writes from external changes to the same device", () => {
    const display = { device: "backlight", current: 50, max: 100 };
    const brighter = { ...display, current: 51 };
    assert.equal(levelChange(display, brighter, true), "local");
    assert.equal(levelChange(brighter, { ...brighter }), "");
    assert.equal(levelChange(brighter, display), "external");

    const volume = { device: 5, current: 0.3, max: 1, muted: false };
    const louder = { ...volume, current: 0.5 };
    assert.equal(levelChange(volume, louder, true), "local");
    assert.equal(levelChange(louder, { ...louder, current: 0.5000000596046448 }), "");
    assert.equal(levelChange(louder, volume), "external");
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
