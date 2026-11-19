pragma ComponentBehavior: Bound

import "NotifPopup.model.js" as Model

import qs.config
import qs.services

import Quickshell
import Quickshell.Services.Notifications
import Quickshell.Wayland
import QtQuick

Scope {
    id: root

    property list<Toast> _popups: []
    property var _pending: null

    function _show(entry: QtObject, screen: ShellScreen): void {
        if (!screen || !Quickshell.screens.includes(screen) || !Notifs.notifications.includes(entry))
            return;
        if (_popups.length < Sizing.notificationPopupLimit) {
            const toast = toastComponent.createObject(root, {
                entry, screen, notification: entry.notification, arrivedAt: entry.arrivedAt
            });
            _popups = [..._popups, toast];
            return;
        }
        const candidate = Model.overflowCandidate(_popups);
        if (candidate || _popups.some(toast => toast.leaving)) {
            const critical = entry.notification.urgency === NotificationUrgency.Critical;
            if (!_pending?.critical || critical)
                _pending = { entry, screen, critical };
            if (candidate && !_popups.some(toast => toast.leaving))
                candidate.leaving = true;
        }
    }

    function _remove(toast: Toast): void {
        if (!_popups.includes(toast))
            return;
        _popups = _popups.filter(item => item !== toast);
        toast.destroy();
        if (_pending) {
            const next = _pending;
            _pending = null;
            _show(next.entry, next.screen);
        }
    }

    Connections {
        target: Notifs

        function onPopupRequested(entry: QtObject): void {
            root._show(entry, Compositor.focusedScreen);
        }

        function onNotificationsChanged(): void {
            for (const toast of Array.from(root._popups)) {
                if (!Notifs.notifications.includes(toast.entry))
                    toast.leaving = true;
            }
        }
    }

    Connections {
        target: Modes

        function onDndOnChanged(): void {
            if (!Modes.dndOn)
                return;
            if (!root._pending?.critical)
                root._pending = null;
            for (const toast of root._popups) {
                if (!toast.critical)
                    toast.leaving = true;
            }
        }
    }

    Connections {
        target: Quickshell

        function onScreensChanged(): void {
            for (const toast of Array.from(root._popups)) {
                if (!Quickshell.screens.includes(toast.screen))
                    root._remove(toast);
            }
        }
    }

    Variants {
        model: Quickshell.screens

        PanelWindow {
            id: window

            required property ShellScreen modelData

            function cardAt(index: int): Item {
                const card = column.children.filter(item => item.toast !== undefined)[index];
                return card && !card.toast.leaving ? card : null;
            }

            screen: modelData
            visible: cards.count > 0
            anchors { top: true; right: true }
            margins.top: Sizing.barHeight + Sizing.popupGap
            margins.right: Sizing.barSideMargin
            implicitWidth: Math.max(1, Math.min(Sizing.notificationPopupWidth, modelData.width - 2 * Sizing.barSideMargin))
            implicitHeight: Math.min(column.implicitHeight, Math.max(1, modelData.height - margins.top - Sizing.barSideMargin))
            exclusionMode: ExclusionMode.Ignore
            color: Theme.transparent
            WlrLayershell.layer: WlrLayer.Overlay
            WlrLayershell.keyboardFocus: WlrKeyboardFocus.None
            WlrLayershell.namespace: "mshell-notifications"

            mask: Region {
                Region { item: window.cardAt(0) }
                Region { item: window.cardAt(1) }
                Region { item: window.cardAt(2) }
            }

            Flickable {
                anchors.fill: parent
                contentWidth: width
                contentHeight: column.implicitHeight
                interactive: contentHeight > height
                clip: true

                Column {
                    id: column

                    width: parent.width
                    spacing: Sizing.popupGap

                    Repeater {
                        id: cards

                        model: ScriptModel {
                            values: Array.from(root._popups).filter(toast => toast.screen === window.modelData)
                        }

                        delegate: NotifToast {
                            required property Toast modelData

                            toast: modelData
                            width: column.width
                            onExited: {
                                const finishedToast = modelData;
                                // Use a separate callback for each card that finishes on the same frame.
                                Qt.callLater(() => root._remove(finishedToast));
                            }
                        }
                    }
                }
            }
        }
    }

    Component {
        id: toastComponent

        Toast {}
    }

    component Toast: QtObject {
        required property QtObject entry
        required property ShellScreen screen
        property bool leaving: false
        required property Notification notification
        required property date arrivedAt
        readonly property bool critical: notification?.urgency === NotificationUrgency.Critical
        readonly property int timeout: Model.timeoutFor(notification?.expireTimeout ?? -1, critical, Motion.notificationTimeout)
    }
}
