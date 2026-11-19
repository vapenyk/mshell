pragma ComponentBehavior: Bound

import qs.config

import QtQuick as QQ
import QtQuick.Controls as QQC
import QtQuick.Layouts as QQL

QQ.Item {
    id: root

    property bool active: false
    property bool iconOnly: false
    required property string icon
    required property string title
    property string subtitle: ""

    signal toggled()
    signal settingsRequested()

    implicitWidth: button.implicitWidth
    implicitHeight: Sizing.tileHeight

    QQC.AbstractButton {
        id: button

        anchors.fill: parent
        readonly property QQ.color _contentColor: root.active ? Theme.onPrimary : Theme.onSurface

        text: root.title
        padding: Sizing.tilePadding
        hoverEnabled: true
        focusPolicy: Qt.StrongFocus

        QQ.Accessible.checkable: true
        QQ.Accessible.checked: root.active
        QQ.Accessible.description: root.subtitle

        onClicked: root.toggled()

        QQ.Keys.onReturnPressed: button.click()
        QQ.Keys.onEnterPressed: button.click()
        QQ.Keys.onPressed: event => {
            if (event.key === Qt.Key_Menu
                    || (event.key === Qt.Key_F10 && event.modifiers === Qt.ShiftModifier)) {
                root.settingsRequested();
                event.accepted = true;
            }
        }

        QQ.TapHandler {
            id: settingsTap

            acceptedButtons: Qt.RightButton
            gesturePolicy: QQ.TapHandler.ReleaseWithinBounds
            onTapped: root.settingsRequested()
        }

        background: QQ.Rectangle {
            color: root.active ? Theme.primary : Theme.surfaceContainerHigh
            radius: Shape.extraLarge

            StateLayer {
                anchors.fill: parent
                radius: parent.radius
                contentColor: button._contentColor
                hovered: button.hovered
                pressed: button.down || settingsTap.pressed
                focused: button.visualFocus
            }
        }

        QQC.ToolTip.text: root.title
        QQC.ToolTip.visible: root.iconOnly && button.hovered
        QQC.ToolTip.delay: Motion.long2

        contentItem: QQ.Item {
            implicitWidth: root.iconOnly ? glyph.implicitWidth : labels.implicitWidth
            implicitHeight: root.iconOnly ? glyph.implicitHeight : labels.implicitHeight

            Icon {
                id: glyph

                anchors.centerIn: parent
                visible: root.iconOnly
                name: root.icon
                color: button._contentColor
                filled: root.active
            }

            QQL.RowLayout {
                id: labels

                anchors.fill: parent
                visible: !root.iconOnly
                spacing: Sizing.tilePadding

                QQ.Rectangle {
                    implicitWidth: Sizing.tileChipSize
                    implicitHeight: Sizing.tileChipSize
                    color: root.active ? Theme.primaryContainer : Theme.surfaceContainerHighest
                    radius: root.active ? Shape.large : height / 2

                    QQ.Behavior on radius {
                        QQ.SpringAnimation {
                            spring: Motion.spatialFast.spring
                            damping: Motion.spatialFast.damping
                            mass: Motion.spatialFast.mass
                        }
                    }

                    Icon {
                        anchors.centerIn: parent
                        name: root.icon
                        color: root.active ? Theme.onPrimary : Theme.onSurfaceVariant
                        filled: root.active
                    }
                }

                QQL.ColumnLayout {
                    QQL.Layout.fillWidth: true
                    QQL.Layout.minimumWidth: Shape.none
                    spacing: Shape.none

                    Text {
                        QQL.Layout.fillWidth: true
                        text: root.title
                        role: "labelLarge"
                        color: button._contentColor
                    }

                    Text {
                        QQL.Layout.fillWidth: true
                        visible: root.subtitle.length > 0
                        text: root.subtitle
                        role: "bodySmall"
                        color: root.active ? Theme.onPrimary : Theme.onSurfaceVariant
                    }
                }
            }
        }
    }
}
