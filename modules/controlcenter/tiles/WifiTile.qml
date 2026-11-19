import qs.components
import qs.services

Tile {
    active: Network.enabled
    icon: "wifi"
    title: qsTr("Wi-Fi")
    subtitle: !active ? qsTr("Off") : Network.ssid || qsTr("On")
    onToggled: Network.toggle()
}
