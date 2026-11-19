pragma Singleton

import "Network.model.js" as Model

import Quickshell
import Quickshell.Networking as Native
import QtQml

Singleton {
    id: root

    readonly property bool connected: _device !== null
    readonly property string kind: _device?.type === Native.DeviceType.Wifi ? "wifi"
                                   : connected ? "ethernet" : ""
    readonly property string ssid: _wifi?.name ?? ""
    readonly property real strength: _wifi?.signalStrength ?? 0
    readonly property bool available: _wifiAdapter !== null
    readonly property bool enabled: Native.Networking.wifiEnabled
    readonly property var networks: enabled ? Model.listNetworks(_wifiAdapter?.networks.values ?? []) : []
    property bool scanning: false

    readonly property Native.NetworkDevice _device: Model.connectedDevice(
        Native.Networking.devices.values, Native.DeviceType.Wired, Native.DeviceType.Wifi)
    readonly property Native.WifiDevice _wifiDevice: Model.deviceOfType(
        Native.Networking.devices.values, Native.DeviceType.Wifi, true)
    readonly property Native.WifiDevice _wifiAdapter: _wifiDevice
        ?? Model.deviceOfType(Native.Networking.devices.values, Native.DeviceType.Wifi)
    readonly property Native.WifiNetwork _wifi: Model.connectedNetwork(_wifiDevice?.networks.values ?? [])

    function canConnect(network: Native.WifiNetwork): bool {
        return Model.canConnect(network, Native.WifiSecurityType.Open, Native.WifiSecurityType.Owe);
    }

    function activate(network: Native.WifiNetwork): void {
        if (enabled)
            Model.activateNetwork(network, Native.WifiSecurityType.Open, Native.WifiSecurityType.Owe);
    }

    Binding {
        target: root._wifiAdapter
        property: "scannerEnabled"
        value: true
        when: root._wifiAdapter !== null && root.enabled && root.scanning
    }

    function toggle(): void {
        Native.Networking.wifiEnabled = !root.enabled;
    }
}
