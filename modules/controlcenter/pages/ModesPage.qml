pragma ComponentBehavior: Bound

import qs.components as Components
import qs.config
import qs.services

import QtQuick as QQ
import QtQuick.Controls.Basic as Basic
import QtQuick.Layouts as QQL

QQ.Item {
    readonly property string title: qsTr("Modes")

    readonly property QQ.Component headerAction: Components.IconButton {
        iconName: "settings"
        text: qsTr("Settings")
        enabled: false
    }

    implicitHeight: dnd.y + dnd.height

    Basic.Switch {
        id: dnd

        y: Sizing.popupGap
        width: parent.width
        height: Sizing.tileHeight
        leftPadding: Sizing.popupInnerPadding
        rightPadding: Sizing.popupInnerPadding + Sizing.switchWidth + Sizing.popupGap
        spacing: Sizing.popupGap
        text: qsTr("Do Not Disturb")
        checked: Modes.dndOn
        hoverEnabled: true
        focusPolicy: Qt.StrongFocus

        onToggled: Modes.toggleDnd()
        QQ.Keys.onReturnPressed: dnd.click()
        QQ.Keys.onEnterPressed: dnd.click()

        background: Components.Surface {
            container: Theme.surfaceContainerHigh
            radius: Shape.large

            Components.StateLayer {
                anchors.fill: parent
                radius: parent.radius
                contentColor: Theme.onSurface
                hovered: dnd.hovered
                pressed: dnd.down
                focused: dnd.visualFocus
            }
        }

        indicator: QQ.Rectangle {
            x: dnd.width - dnd.leftPadding - width
            anchors.verticalCenter: parent.verticalCenter
            implicitWidth: Sizing.switchWidth
            implicitHeight: Sizing.switchHeight
            radius: Shape.full
            color: dnd.checked ? Theme.primary : Theme.surfaceContainerHighest
            border.width: dnd.checked ? Shape.none : Sizing.switchOutlineWidth
            border.color: Theme.outline

            QQ.Rectangle {
                x: (parent.height - width) / 2 + dnd.visualPosition * (parent.width - parent.height)
                anchors.verticalCenter: parent.verticalCenter
                width: dnd.checked ? Sizing.switchThumbOnSize : Sizing.switchThumbOffSize
                height: width
                radius: Shape.full
                color: dnd.checked ? Theme.onPrimary : Theme.outline

                QQ.Behavior on x {
                    enabled: !dnd.pressed

                    QQ.SpringAnimation {
                        spring: Motion.spatialFast.spring
                        damping: Motion.spatialFast.damping
                        mass: Motion.spatialFast.mass
                    }
                }
            }
        }

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
