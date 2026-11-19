.pragma library

function connectedDevice(devices, wiredType, wifiType) {
    return devices.find(device => device.connected && device.type === wiredType)
        ?? devices.find(device => device.connected && device.type === wifiType)
        ?? null;
}

function connectedNetwork(networks) {
    return networks.find(network => network.connected) ?? null;
}
