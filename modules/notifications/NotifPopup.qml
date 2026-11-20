pragma ComponentBehavior: Bound

import "NotifPopup.model.js" as Model

import qs.config
import qs.services

import Quickshell
import Quickshell.Services.Notifications
import QtQuick

Scope {
    id: root

    property list<Toast> _popups: []
    property var _pending: []

    function _show(entry: QtObject, screen: ShellScreen): void {
        const existing = _popups.find(toast => toast.entry === entry && !toast.leaving);
        const request = {
            entry, screen: existing?.screen ?? screen,
            critical: entry.notification.urgency === NotificationUrgency.Critical
        };
        if (!_canShow(request)) {
            _dropPending(item => item.entry === entry);
            if (existing)
                existing.leaving = true;
            _expireIfHidden(entry);
            return;
        }
        if (existing) {
            existing.arrivedAt = entry.arrivedAt;
            existing.refreshed();
            return;
        }
        const previous = _pending;
        _pending = Model.enqueue(previous, request);
        for (const item of previous)
            _expireIfHidden(item.entry);
        _pump();
    }

    function _canShow(request: var): bool {
        return Notifs.contains(request.entry) && request.entry.routing.popup
            && UiState.openPopup !== "notifications" && (!Modes.dndOn || request.critical)
            && Quickshell.screens.includes(request.screen);
    }

    function _expireIfHidden(entry: QtObject): void {
        if (!_popups.some(toast => toast.entry === entry) && !_pending.some(item => item.entry === entry))
            Notifs.expireTransient(entry);
    }

    function _dropPending(match: var): void {
        const dropped = _pending.filter(match);
        _pending = _pending.filter(item => !dropped.includes(item));
        for (const item of dropped)
            _expireIfHidden(item.entry);
    }

    function _pump(): void {
        _dropPending(item => !_canShow(item));
        while (_pending.length > 0 && _popups.length < Sizing.notificationPopupLimit) {
            const { entry, screen } = _pending[0];
            _pending = _pending.slice(1);
            const toast = toastComponent.createObject(root, {
                entry, screen, notification: entry.notification, arrivedAt: entry.arrivedAt
            });
            _popups = [..._popups, toast];
        }
        if (_pending.length === 0)
            return;
        const candidate = Model.overflowCandidate(_popups, _pending[0].critical);
        if (candidate)
            candidate.leaving = true;
        else if (!_popups.some(toast => toast.leaving))
            _dropPending(() => true);
    }

    function _remove(toast: Toast): void {
        if (!_popups.includes(toast))
            return;
        const entry = toast.entry;
        _popups = _popups.filter(item => item !== toast);
        toast.destroy();
        _expireIfHidden(entry);
        _pump();
    }

    Connections {
        target: Notifs

        function onPopupRequested(entry: QtObject): void {
            root._show(entry, Compositor.focusedScreen);
        }

        function onEntryRemoved(entry: QtObject): void {
            root._dropPending(item => item.entry === entry);
            for (const toast of Array.from(root._popups)) {
                if (toast.entry === entry)
                    toast.leaving = true;
            }
        }
    }

    Connections {
        target: UiState

        function onOpenPopupChanged(): void {
            if (UiState.openPopup === "notifications") {
                root._dropPending(() => true);
                for (const toast of root._popups)
                    toast.leaving = true;
            }
        }
    }

    Connections {
        target: Modes

        function onDndOnChanged(): void {
            if (!Modes.dndOn)
                return;
            root._dropPending(item => !item.critical);
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

        NotifPopupWindow {
            required property ShellScreen modelData

            screenModel: modelData
            toasts: root._popups.filter(toast => toast.screen === screenModel)
            onToastExited: toast => root._remove(toast)
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
        signal refreshed()
        readonly property bool critical: notification?.urgency === NotificationUrgency.Critical
        readonly property int timeout: Model.timeoutFor(notification?.expireTimeout ?? -1, critical, Motion.notificationTimeout)
    }
}
