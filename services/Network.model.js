.pragma library

function deviceOfType(devices, type, connectedOnly = false) {
    return devices.find(device => device.type === type && (!connectedOnly || device.connected)) ?? null;
}

function connectedDevice(devices, wiredType, wifiType) {
    return deviceOfType(devices, wiredType, true) ?? deviceOfType(devices, wifiType, true);
}

function connectedNetwork(networks) {
    return networks.find(network => network.connected) ?? null;
}
