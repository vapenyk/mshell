pragma Singleton

import "Bluetooth.model.js" as Model

import Quickshell
import Quickshell.Bluetooth as Native

Singleton {
    id: root

    readonly property bool available: _adapter !== null
    readonly property bool enabled: _adapter?.enabled ?? false
    readonly property int connectedCount: Model.connectedCount(Native.Bluetooth.devices.values)

    readonly property Native.BluetoothAdapter _adapter: Native.Bluetooth.defaultAdapter

    function toggle(): void {
        if (root.available)
            root._adapter.enabled = !root.enabled;
    }
}
