pragma ComponentBehavior: Bound

import qs.components as Components
import qs.config
import qs.services as Services

import Quickshell
import Quickshell.Networking as Native
import QtQuick as QQ
import QtQuick.Controls as QQC
import QtQuick.Controls.Basic as Basic
import QtQuick.Layouts as QQL

QQL.ColumnLayout {
    id: root

    readonly property string title: qsTr("Internet")
    readonly property QQ.Component headerAction: Components.IconButton {
        iconName: "settings"
        text: qsTr("Settings")
        enabled: false
    }

    spacing: Sizing.popupGap

    QQ.Binding {
        target: Services.Network
        property: "scanning"
        value: true
        when: root.QQC.StackView.status === QQC.StackView.Active
    }

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

        delegate: Basic.AbstractButton {
            id: row

            required property Native.WifiNetwork modelData
            property bool connectionFailed: false
            readonly property bool connected: modelData.connected
            readonly property bool selectable: Services.Network.canConnect(modelData)
            readonly property QQ.color _contentColor: connected ? Theme.onPrimary : Theme.onSurface

            QQL.Layout.fillWidth: true
            implicitHeight: Sizing.tileHeight
            padding: Sizing.popupInnerPadding
            spacing: Sizing.popupGap
            text: modelData.name
            enabled: !modelData.stateChanging && (connected || selectable)
            hoverEnabled: true
            focusPolicy: Qt.StrongFocus

            QQ.Accessible.name: connected ? qsTr("Disconnect from %1").arg(text) : qsTr("Connect to %1").arg(text)
            QQ.Accessible.description: status.text
            QQ.Keys.onReturnPressed: row.click()
            QQ.Keys.onEnterPressed: row.click()
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

            background: Components.Surface {
                container: row.connected ? Theme.primary : Theme.surfaceContainerHigh
                radius: Shape.large

                Components.StateLayer {
                    anchors.fill: parent
                    radius: parent.radius
                    contentColor: row._contentColor
                    hovered: row.enabled && row.hovered
                    pressed: row.down
                    focused: row.visualFocus
                }
            }

            contentItem: QQL.RowLayout {
                spacing: row.spacing

                Components.Icon {
                    name: "wifi"
                    color: row._contentColor
                }

                QQL.ColumnLayout {
                    QQL.Layout.fillWidth: true
                    spacing: Shape.none

                    Components.Text {
                        QQL.Layout.fillWidth: true
                        text: row.text
                        color: row._contentColor
                        role: "labelLarge"
                    }

                    Components.Text {
                        id: status

                        QQL.Layout.fillWidth: true
                        text: row.modelData.stateChanging ? qsTr("Changing connection…")
                            : row.connected ? qsTr("Connected")
                            : row.connectionFailed ? qsTr("Could not connect")
                            : row.modelData.known ? qsTr("Saved network")
                            : row.selectable ? qsTr("Open network") : qsTr("Credentials required")
                        color: row.connected ? Theme.onPrimary : Theme.onSurfaceVariant
                        role: "bodySmall"
                    }
                }

                Components.Icon {
                    name: row.connected ? "link_off" : row.selectable ? "chevron_right" : "lock"
                    size: Sizing.smallIconSize
                    color: row._contentColor
                }
            }
        }
    }
}
