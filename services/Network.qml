pragma Singleton

import "Network.model.js" as Model

import Quickshell
import Quickshell.Networking as Native

Singleton {
    id: root

    readonly property bool connected: _device !== null
    readonly property string kind: _device?.type === Native.DeviceType.Wifi ? "wifi"
                                   : connected ? "ethernet" : ""
    readonly property string ssid: _wifi?.name ?? ""
    readonly property real strength: _wifi?.signalStrength ?? 0
    readonly property bool available: Model.deviceOfType(Native.Networking.devices.values, Native.DeviceType.Wifi) !== null
    readonly property bool enabled: Native.Networking.wifiEnabled

    readonly property Native.NetworkDevice _device: Model.connectedDevice(
        Native.Networking.devices.values, Native.DeviceType.Wired, Native.DeviceType.Wifi)
    readonly property Native.WifiDevice _wifiDevice: Model.deviceOfType(
        Native.Networking.devices.values, Native.DeviceType.Wifi, true)
    readonly property Native.WifiNetwork _wifi: Model.connectedNetwork(_wifiDevice?.networks.values ?? [])

    function toggle(): void {
        Native.Networking.wifiEnabled = !root.enabled;
    }
}
