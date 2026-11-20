pragma ComponentBehavior: Bound

import qs.components as Components
import qs.components.sliders as Sliders
import qs.config
import qs.services

import QtQuick

Column {
    id: root

    signal mixerRequested()

    spacing: Sizing.popupGap

    Timer {
        interval: 1000
        repeat: true
        triggeredOnStart: true
        running: root.visible
        onTriggered: NightLight.refresh()
    }

    Row {
        anchors.right: parent.right
        spacing: root.spacing

        Sliders.ValueSlider {
            width: Math.max(0, root.width - nightLight.width - parent.spacing)
            visible: Brightness.available
            accessibleName: qsTr("Brightness")
            icon: "brightness_6"
            value: Brightness.value
            onMoved: value => Brightness.set(value)
        }

        Components.IconButton {
            id: nightLight

            text: qsTr("Night light")
            iconName: "dark_mode"
            variant: "tonal"
            toggle: true
            selected: NightLight.active
            enabled: NightLight.available
            onClicked: NightLight.toggle()
        }
    }

    Row {
        anchors.right: parent.right
        spacing: root.spacing
        visible: Audio.available

        Sliders.ValueSlider {
            width: Math.max(0, root.width - mixer.width - parent.spacing)
            accessibleName: qsTr("Volume")
            icon: Audio.muted ? "volume_off" : "music_note"
            value: Audio.volume
            onMoved: value => Audio.setVolume(value)
        }

        Components.IconButton {
            id: mixer

            text: qsTr("Mixer")
            iconName: "tune"
            variant: "tonal"
            onClicked: root.mixerRequested()
        }
    }
}
