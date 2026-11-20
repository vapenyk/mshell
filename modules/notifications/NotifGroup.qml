pragma ComponentBehavior: Bound

import qs.config
import qs.services

import Quickshell
import QtQuick

Column {
    id: root

    required property var group
    property bool expanded: false
    readonly property bool _showAll: expanded && _items.length > 1
    readonly property var _items: group?.items ?? []

    spacing: Sizing.outlineWidth

    Repeater {
        model: ScriptModel {
            values: (root._showAll ? root._items : root._items.slice(0, 1)).map(entry => entry.notification.id)
        }

        delegate: NotifCard {
            required property double modelData
            readonly property bool first: root._items[0]?.notification.id === modelData
            readonly property bool last: root._items[root._items.length - 1]?.notification.id === modelData
            readonly property QtObject currentEntry: root._items.find(item => item.notification.id === modelData) ?? null

            width: root.width
            entry: currentEntry
            notification: currentEntry?.notification ?? null
            arrivedAt: currentEntry?.arrivedAt ?? new Date()
            copyEnabled: true
            groupCount: first ? root._items.length : 0
            groupExpanded: root._showAll
            topRadius: first ? Shape.large : Shape.extraSmall
            bottomRadius: !root._showAll || last ? Shape.large : Shape.extraSmall
            onGroupToggleRequested: root.expanded = !root.expanded
            onDismissRequested: Notifs.dismiss(currentEntry)
            onActionRequested: action => Notifs.invoke(action)
        }
    }
}
