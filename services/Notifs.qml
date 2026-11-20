pragma Singleton
pragma ComponentBehavior: Bound

import "../utils/Grouping.js" as Grouping
import "Notifs.model.js" as Model

import Quickshell
import Quickshell.Io
import Quickshell.Services.Notifications
import QtQml

Singleton {
    id: root

    readonly property list<Entry> notifications: _entries.filter(entry => !entry.notification.transient)
    readonly property bool unread: notifications.some(entry => entry.unread)
    readonly property var history: _history
    property var _history: []
    readonly property var sections: Grouping.sections(notifications)
    property list<Entry> _entries: []

    signal popupRequested(entry: Entry)
    signal entryRemoved(entry: Entry)

    function contains(entry: Entry): bool {
        return entry !== null && _entries.includes(entry);
    }

    function expireTransient(entry: Entry): void {
        if (contains(entry) && entry.notification.transient && entry.notification.tracked)
            entry.notification.expire();
    }

    function dismiss(entry: Entry): void {
        if (contains(entry))
            entry.notification.dismiss();
    }

    function clearAll(): void {
        for (const entry of Array.from(notifications))
            dismiss(entry);
    }

    function clearSilent(): void {
        for (const entry of Array.from(notifications).filter(item => item.silent))
            dismiss(entry);
    }

    function invoke(action: NotificationAction): void {
        action?.invoke();
    }

    function _remove(entry: Entry): void {
        _history = Model.historyAfterClose(_history, entry);
        _entries = _entries.filter(item => item !== entry);
        entryRemoved(entry);
        entry.destroy();
    }

    function _deliver(entry: Entry): void {
        if (!contains(entry))
            return;
        const carriedOver = entry.notification.lastGeneration && entry.firstDelivery;
        entry.firstDelivery = false;
        if (carriedOver)
            expireTransient(entry);
        else
            popupRequested(entry);
    }

    NotificationServer {
        actionsSupported: true
        inlineReplySupported: true
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
            // The server registers the new ID after this handler returns.
            Qt.callLater(() => root._deliver(entry));
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
        property date arrivedAt: new Date()
        property string replyDraft: ""
        property bool firstDelivery: true
        readonly property double notificationId: notification.id
        readonly property string appName: notification.appName
        readonly property string desktopEntry: notification.desktopEntry
        readonly property var _actionLabels: notification.actions.map(action => action.text)
        readonly property var routing: Grouping.route(notification.urgency, arrivedDuringDnd,
            NotificationUrgency.Low, NotificationUrgency.Critical)
        readonly property bool silent: routing.silent

        on_ActionLabelsChanged: {
            if (root.contains(entry))
                Qt.callLater(entry.refresh);
        }

        function refresh(): void {
            if (!root.contains(entry))
                return;
            arrivedDuringDnd = Modes.dndOn;
            arrivedAt = new Date();
            unread = UiState.openPopup !== "notifications";
            firstDelivery = false;
            root._deliver(entry);
        }

        Connections {
            target: entry.notification

            // Replacements update the same object. Coalesce its property changes per delivery.
            function onSummaryChanged(): void { Qt.callLater(entry.refresh); }
            function onBodyChanged(): void { Qt.callLater(entry.refresh); }
            function onHintsChanged(): void { Qt.callLater(entry.refresh); }
            function onImageChanged(): void { Qt.callLater(entry.refresh); }
            function onAppNameChanged(): void { Qt.callLater(entry.refresh); }
            function onAppIconChanged(): void { Qt.callLater(entry.refresh); }
            function onHasInlineReplyChanged(): void { Qt.callLater(entry.refresh); }
            function onInlineReplyPlaceholderChanged(): void { Qt.callLater(entry.refresh); }
            function onExpireTimeoutChanged(): void { Qt.callLater(entry.refresh); }

            function onClosed(): void {
                root._remove(entry);
            }
        }
    }
}
