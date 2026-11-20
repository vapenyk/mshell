pragma ComponentBehavior: Bound

import qs.components as Components
import qs.config
import qs.services

import Quickshell
import QtQuick
import QtQuick.Layouts as Layouts

Scope {
    id: root

    required property list<QtObject> barWindows
    readonly property Item requestedAnchor: UiState.openPopup === "notifications" ? UiState.popupAnchor : null

    Components.AnchoredPopup {
        requestedAnchor: root.requestedAnchor
        preferredWidth: Sizing.notificationPopupWidth
        barWindows: root.barWindows
        onDismissRequested: UiState.close()

        content: Column {
            id: content

            width: parent.width
            spacing: Sizing.popupGap
            property bool historyOpen: false
            readonly property int count: Notifs.notifications.length

            GroupSection {
                visible: !content.historyOpen && groups.length > 0
                width: parent.width
                groups: Notifs.sections.alerting.groups
            }

            Row {
                visible: !content.historyOpen && Notifs.sections.silent.count > 0
                width: parent.width
                spacing: Sizing.pillGap

                Components.Text {
                    width: Math.max(0, parent.width - clearSilent.width - parent.spacing)
                    height: clearSilent.height
                    text: qsTr("Silent")
                    role: "titleSmall"
                    verticalAlignment: Text.AlignVCenter
                }

                Components.IconButton {
                    id: clearSilent

                    text: qsTr("Clear silent notifications")
                    iconName: "close"
                    onClicked: Notifs.clearSilent()
                }
            }

            GroupSection {
                visible: !content.historyOpen && groups.length > 0
                width: parent.width
                groups: Notifs.sections.silent.groups
            }

            Loader {
                width: parent.width
                active: content.historyOpen && Notifs.history.length > 0
                visible: active
                sourceComponent: NotifHistory {}
            }

            Column {
                width: parent.width
                visible: content.historyOpen ? Notifs.history.length === 0 : content.count === 0
                padding: Sizing.popupInnerPadding
                spacing: Sizing.popupInnerPadding

                Components.Icon {
                    anchors.horizontalCenter: parent.horizontalCenter
                    name: content.historyOpen ? "history" : "emoji_events"
                    size: Sizing.pillHeight
                }
                Components.Text {
                    width: parent.width - 2 * parent.padding
                    text: content.historyOpen ? qsTr("No notification history") : qsTr("You’re all caught up")
                    horizontalAlignment: Text.AlignHCenter
                    role: "titleMedium"
                }
            }

            Layouts.RowLayout {
                width: parent.width
                spacing: Sizing.popupGap

                Components.IconButton {
                    id: historyButton

                    text: content.historyOpen ? qsTr("Back to notifications") : qsTr("Notification history")
                    iconName: content.historyOpen ? "arrow_back" : "history"
                    variant: "tonal"
                    onClicked: content.historyOpen = !content.historyOpen
                }

                Components.Pill {
                    Layouts.Layout.fillWidth: true
                    implicitHeight: historyButton.implicitHeight
                    visible: !content.historyOpen && content.count > 0
                    text: qsTr("Clear all")
                    onClicked: Notifs.clearAll()
                }
            }
        }
    }

    component GroupSection: Column {
        id: section

        required property var groups
        spacing: Sizing.popupGap

        Repeater {
            model: ScriptModel {
                values: section.groups.map(group => group.key)
            }

            delegate: NotifGroup {
                required property var modelData

                width: section.width
                group: section.groups.find(group => group.key === modelData)
            }
        }
    }
}
