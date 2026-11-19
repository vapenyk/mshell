const assert = require("node:assert/strict");
const test = require("node:test");
const { loadModel } = require("../../../load.js");

const { icons } = loadModel("modules/bar/pills/StatusPill.model.js");

test("icons omit disconnected or absent devices", () => {
    const result = icons({
        network: { connected: false, kind: "wifi" },
        bluetooth: { enabled: true, connectedCount: 0 },
        battery: { present: false },
    });
    assert.equal(result.length, 0);
});

test("icons put Wi-Fi before connected Bluetooth", () => {
    const result = icons({
        network: { connected: true, kind: "wifi", strength: 1 },
        bluetooth: { connectedCount: 2 },
    });
    assert.deepEqual(Array.from(result, ({ name, filled }) => [name, filled]), [
        ["wifi", true],
        ["bluetooth_connected", true],
    ]);
});

test("icons distinguish Ethernet from Wi-Fi and show signal strength", () => {
    assert.equal(icons({ network: { connected: true, kind: "ethernet" } })[0].name, "settings_ethernet");
    for (const [strength, name] of [
        [0, "signal_wifi_0_bar"],
        [0.24, "network_wifi_1_bar"],
        [0.25, "network_wifi_2_bar"],
        [0.5, "network_wifi_3_bar"],
        [0.75, "wifi"],
    ]) {
        assert.equal(icons({ network: { connected: true, kind: "wifi", strength } })[0].name, name);
    }
});

test("icons put the battery last and preserve the percentage and low warning while charging", () => {
    const battery = { present: true, percent: 15, charging: false, low: true };
    const low = icons({ battery })[0];
    assert.equal(low.name, "battery_alert");
    assert.equal(low.text, "15%");
    assert.equal(low.low, true);

    const withCharging = icons({
        bluetooth: { connectedCount: 1 },
        battery: { ...battery, charging: true },
    });
    assert.deepEqual(Array.from(withCharging, icon => icon.name), ["bluetooth_connected", "battery_charging_full"]);
    assert.equal(withCharging[1].text, "15%");
    assert.equal(withCharging[1].low, true);
});
