const assert = require("node:assert/strict");
const test = require("node:test");
const { loadModel } = require("../load.js");

const { connectedDevice, connectedNetwork } = loadModel("services/Network.model.js");

const wiredType = 1;
const wifiType = 2;

test("connectedDevice prefers connected Ethernet to Wi-Fi", () => {
    const wifi = { type: wifiType, connected: true };
    const wired = { type: wiredType, connected: true };
    assert.equal(connectedDevice([wifi, wired], wiredType, wifiType), wired);
});

test("connectedDevice falls back to Wi-Fi and ignores unsupported or disconnected devices", () => {
    const loopback = { type: 0, connected: true };
    const wired = { type: wiredType, connected: false };
    const wifi = { type: wifiType, connected: true };

    assert.equal(connectedDevice([loopback, wired, wifi], wiredType, wifiType), wifi);
    assert.equal(connectedDevice([loopback, wired], wiredType, wifiType), null);
    assert.equal(connectedDevice([], wiredType, wifiType), null);
});

test("connectedNetwork selects the connected Wi-Fi network rather than a stronger scan result", () => {
    const current = { connected: true, signalStrength: 0.42 };
    const other = { connected: false, signalStrength: 0.94 };
    assert.equal(connectedNetwork([other, current]), current);
    assert.equal(connectedNetwork([other]), null);
});
