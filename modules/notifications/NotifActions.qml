pragma ComponentBehavior: Bound

import qs.config

import Quickshell.Services.Notifications
import QtQuick

Flow {
    id: root

    required property var actions
    required property string link
    readonly property bool hasActions: link.length > 0 || actionButtons.count > 0
    signal actionRequested(action: NotificationAction)

    spacing: Sizing.popupGap

    Repeater {
        id: actionButtons

        model: root.actions.filter(action => action.identifier !== "default" && action.identifier !== "inline-reply")

        delegate: NotifActionButton {
            required property NotificationAction modelData

            text: modelData.text
            onClicked: root.actionRequested(modelData)
        }
    }

    NotifActionButton {
        visible: root.link.length > 0
        outlined: true
        text: qsTr("Open link")
        onClicked: Qt.openUrlExternally(root.link)
    }
}
