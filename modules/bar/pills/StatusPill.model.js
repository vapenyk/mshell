.pragma library

function icons(state) {
    var result = [];
    var network = state.network;
    var battery = state.battery;

    if (state.dndOn)
        result.push({ name: "do_not_disturb_on", filled: true });

    if (network?.ethernetConnected)
        result.push({ name: "settings_ethernet", filled: true });

    if (network?.wifiConnected)
        result.push({ name: wifiIcon(network.strength), filled: true });

    if (state.bluetooth?.connectedCount > 0)
        result.push({ name: "bluetooth_connected", filled: true });

    if (battery?.present) {
        result.push({
            name: batteryIcon(battery),
            filled: true,
            text: battery.percent + "%",
            low: battery.low,
        });
    }

    return result;
}

function wifiIcon(strength) {
    if (strength <= 0)
        return "signal_wifi_0_bar";
    if (strength < 0.25)
        return "network_wifi_1_bar";
    if (strength < 0.5)
        return "network_wifi_2_bar";
    if (strength < 0.75)
        return "network_wifi_3_bar";
    return "wifi";
}

function batteryIcon(battery) {
    if (battery.charging)
        return "battery_charging_full";
    if (battery.low)
        return "battery_alert";
    if (battery.percent < 25)
        return "battery_horiz_000";
    if (battery.percent < 65)
        return "battery_horiz_050";
    if (battery.percent < 90)
        return "battery_horiz_075";
    return "battery_full_alt";
}
