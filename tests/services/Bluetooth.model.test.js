const assert = require("node:assert/strict");
const test = require("node:test");
const { loadModel } = require("../load.js");

const { connectedCount } = loadModel("services/Bluetooth.model.js");

test("connectedCount includes only connected Bluetooth devices", () => {
    const devices = [
        { connected: false, paired: true },
        { connected: true },
        { connected: true },
    ];
    assert.equal(connectedCount(devices), 2);
    assert.equal(connectedCount([]), 0);
});
