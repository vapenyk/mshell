import qs.config

import QtQml
import QtQuick as QQ

QQ.Item {
    id: root

    property string icon: ""
    property string text: ""
    property Component trailing
    property bool active: false
    readonly property QQ.color contentColor: _highlighted ? Theme.onSecondaryContainer : Theme.onSurface
    readonly property bool _pressed: leftTap.pressed || rightTap.pressed
    readonly property bool _highlighted: active || _pressed

    signal clicked()
    signal rightClicked()

    implicitHeight: Sizing.pillHeight
    implicitWidth: text.length > 0 || trailing
                   ? Math.max(implicitHeight, content.implicitWidth + 2 * Sizing.pillHorizontalPadding)
                   : implicitHeight

    Surface {
        anchors.fill: parent
        container: root._highlighted ? Theme.secondaryContainer : Theme.surfaceContainerHigh
        radius: Shape.full
    }

    StateLayer {
        anchors.fill: parent
        contentColor: root.contentColor
        hovered: hover.hovered
        pressed: root._pressed
        focused: root.activeFocus
        radius: Shape.full
    }

    QQ.Row {
        id: content

        anchors.centerIn: parent
        spacing: Sizing.pillGap

        Icon {
            anchors.verticalCenter: parent.verticalCenter
            visible: root.icon.length > 0
            name: root.icon
            size: Sizing.smallIconSize
            color: root.contentColor
        }

        Text {
            anchors.verticalCenter: parent.verticalCenter
            visible: root.text.length > 0
            text: root.text
            role: "labelLarge"
            color: root.contentColor
        }

        QQ.Loader {
            anchors.verticalCenter: parent.verticalCenter
            visible: item !== null
            sourceComponent: root.trailing
        }
    }

    QQ.HoverHandler {
        id: hover
    }

    QQ.TapHandler {
        id: leftTap

        acceptedButtons: Qt.LeftButton
        onTapped: root.clicked()
    }

    QQ.TapHandler {
        id: rightTap

        acceptedButtons: Qt.RightButton
        onTapped: root.rightClicked()
    }
}
