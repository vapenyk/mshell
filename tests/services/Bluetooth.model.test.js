const assert = require("node:assert/strict");
const test = require("node:test");
const { loadModel } = require("../load.js");

const { connectedCount, deviceLabel, pairedDevices, canActivate, activateDevice, batteryPercent } = loadModel("services/Bluetooth.model.js");

test("connectedCount includes only connected Bluetooth devices", () => {
    const devices = [
        { connected: false, paired: true },
        { connected: true },
        { connected: true },
    ];
    assert.equal(connectedCount(devices), 2);
    assert.equal(connectedCount([]), 0);
});

test("paired devices put active connections first and use the available device label", () => {
    const active = { name: "Headset", connected: true, paired: true };
    const nearby = { name: "Nearby", connected: false, paired: false };
    const keyboard = { deviceName: "Keyboard", connected: false, paired: true };
    const controller = { name: "Controller", connected: false, paired: true };

    assert.deepEqual(pairedDevices([keyboard, nearby, controller, active]).map(deviceLabel), [
        "Headset", "Controller", "Keyboard",
    ]);
    assert.equal(deviceLabel({ address: "test address" }), "test address");
    assert.equal(batteryPercent({ battery: 0.75 }), 75);
});

test("activates disconnected devices and disconnects connected devices while respecting pending states", () => {
    const calls = [];
    const disconnected = 0;
    const connected = 1;
    const connecting = 2;
    const device = {
        paired: true,
        state: disconnected,
        connect: () => calls.push("connect"),
        disconnect: () => calls.push("disconnect"),
    };

    assert.equal(canActivate(device, disconnected, connected), true);
    assert.equal(canActivate({ ...device, blocked: true }, disconnected, connected), false);
    activateDevice(device, disconnected, connected);
    activateDevice({ ...device, state: connected }, disconnected, connected);
    activateDevice({ ...device, state: connecting }, disconnected, connected);
    activateDevice({ ...device, paired: false }, disconnected, connected);
    assert.deepEqual(calls, ["connect", "disconnect"]);
});
