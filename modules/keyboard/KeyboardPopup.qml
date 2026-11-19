pragma ComponentBehavior: Bound

import qs.components as Components
import qs.config
import qs.services

import Quickshell
import QtQuick as QQ
import QtQuick.Controls as QQC
import QtQuick.Layouts as QQL

Components.AnchoredPopup {
    requestedAnchor: UiState.openPopup === "keyboard" ? UiState.popupAnchor : null
    preferredWidth: Sizing.keyboardPopupWidth
    centerOnAnchor: true
    onDismissRequested: UiState.close()

    QQ.Connections {
        target: Keyboard

        function onLayoutsChanged(): void {
            if (UiState.openPopup === "keyboard" && Keyboard.layouts.length < 2)
                UiState.close();
        }
    }

    content: QQ.Column {
        spacing: Sizing.pillGap

        QQ.Repeater {
            id: rows

            model: ScriptModel {
                values: Keyboard.layouts
                objectProp: "index"
            }

            QQC.AbstractButton {
                id: row

                required property var modelData
                required property int index
                readonly property bool selected: Keyboard.current?.index === modelData.index
                readonly property QQ.color foreground: selected ? Theme.onSecondaryContainer : Theme.onSurface

                width: parent.width
                implicitHeight: Sizing.keyboardRowHeight
                leftPadding: Sizing.popupInnerPadding
                rightPadding: Sizing.popupInnerPadding
                topPadding: 0
                bottomPadding: 0
                hoverEnabled: true
                focusPolicy: Qt.StrongFocus
                text: modelData.label
                QQ.Accessible.checkable: true
                QQ.Accessible.checked: selected

                QQ.Component.onCompleted: {
                    if (selected)
                        forceActiveFocus(Qt.OtherFocusReason);
                }

                QQ.Keys.onUpPressed: rows.itemAt(index - 1)?.forceActiveFocus(Qt.TabFocusReason)
                QQ.Keys.onDownPressed: rows.itemAt(index + 1)?.forceActiveFocus(Qt.TabFocusReason)
                QQ.Keys.onReturnPressed: click()
                QQ.Keys.onEnterPressed: click()
                onClicked: {
                    Keyboard.switchTo(modelData.index);
                    UiState.close();
                }

                background: Components.Surface {
                    radius: Shape.large
                    container: row.selected ? Theme.secondaryContainer : Theme.surfaceContainerLow

                    Components.StateLayer {
                        anchors.fill: parent
                        radius: Shape.large
                        contentColor: row.foreground
                        hovered: row.hovered
                        pressed: row.down
                        focused: row.visualFocus
                    }
                }

                contentItem: QQL.RowLayout {
                    spacing: Sizing.popupGap

                    Components.Text {
                        QQL.Layout.preferredWidth: Sizing.pillHeight
                        text: row.modelData.code
                        horizontalAlignment: QQ.Text.AlignHCenter
                        role: "labelMedium"
                        color: row.foreground
                    }

                    Components.Text {
                        QQL.Layout.fillWidth: true
                        text: row.text
                        role: "titleMedium"
                        color: row.foreground
                    }
                }
            }
        }
    }
}
