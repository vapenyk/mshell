pragma ComponentBehavior: Bound

import qs.components as Components
import qs.config
import qs.services as Services

import Quickshell
import Quickshell.Networking as Native
import QtQuick as QQ
import QtQuick.Controls as QQC
import QtQuick.Layouts as QQL

QQ.Item {
    id: root

    implicitHeight: content.implicitHeight

    readonly property string title: qsTr("Internet")
    readonly property QQ.Component headerAction: Components.IconButton {
        iconName: "settings"
        text: qsTr("Settings")
        enabled: false
    }

    QQ.Binding {
        target: Services.Network
        property: "scanning"
        value: true
        when: root.QQC.StackView.status !== QQC.StackView.Inactive
    }

    QQL.ColumnLayout {
        id: content

        width: parent.width
        height: implicitHeight
        spacing: Sizing.popupGap

        Components.ToggleSwitch {
            QQL.Layout.fillWidth: true
            text: qsTr("Wi-Fi")
            checked: Services.Network.enabled
            enabled: Services.Network.available

            onToggled: Services.Network.toggle()
        }

        Components.Text {
            QQL.Layout.fillWidth: true
            QQL.Layout.margins: Sizing.popupGap
            visible: Services.Network.enabled && Services.Network.networks.length === 0
            text: qsTr("No networks found")
            color: Theme.onSurfaceVariant
            horizontalAlignment: QQ.Text.AlignHCenter
        }

        QQ.Repeater {
            model: ScriptModel {
                values: Services.Network.networks
            }

            delegate: ConnectionRow {
                id: row

                required property Native.WifiNetwork modelData
                property bool connectionFailed: false
                readonly property bool selectable: Services.Network.canConnect(modelData)

                QQL.Layout.fillWidth: true
                connected: modelData.connected
                iconName: "wifi"
                text: modelData.name
                enabled: !modelData.stateChanging && (connected || selectable)
                trailingIcon: connected ? "link_off" : selectable ? "chevron_right" : "lock"
                subtitle: modelData.stateChanging ? qsTr("Changing connection…")
                    : connected ? qsTr("Connected")
                    : connectionFailed ? qsTr("Could not connect")
                    : modelData.known ? qsTr("Saved network")
                    : selectable ? qsTr("Open network") : qsTr("Credentials required")

                onClicked: {
                    connectionFailed = false;
                    Services.Network.activate(modelData);
                }

                QQ.Connections {
                    target: row.modelData
                    function onConnectionFailed(): void {
                        row.connectionFailed = true;
                    }
                }
            }
        }
    }
}
