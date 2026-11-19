pragma ComponentBehavior: Bound

import qs.components as Components
import qs.config
import qs.services

import QtQuick as QQ
import QtQuick.Layouts as QQL

QQ.Item {
    readonly property string title: qsTr("Modes")

    readonly property QQ.Component headerAction: Components.IconButton {
        iconName: "settings"
        text: qsTr("Settings")
        enabled: false
    }

    implicitHeight: dnd.y + dnd.height

    Components.ToggleSwitch {
        id: dnd

        y: Sizing.popupGap
        width: parent.width
        text: qsTr("Do Not Disturb")
        checked: Modes.dndOn
        onToggled: Modes.toggleDnd()

        contentItem: QQL.RowLayout {
            spacing: dnd.spacing

            Components.Icon {
                name: "do_not_disturb_on"
                color: Theme.onSurfaceVariant
            }

            QQL.ColumnLayout {
                QQL.Layout.fillWidth: true
                spacing: Shape.none

                Components.Text {
                    QQL.Layout.fillWidth: true
                    text: dnd.text
                    role: "labelLarge"
                }

                Components.Text {
                    QQL.Layout.fillWidth: true
                    text: dnd.checked ? qsTr("On") : qsTr("Off")
                    color: Theme.onSurfaceVariant
                    role: "bodySmall"
                }
            }
        }
    }
}
