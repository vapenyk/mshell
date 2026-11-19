pragma ComponentBehavior: Bound

import qs.config

import Quickshell.Services.Notifications
import QtQuick

Flow {
    id: root

    required property var actions
    required property string link
    property bool canReply: false
    readonly property bool hasActions: canReply || link.length > 0 || actionButtons.count > 0
    signal replyRequested()
    signal actionRequested(action: NotificationAction)

    spacing: Sizing.popupGap

    function focusReply(): void {
        if (visible && canReply)
            replyButton.forceActiveFocus(Qt.OtherFocusReason);
    }

    Repeater {
        id: actionButtons

        model: root.actions.filter(action => action && action.identifier !== "default" && action.identifier !== "inline-reply")

        delegate: NotifActionButton {
            required property NotificationAction modelData

            text: modelData?.text ?? ""
            enabled: modelData !== null
            onClicked: root.actionRequested(modelData)
        }
    }

    NotifActionButton {
        id: replyButton

        visible: root.canReply
        text: qsTr("Reply")
        onClicked: root.replyRequested()
    }

    NotifActionButton {
        visible: root.link.length > 0
        outlined: true
        text: qsTr("Open link")
        onClicked: Qt.openUrlExternally(root.link)
    }
}
