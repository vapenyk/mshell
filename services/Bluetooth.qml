pragma Singleton

import "Bluetooth.model.js" as Model

import Quickshell
import Quickshell.Bluetooth as Native

Singleton {
    id: root

    readonly property bool available: _adapter !== null
    readonly property bool enabled: _adapter?.enabled ?? false
    readonly property var pairedDevices: enabled ? Model.pairedDevices(_adapter?.devices.values ?? []) : []
    readonly property int connectedCount: Model.connectedCount(Native.Bluetooth.devices.values)

    readonly property Native.BluetoothAdapter _adapter: Native.Bluetooth.defaultAdapter

    function deviceLabel(device: Native.BluetoothDevice): string {
        return Model.deviceLabel(device);
    }

    function batteryPercent(device: Native.BluetoothDevice): int {
        return Model.batteryPercent(device);
    }

    function canActivate(device: Native.BluetoothDevice): bool {
        return enabled && Model.canActivate(device, Native.BluetoothDeviceState.Disconnected,
            Native.BluetoothDeviceState.Connected);
    }

    function activate(device: Native.BluetoothDevice): void {
        if (enabled && device?.adapter === _adapter)
            Model.activateDevice(device, Native.BluetoothDeviceState.Disconnected,
                Native.BluetoothDeviceState.Connected);
    }

    function toggle(): void {
        if (root.available)
            root._adapter.enabled = !root.enabled;
    }
}
