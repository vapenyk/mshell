pragma ComponentBehavior: Bound

import qs.components as Components
import qs.config
import qs.services

import QtQuick as QQ

Components.Pill {
    id: root

    icon: "notifications"
    idleContainer: Theme.transparent
    active: UiState.openPopup === "notifications" && UiState.popupAnchor === root
    activeFocusOnTab: true

    QQ.Accessible.role: QQ.Accessible.Button
    QQ.Accessible.name: Notifs.unread ? qsTr("Notifications, unread") : qsTr("Notifications")
    QQ.Accessible.onPressAction: root.clicked()
    QQ.Keys.onReturnPressed: root.clicked()
    QQ.Keys.onSpacePressed: root.clicked()
    onClicked: UiState.toggleAt("notifications", root)

    QQ.Rectangle {
        anchors {
            top: parent.top
            right: parent.right
            margins: Sizing.pillGap
        }
        width: Sizing.notificationDotSize
        height: width
        radius: Shape.full
        color: Theme.tertiary
        visible: Notifs.unread
    }
}
