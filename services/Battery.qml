pragma Singleton

import "Battery.model.js" as Model

import Quickshell
import Quickshell.Services.UPower

Singleton {
    id: root

    readonly property bool present: _device.ready && _device.isPresent
    readonly property int percent: present ? Model.percent(_device.percentage) : 0
    readonly property bool charging: present && _device.state === UPowerDeviceState.Charging
    readonly property bool low: Model.isLow(present, percent)

    readonly property UPowerDevice _device: UPower.displayDevice
}
