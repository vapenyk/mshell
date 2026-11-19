import qs.components
import qs.services

Tile {
    active: Audio.sourceAvailable && !Audio.sourceMuted
    iconOnly: true
    icon: active ? "mic" : "mic_off"
    title: qsTr("Microphone")
    onToggled: Audio.toggleSourceMute()
}
