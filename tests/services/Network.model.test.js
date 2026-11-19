const assert = require("node:assert/strict");
const test = require("node:test");
const { loadModel } = require("../load.js");

const { deviceOfType, connectedNetwork, listNetworks, canConnect, activateNetwork } = loadModel("services/Network.model.js");

const wiredType = 1;
const wifiType = 2;

test("detects connected Wi-Fi and Ethernet separately when both are active", () => {
    const offlineWifi = { type: wifiType, connected: false };
    const wifi = { type: wifiType, connected: true };
    const wired = { type: wiredType, connected: true };
    const devices = [offlineWifi, wifi, wired];

    assert.equal(deviceOfType(devices, wiredType, true), wired);
    assert.equal(deviceOfType(devices, wifiType, true), wifi);
});

test("ignores disconnected and unsupported devices in a connected-device lookup", () => {
    const loopback = { type: 0, connected: true };
    const wired = { type: wiredType, connected: false };

    assert.equal(deviceOfType([loopback, wired], wiredType, true), null);
    assert.equal(deviceOfType([loopback, wired], wifiType, true), null);
    assert.equal(deviceOfType([], wifiType, true), null);
});

test("connectedNetwork selects the connected Wi-Fi network rather than a stronger scan result", () => {
    const current = { connected: true, signalStrength: 0.42 };
    const other = { connected: false, signalStrength: 0.94 };
    assert.equal(connectedNetwork([other, current]), current);
    assert.equal(connectedNetwork([other]), null);
});

test("Wi-Fi availability includes disconnected adapters and connection lookup ignores Ethernet", () => {
    const wired = { type: wiredType, connected: true };
    const disconnected = { type: wifiType, connected: false };
    const connected = { type: wifiType, connected: true };

    assert.equal(deviceOfType([wired, disconnected], wifiType), disconnected);
    assert.equal(deviceOfType([wired, disconnected], wifiType, true), null);
    assert.equal(deviceOfType([wired, disconnected, connected], wifiType, true), connected);
    assert.equal(deviceOfType([wired], wifiType), null);
});

test("network list puts the connected network first, then saved and named networks", () => {
    const networks = [
        { name: "Cafe", known: false, connected: false },
        { name: "Office", known: true, connected: false },
        { name: "", known: false, connected: false },
        { name: "Home", known: true, connected: false },
        { name: "Current", known: false, connected: true },
    ];

    assert.deepEqual(listNetworks(networks).map(network => network.name), ["Current", "Home", "Office", "Cafe"]);
    assert.equal(networks[0].name, "Cafe");
});

test("connection actions support saved and open networks", () => {
    const open = 1;
    const owe = 2;
    const secured = 3;

    assert.equal(canConnect({ known: true, security: secured }, open, owe), true);
    assert.equal(canConnect({ known: false, security: open }, open, owe), true);
    assert.equal(canConnect({ known: false, security: owe }, open, owe), true);
    assert.equal(canConnect({ known: false, security: secured }, open, owe), false);
});

test("activation connects saved networks, disconnects active ones, and ignores pending actions", () => {
    const calls = [];
    const network = {
        known: true,
        connect: () => calls.push("connect"),
        disconnect: () => calls.push("disconnect"),
    };

    activateNetwork(network, 1, 2);
    activateNetwork({ ...network, connected: true }, 1, 2);
    activateNetwork({ ...network, stateChanging: true }, 1, 2);
    activateNetwork({ ...network, known: false, security: 3 }, 1, 2);
    assert.deepEqual(calls, ["connect", "disconnect"]);
});
