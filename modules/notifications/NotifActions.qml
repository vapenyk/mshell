pragma ComponentBehavior: Bound

import "NotifCard.model.js" as Model

import qs.components as Components
import qs.config

import Quickshell
import Quickshell.Services.Notifications
import QtQuick

Flow {
    id: root

    required property var actions
    required property string link
    required property string copyText
    property bool canReply: false
    readonly property bool hasActions: canReply || link.length > 0 || copyText.length > 0 || actionButtons.count > 0
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
        visible: root.copyText.length > 0
        text: qsTr("Copy text")
        onClicked: Quickshell.clipboardText = root.copyText
    }

    NotifActionButton {
        id: linkButton

        visible: root.link.length > 0
        outlined: true
        text: qsTr("Open link")
        Accessible.description: tooltip.text
        onClicked: Qt.openUrlExternally(root.link)

        Components.Tooltip {
            id: tooltip

            requested: linkButton.hovered || linkButton.visualFocus
            text: Model.webHost(root.link)
        }
    }
}
