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
    property Item _mountedAnchor: null

    onRequestedAnchorChanged: Qt.callLater(_syncPopup)

    function _syncPopup(): void {
        if (requestedAnchor && requestedAnchor !== _mountedAnchor) {
            loader.active = false;
            _mountedAnchor = requestedAnchor;
            loader.active = true;
        }
    }

    function _dismissPopup(window: QtObject): void {
        if (loader.item === window && window.opened)
            UiState.close();
    }

    function _unmountPopup(): void {
        if (!requestedAnchor) {
            loader.active = false;
            _mountedAnchor = null;
        }
    }

    LazyLoader {
        id: loader

        active: false

        Components.PopupWindow {
            id: popup

            anchorItem: root._mountedAnchor
            opened: anchorItem !== null && root.requestedAnchor === anchorItem
            preferredWidth: Sizing.notificationPopupWidth
            barWindows: root.barWindows
            onDismissRequested: Qt.callLater(root._dismissPopup, popup)
            onExited: Qt.callLater(root._unmountPopup)

            Column {
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
                        text: content.historyOpen ? qsTr("Back to notifications") : qsTr("Notification history")
                        iconName: content.historyOpen ? "arrow_back" : "history"
                        variant: "tonal"
                        onClicked: content.historyOpen = !content.historyOpen
                    }

                    Components.Pill {
                        Layouts.Layout.fillWidth: true
                        visible: !content.historyOpen && content.count > 0
                        text: qsTr("Clear all")
                        activeFocusOnTab: true
                        Accessible.role: Accessible.Button
                        Accessible.name: text
                        Accessible.onPressAction: Notifs.clearAll()
                        Keys.onReturnPressed: Notifs.clearAll()
                        Keys.onSpacePressed: Notifs.clearAll()
                        onClicked: Notifs.clearAll()
                    }
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
                required property string modelData

                width: section.width
                group: section.groups.find(group => group.key === modelData)
            }
        }
    }
}
