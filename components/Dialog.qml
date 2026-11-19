pragma ComponentBehavior: Bound

import qs.config

import Quickshell
import Quickshell.Wayland
import QtQuick as QQ

PanelWindow {
    id: root

    required property ShellScreen targetScreen
    required property string title
    required property string message
    required property string confirmText

    signal accepted()
    signal rejected()

    screen: targetScreen
    visible: targetScreen !== null
    anchors { top: true; bottom: true; left: true; right: true }
    color: Theme.transparent
    exclusionMode: ExclusionMode.Ignore
    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.keyboardFocus: WlrKeyboardFocus.Exclusive
    WlrLayershell.namespace: "mshell-dialog"
    onClosed: rejected()

    QQ.FocusScope {
        anchors.fill: parent
        focus: true
        QQ.Keys.onEscapePressed: root.rejected()

        QQ.Rectangle {
            anchors.fill: parent
            color: Theme.scrim
            opacity: Theme.dialogScrimOpacity
        }

        QQ.MouseArea {
            anchors.fill: parent
            acceptedButtons: Qt.AllButtons
            onClicked: root.rejected()
        }

        Surface {
            anchors.centerIn: parent
            width: Math.min(Sizing.dialogWidth, parent.width - 2 * Sizing.barSideMargin)
            height: content.implicitHeight + 2 * Sizing.popupInnerPadding
            container: Theme.surfaceContainerHigh
            radius: Shape.extraLarge

            QQ.MouseArea { anchors.fill: parent; acceptedButtons: Qt.AllButtons }

            QQ.Column {
                id: content

                anchors.fill: parent
                anchors.margins: Sizing.popupInnerPadding
                spacing: Sizing.popupGap

                Text {
                    width: parent.width
                    text: root.title
                    role: "titleLarge"
                }

                Text {
                    width: parent.width
                    text: root.message
                    color: Theme.onSurfaceVariant
                    wrapMode: QQ.Text.WordWrap
                }

                QQ.Row {
                    anchors.right: parent.right
                    spacing: Sizing.pillGap

                    Button {
                        text: qsTr("Cancel")
                        variant: "tonal"
                        focus: true
                        onClicked: root.rejected()
                    }

                    Button {
                        text: root.confirmText
                        variant: "error"
                        onClicked: root.accepted()
                    }
                }
            }
        }
    }
}
