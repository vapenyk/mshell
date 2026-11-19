.pragma library

function connectedCount(devices) {
    return devices.filter(device => device.connected).length;
}
