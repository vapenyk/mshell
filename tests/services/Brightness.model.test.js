const assert = require("node:assert/strict");
const test = require("node:test");
const { loadModel } = require("../load.js");

const { parseDevices, parseInfo, rawValue } = loadModel("services/Brightness.model.js");

test("reads the raw brightness and maximum instead of the rounded percentage", () => {
    const record = parseInfo("intel_backlight,backlight,199,50%,400\n");
    assert.equal(record.device, "intel_backlight");
    assert.equal(record.current, 199);
    assert.equal(record.max, 400);
});

test("ignores unrelated or malformed lines and selects the first usable backlight", () => {
    const records = [
        "input3::capslock,leds,1,100%,1",
        "fake,backlight,90,90%,0",
        "broken,backlight,no,30%,400",
        "amdgpu_bl1,backlight,0,0%,255",
        "acpi_video0,backlight,5,50%,10",
    ];
    assert.equal(parseInfo(records.join("\r\n")).device, "amdgpu_bl1");
    assert.equal(parseInfo(""), null);
    assert.equal(parseInfo("broken,backlight,401,100%,400"), null);
});

test("converts normalized brightness to the nearest hardware level", () => {
    assert.equal(rawValue(0.5, 255), 128);
    assert.equal(rawValue(1.1, 255), 255);
});

test("reads display and keyboard backlight from one device list", () => {
    const records = [
        "input3::capslock,leds,1,100%,1",
        "intel_backlight,backlight,199,50%,400",
        "asus::kbd_backlight,leds,0,0%,3",
    ].join("\n");
    const devices = parseDevices(records);
    assert.deepEqual({ ...devices.display }, { device: "intel_backlight", current: 199, max: 400 });
    assert.deepEqual({ ...devices.keyboard }, { device: "asus::kbd_backlight", current: 0, max: 3 });
    assert.equal(parseDevices("input3::capslock,leds,1,100%,1").keyboard, null);
    assert.equal(parseDevices("kbd_backlight,leds,7,100%,7").keyboard.max, 7);
});

test("keeps at least five percent and never requests a fully dark backlight", () => {
    assert.equal(rawValue(0, 255), 13);
    assert.equal(rawValue(-1, 4), 1);
    assert.equal(rawValue(Number.NaN, 255), -1);
    assert.equal(rawValue(0.5, 0), -1);
});
