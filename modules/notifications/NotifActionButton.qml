pragma ComponentBehavior: Bound

import qs.components as Components
import qs.config

import Quickshell
import QtQuick as QQ
import QtQuick.Controls.Basic as Basic
import QtQuick.Layouts as QQL

Basic.Button {
    id: action
    property bool outlined: false
    readonly property string _browserIcon: outlined ? Quickshell.iconPath("web-browser", true) : ""
    width: Math.min(implicitWidth, parent.width)
    implicitHeight: Sizing.pillHeight
    horizontalPadding: outlined ? Sizing.pillHorizontalPadding : Shape.none
    hoverEnabled: true
    QQ.Keys.onReturnPressed: click()
    QQ.Keys.onEnterPressed: click()

    contentItem: QQL.RowLayout {
        spacing: Sizing.pillGap
        QQ.Image {
            id: browserImage

            visible: action.outlined && status === QQ.Image.Ready
            source: action.outlined ? action._browserIcon : ""
            fillMode: QQ.Image.PreserveAspectFit
            QQL.Layout.preferredWidth: Sizing.smallIconSize
            QQL.Layout.preferredHeight: Sizing.smallIconSize
        }
        Components.Icon {
            visible: action.outlined && browserImage.status !== QQ.Image.Ready
            name: "language"
            color: Theme.primary
            size: Sizing.smallIconSize
        }
        Components.Text {
            QQL.Layout.fillWidth: true
            text: action.text
            role: "labelLarge"
            color: Theme.primary
            verticalAlignment: QQ.Text.AlignVCenter
        }
    }
    background: QQ.Rectangle {
        color: Theme.transparent
        border.color: Theme.outline
        border.width: action.outlined ? Sizing.outlineWidth : Shape.none
        radius: Shape.full
        Components.StateLayer {
            anchors.fill: parent
            radius: parent.radius
            contentColor: Theme.primary
            hovered: action.hovered
            pressed: action.down
            focused: action.visualFocus
        }
    }
}
