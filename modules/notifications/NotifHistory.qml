pragma ComponentBehavior: Bound

import "../../utils/Format.js" as Format

import qs.components as Components
import qs.config
import qs.services

import Quickshell
import QtQuick

Column {
    id: root

    spacing: Sizing.popupGap

    Components.Text {
        width: parent.width
        text: qsTr("Notification history")
        role: "titleSmall"
    }

    Repeater {
        model: Notifs.history

        delegate: Components.Surface {
            id: historyRow

            required property var modelData

            width: root.width
            implicitHeight: labels.implicitHeight + 2 * Sizing.popupInnerPadding
            container: Theme.surfaceContainerHigh
            radius: Shape.large

            Column {
                id: labels

                anchors {
                    left: parent.left
                    right: parent.right
                    top: parent.top
                    margins: Sizing.popupInnerPadding
                }
                spacing: Sizing.pillGap

                Components.Text {
                    width: parent.width
                    text: qsTr("%1 · %2").arg(historyRow.modelData.appName || qsTr("Notification"))
                        .arg(Format.relative(historyRow.modelData.arrivedAt, Time.date))
                    role: "labelMedium"
                    color: Theme.onSurfaceVariant
                }
                Components.Text {
                    width: parent.width
                    text: historyRow.modelData.summary
                    role: "titleSmall"
                }
                Components.Text {
                    width: parent.width
                    visible: text.length > 0
                    text: historyRow.modelData.body
                    color: Theme.onSurfaceVariant
                    elide: Text.ElideNone
                    wrapMode: Text.Wrap
                }

                NotifActionButton {
                    visible: historyRow.modelData.replyDraft.length > 0
                    text: qsTr("Copy unsent reply")
                    onClicked: Quickshell.clipboardText = historyRow.modelData.replyDraft
                }
            }
        }
    }
}
