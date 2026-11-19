pragma ComponentBehavior: Bound

import qs.config

import QtQuick as QQ
import QtQuick.Controls.Basic as Basic

Basic.Switch {
    id: root

    implicitHeight: Sizing.tileHeight
    leftPadding: Sizing.popupInnerPadding
    rightPadding: Sizing.popupInnerPadding + Sizing.switchWidth + Sizing.popupGap
    spacing: Sizing.popupGap
    hoverEnabled: true
    focusPolicy: Qt.StrongFocus

    QQ.Keys.onReturnPressed: root.click()
    QQ.Keys.onEnterPressed: root.click()

    background: Surface {
        container: Theme.surfaceContainerHigh
        radius: Shape.large

        StateLayer {
            anchors.fill: parent
            radius: parent.radius
            contentColor: Theme.onSurface
            hovered: root.hovered
            pressed: root.down
            focused: root.visualFocus
        }
    }

    indicator: QQ.Rectangle {
        x: root.width - root.leftPadding - width
        anchors.verticalCenter: parent.verticalCenter
        implicitWidth: Sizing.switchWidth
        implicitHeight: Sizing.switchHeight
        radius: Shape.full
        color: root.checked ? Theme.primary : Theme.surfaceContainerHighest
        border.width: root.checked ? Shape.none : Sizing.switchOutlineWidth
        border.color: Theme.outline

        QQ.Rectangle {
            x: (parent.height - width) / 2 + root.visualPosition * (parent.width - parent.height)
            anchors.verticalCenter: parent.verticalCenter
            width: root.checked ? Sizing.switchThumbOnSize : Sizing.switchThumbOffSize
            height: width
            radius: Shape.full
            color: root.checked ? Theme.onPrimary : Theme.outline

            QQ.Behavior on x {
                enabled: !root.pressed

                QQ.SpringAnimation {
                    spring: Motion.spatialFast.spring
                    damping: Motion.spatialFast.damping
                    mass: Motion.spatialFast.mass
                }
            }
        }
    }

    contentItem: Text {
        text: root.text
        role: "labelLarge"
        verticalAlignment: QQ.Text.AlignVCenter
    }
}
