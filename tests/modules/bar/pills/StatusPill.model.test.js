const assert = require("node:assert/strict");
const test = require("node:test");
const { loadModel } = require("../../../load.js");

const { icons } = loadModel("modules/bar/pills/StatusPill.model.js");

test("icons omit disconnected or absent devices", () => {
    const result = icons({
        dndOn: false,
        network: { wifiConnected: false, ethernetConnected: false },
        bluetooth: { enabled: true, connectedCount: 0 },
        battery: { present: false },
    });
    assert.equal(result.length, 0);
});

test("icons put Wi-Fi before connected Bluetooth", () => {
    const result = icons({
        network: { wifiConnected: true, strength: 1 },
        bluetooth: { connectedCount: 2 },
    });
    assert.deepEqual(Array.from(result, ({ name, filled }) => [name, filled]), [
        ["wifi", true],
        ["bluetooth_connected", true],
    ]);
});

test("icons distinguish Ethernet from Wi-Fi and show signal strength", () => {
    assert.equal(icons({ network: { ethernetConnected: true } })[0].name, "settings_ethernet");
    for (const [strength, name] of [
        [0, "signal_wifi_0_bar"],
        [0.24, "network_wifi_1_bar"],
        [0.25, "network_wifi_2_bar"],
        [0.5, "network_wifi_3_bar"],
        [0.75, "wifi"],
    ]) {
        assert.equal(icons({ network: { wifiConnected: true, strength } })[0].name, name);
    }
});

test("icons show DND and all active connections together, with the battery last", () => {
    const state = {
        dndOn: true,
        network: { wifiConnected: true, ethernetConnected: true, strength: 0.6 },
        bluetooth: { connectedCount: 1 },
        battery: { present: true, percent: 100 },
    };

    assert.deepEqual(Array.from(icons(state), icon => icon.name), [
        "do_not_disturb_on", "settings_ethernet", "network_wifi_3_bar", "bluetooth_connected", "battery_full_alt",
    ]);
    assert.deepEqual(Array.from(icons({ dndOn: true }), icon => icon.name), ["do_not_disturb_on"]);
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
