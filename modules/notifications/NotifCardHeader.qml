pragma ComponentBehavior: Bound

import qs.components as Components
import qs.config

import QtQuick as QQ
import QtQuick.Layouts as QQL

QQL.RowLayout {
    id: root

    required property string appLabel
    required property int groupCount
    required property bool groupExpanded
    required property bool expanded
    signal groupToggleRequested()
    signal expandRequested()
    signal dismissRequested()

    spacing: Sizing.pillGap

    Components.Text {
        QQL.Layout.fillWidth: true
        QQL.Layout.minimumWidth: Shape.none
        role: "labelMedium"
        color: Theme.onSurfaceVariant
        text: root.appLabel
    }

    Components.Pill {
        visible: root.groupCount > 1
        text: root.groupCount.toString()
        idleContainer: Theme.surfaceContainerHighest
        trailing: Components.Icon {
            name: root.groupExpanded ? "expand_less" : "expand_more"
            size: Sizing.smallIconSize
            color: Theme.onSurfaceVariant
        }
        QQ.Accessible.name: root.groupExpanded ? qsTr("Collapse group") : qsTr("Expand group")
        onClicked: root.groupToggleRequested()
    }

    Components.IconButton {
        QQL.Layout.preferredWidth: Sizing.pillHeight
        QQL.Layout.preferredHeight: Sizing.pillHeight
        visible: root.groupCount <= 1 || root.groupExpanded
        text: root.expanded ? qsTr("Collapse notification") : qsTr("Expand notification")
        iconName: root.expanded ? "expand_less" : "expand_more"
        onClicked: root.expandRequested()
    }

    Components.IconButton {
        QQL.Layout.preferredWidth: Sizing.pillHeight
        QQL.Layout.preferredHeight: Sizing.pillHeight
        visible: root.expanded
        text: qsTr("Dismiss notification")
        iconName: "close"
        onClicked: root.dismissRequested()
    }
}
