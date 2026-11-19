.pragma library
.import "Battery.model.js" as BatteryModel

function connectedCount(devices) {
    return devices.filter(device => device.connected).length;
}

function deviceLabel(device) {
    return device.name || device.deviceName || device.address;
}

function pairedDevices(devices) {
    return Array.from(devices)
        .filter(device => device.paired)
        .sort((left, right) => Number(right.connected) - Number(left.connected)
            || deviceLabel(left).localeCompare(deviceLabel(right)));
}

function canActivate(device, disconnectedState, connectedState) {
    return Boolean(device && device.paired && !device.blocked
        && (device.state === disconnectedState || device.state === connectedState));
}

function activateDevice(device, disconnectedState, connectedState) {
    if (!canActivate(device, disconnectedState, connectedState))
        return;
    if (device.state === connectedState)
        device.disconnect();
    else
        device.connect();
}

function batteryPercent(device) {
    return BatteryModel.percent(device.battery);
}
