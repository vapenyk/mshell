pragma ComponentBehavior: Bound

import qs.components as Components
import qs.config

import QtQuick

Column {
    id: root

    property real brightness: 0.79
    property real volume: 0.33

    spacing: Sizing.popupGap

    Components.ValueSlider {
        width: root.width
        accessibleName: qsTr("Brightness")
        icon: "brightness_6"
        value: root.brightness
        onMoved: value => root.brightness = value
    }

    Components.ValueSlider {
        width: root.width
        accessibleName: qsTr("Volume")
        icon: "music_note"
        value: root.volume
        onMoved: value => root.volume = value
    }
}
