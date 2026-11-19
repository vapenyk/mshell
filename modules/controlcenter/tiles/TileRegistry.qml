pragma ComponentBehavior: Bound

import qs.services

import QtQml

QtObject {
    readonly property var definitions: ({
        wifi: { comp: wifi, span: 2, available: Network.available },
        bluetooth: { comp: bluetooth, span: 2, available: Bluetooth.available },
        modes: { comp: modes, span: 1, available: true },
        mic: { comp: mic, span: 1, available: Audio.sourceAvailable }
    })

    readonly property Component wifi: WifiTile {}
    readonly property Component bluetooth: BluetoothTile {}
    readonly property Component modes: ModesTile {}
    readonly property Component mic: MicTile {}
}
