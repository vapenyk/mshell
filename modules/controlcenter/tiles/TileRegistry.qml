pragma ComponentBehavior: Bound

import qs.components

import QtQml

QtObject {
    readonly property var definitions: ({
        wifi: { comp: wifi, span: 2, available: true },
        bluetooth: { comp: bluetooth, span: 2, available: true },
        modes: { comp: modes, span: 1, available: true },
        mic: { comp: mic, span: 1, available: true }
    })

    property Component wifi: Tile {
        enabled: false
        title: qsTr("Wi-Fi")
        icon: "wifi"
    }

    property Component bluetooth: Tile {
        enabled: false
        title: qsTr("Bluetooth")
        icon: "bluetooth"
    }

    property Component modes: Tile {
        enabled: false
        iconOnly: true
        title: qsTr("Modes")
        icon: "do_not_disturb_on"
    }

    property Component mic: Tile {
        enabled: false
        iconOnly: true
        title: qsTr("Microphone")
        icon: "mic"
    }
}
