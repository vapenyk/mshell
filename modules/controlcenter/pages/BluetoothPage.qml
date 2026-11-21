pragma ComponentBehavior: Bound

import qs.components as Components
import qs.config
import qs.services as Services

import Quickshell
import Quickshell.Bluetooth as Native
import QtQuick as QQ
import QtQuick.Layouts as QQL

QQ.Item {
    id: root

    implicitHeight: content.implicitHeight

    readonly property string title: qsTr("Bluetooth")

    readonly property QQ.Component headerAction: Components.IconButton {
        iconName: "settings"
        text: qsTr("Settings")
        enabled: false
    }

    QQL.ColumnLayout {
        id: content

        width: parent.width
        height: implicitHeight
        spacing: Sizing.popupGap

        Components.ToggleSwitch {
            QQL.Layout.fillWidth: true
            text: qsTr("Use Bluetooth")
            checked: Services.Bluetooth.enabled
            enabled: Services.Bluetooth.available

            onToggled: Services.Bluetooth.toggle()
        }

        Components.Text {
            QQL.Layout.fillWidth: true
            QQL.Layout.margins: Sizing.popupGap
            visible: Services.Bluetooth.enabled && Services.Bluetooth.pairedDevices.length === 0
            text: qsTr("No paired devices")
            color: Theme.onSurfaceVariant
            horizontalAlignment: QQ.Text.AlignHCenter
        }

        QQ.Repeater {
            model: ScriptModel {
                values: Services.Bluetooth.pairedDevices
            }

            delegate: ConnectionRow {
                required property Native.BluetoothDevice modelData

                QQL.Layout.fillWidth: true
                text: Services.Bluetooth.deviceLabel(modelData)
                iconName: "bluetooth"
                connected: modelData.connected
                enabled: Services.Bluetooth.canActivate(modelData)
                subtitle: modelData.blocked ? qsTr("Blocked")
                    : modelData.state === Native.BluetoothDeviceState.Connecting ? qsTr("Connecting…")
                    : modelData.state === Native.BluetoothDeviceState.Disconnecting ? qsTr("Disconnecting…")
                    : !connected ? qsTr("Disconnected")
                    : modelData.batteryAvailable ? qsTr("Connected · %1% battery").arg(Services.Bluetooth.batteryPercent(modelData))
                    : qsTr("Connected")

                onClicked: Services.Bluetooth.activate(modelData)
            }
        }
    }
}
