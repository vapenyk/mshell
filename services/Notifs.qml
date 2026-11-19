pragma Singleton
pragma ComponentBehavior: Bound

import "../utils/Grouping.js" as Grouping

import Quickshell
import Quickshell.Io
import Quickshell.Services.Notifications
import QtQml

Singleton {
    id: root

    readonly property list<Entry> notifications: _entries
    readonly property bool unread: _entries.some(entry => entry.unread)
    readonly property var history: _history
    property var _history: []
    readonly property var sections: Grouping.sections(notifications)
    property list<Entry> _entries: []

    signal popupRequested(entry: Entry)

    function dismiss(entry: Entry): void {
        if (entry && _entries.includes(entry))
            entry.notification.dismiss();
    }

    function clearAll(): void {
        for (const entry of Array.from(_entries))
            dismiss(entry);
    }

    function clearSilent(): void {
        for (const entry of Array.from(_entries).filter(item => item.silent))
            dismiss(entry);
    }

    function invoke(action: NotificationAction): void {
        action?.invoke();
    }

    function _remove(entry: Entry): void {
        if (!entry.notification.transient) {
            _history = [{
                appName: entry.appName,
                summary: entry.notification.summary,
                body: entry.notification.body,
                arrivedAt: entry.arrivedAt
            }, ..._history];
        }
        _entries = _entries.filter(item => item !== entry);
        entry.destroy();
    }

    NotificationServer {
        actionsSupported: true
        persistenceSupported: true
        imageSupported: true

        onNotification: notification => {
            if (root._entries.some(entry => entry.notification.id === notification.id))
                return;

            notification.tracked = true;
            const entry = entryComponent.createObject(root, {
                notification,
                arrivedDuringDnd: Modes.dndOn,
                unread: !notification.lastGeneration && UiState.openPopup !== "notifications"
            });
            root._entries = [...root._entries, entry];
            if (!notification.lastGeneration && entry.routing.popup)
                root.popupRequested(entry);
        }
    }

    Connections {
        target: UiState

        function onOpenPopupChanged(): void {
            if (UiState.openPopup === "notifications") {
                for (const entry of root._entries)
                    entry.unread = false;
            }
        }
    }

    IpcHandler {
        target: "notifs"

        function toggleDnd(): void {
            Modes.toggleDnd();
        }

        function clear(): void {
            root.clearAll();
        }
    }

    Component {
        id: entryComponent

        Entry {}
    }

    component Entry: Scope {
        id: entry

        required property Notification notification
        required property bool arrivedDuringDnd
        required property bool unread
        readonly property date arrivedAt: new Date()
        readonly property string appName: notification.appName
        readonly property string desktopEntry: notification.desktopEntry
        readonly property var routing: Grouping.route(notification.urgency, arrivedDuringDnd,
            NotificationUrgency.Low, NotificationUrgency.Critical)
        readonly property bool silent: routing.silent

        Connections {
            target: entry.notification

            function onClosed(): void {
                root._remove(entry);
            }
        }
    }
}
