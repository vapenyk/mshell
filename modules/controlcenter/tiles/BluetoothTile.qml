import qs.components
import qs.services

Tile {
    active: Bluetooth.enabled
    icon: "bluetooth"
    title: qsTr("Bluetooth")
    subtitle: !active ? qsTr("Off") : Bluetooth.connectedCount > 0 ? qsTr("Connected") : qsTr("On")
    onToggled: Bluetooth.toggle()
}
