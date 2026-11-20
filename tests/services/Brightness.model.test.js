const assert = require("node:assert/strict");
const test = require("node:test");
const { loadModel } = require("../load.js");

const { parseDevices, parseInfo, rawValue, absoluteWrite, relativeWrite, writeCommand, enqueue, displayTarget } =
    loadModel("services/Brightness.model.js");

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

test("keeps at least one percent and never requests a fully dark display backlight", () => {
    assert.equal(rawValue(0, 255), 3);
    assert.equal(rawValue(-1, 4), 1);
    assert.equal(rawValue(Number.NaN, 255), -1);
    assert.equal(rawValue(0.5, 0), -1);
});

test("builds relative writes with a raw minimum only for the display", () => {
    const display = { device: "intel_backlight", current: 50, max: 255 };
    const keyboard = { device: "asus::kbd_backlight", current: 1, max: 3 };
    const lower = relativeWrite("display", display, -1);
    const off = relativeWrite("keyboard", keyboard, -1);
    assert.deepEqual(Array.from(writeCommand(lower, display)),
        ["brightnessctl", "-m", "-c", "backlight", "-d", display.device, "--min-value=3", "set", "5%-"]);
    assert.deepEqual(Array.from(writeCommand(off, keyboard)),
        ["brightnessctl", "-m", "-c", "leds", "-d", keyboard.device, "set", "1-"]);
    assert.equal(relativeWrite("display", display, 1).value, "5%+");
    assert.equal(relativeWrite("keyboard", keyboard, 1).value, "1+");
    assert.equal(relativeWrite("keyboard", null, 1), null);
});

test("preserves ordered relative steps while coalescing adjacent slider targets", () => {
    const display = { device: "intel_backlight", current: 200, max: 400 };
    const up = relativeWrite("display", display, 1);
    const down = relativeWrite("display", display, -1);
    const first = absoluteWrite(display, 0.6);
    const latest = absoluteWrite(display, 0.7, first.target);
    const sameAsReading = absoluteWrite(display, 0.5, displayTarget([up], null, display.device));
    const queue = [first, latest, up, up, down, sameAsReading].reduce(enqueue, []);
    assert.deepEqual(Array.from(queue, write => write.value), ["280", "5%+", "5%+", "5%-", "200"]);
    assert.equal(displayTarget(queue, null, display.device), 200);
    assert.equal(displayTarget(queue, first, "other_backlight"), undefined);
    assert.equal(absoluteWrite(display, 0.5), null);
});
