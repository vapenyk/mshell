pragma ComponentBehavior: Bound

import "../../utils/Format.js" as Format
import "NotifCard.model.js" as Model

import qs.components as Components
import qs.config
import qs.services

import Quickshell
import Quickshell.Services.Notifications
import QtQuick as QQ
import QtQuick.Controls.Basic as Basic
import QtQuick.Layouts as QQL

QQ.Item {
    id: root
    required property Notification notification
    required property date arrivedAt
    property bool expanded: false
    property int groupCount: 0
    property bool groupExpanded: false
    readonly property bool replying: expanded && _canReply && reply.editing
    property int topRadius: Shape.large
    property int bottomRadius: Shape.large

    signal groupToggleRequested()
    signal dismissRequested()
    signal actionRequested(action: NotificationAction)
    readonly property var _actions: Array.from(notification?.actions ?? [])
    readonly property NotificationAction _defaultAction: _actions.find(action => action?.identifier === "default") ?? null
    readonly property string _body: notification?.body ?? ""
    readonly property string _link: expanded ? Model.webLink(_body) : ""
    readonly property string _age: Format.relative(arrivedAt, Time.date)
    readonly property string _app: notification?.appName || qsTr("Notification")
    readonly property bool _canReply: notification?.hasInlineReply ?? false
    readonly property string _entry: notification?.desktopEntry ?? ""
    readonly property string _appIcon: notification?.appIcon
        || (_entry ? DesktopEntries.byId(_entry)?.icon || _entry : "")
    readonly property url _iconSource: _appIcon.startsWith("/") ? "file://" + _appIcon
        : _appIcon.startsWith("file:") ? _appIcon : _appIcon ? Quickshell.iconPath(_appIcon, true) : ""

    onGroupExpandedChanged: {
        if (!groupExpanded && groupCount > 1)
            expanded = false;
    }

    implicitHeight: content.implicitHeight + 2 * Sizing.popupInnerPadding
    Basic.AbstractButton {
        id: bodyButton
        anchors.fill: parent
        hoverEnabled: true
        focusPolicy: Qt.StrongFocus
        QQ.Accessible.name: root.notification?.summary || root._app
        QQ.Accessible.description: root._body
        QQ.Keys.onReturnPressed: click()
        QQ.Keys.onEnterPressed: click()
        onClicked: {
            if (root._defaultAction)
                root.actionRequested(root._defaultAction);
            else
                root.dismissRequested();
        }

        background: Components.Surface {
            container: Theme.surfaceContainerHigh
            topLeftRadius: root.topRadius
            topRightRadius: root.topRadius
            bottomLeftRadius: root.bottomRadius
            bottomRightRadius: root.bottomRadius

            Components.StateLayer {
                anchors.fill: parent
                topLeftRadius: root.topRadius
                topRightRadius: root.topRadius
                bottomLeftRadius: root.bottomRadius
                bottomRightRadius: root.bottomRadius
                contentColor: Theme.onSurface
                hovered: bodyButton.hovered
                pressed: bodyButton.down
                focused: bodyButton.visualFocus
            }
        }
    }

    QQL.ColumnLayout {
        id: content

        anchors {
            fill: parent
            margins: Sizing.popupInnerPadding
        }
        spacing: Sizing.popupGap

        NotifCardContent {
            QQL.Layout.fillWidth: true
            appLabel: root._age ? qsTr("%1 · %2").arg(root._app).arg(root._age) : root._app
            title: root.notification?.summary ?? ""
            body: root._body
            appIcon: root._iconSource
            image: root.notification?.image ?? ""
            category: root.notification?.hints?.category ?? ""
            expanded: root.expanded
            groupCount: root.groupCount
            groupExpanded: root.groupExpanded
            onGroupToggleRequested: root.groupToggleRequested()
            onExpandRequested: root.expanded = !root.expanded
            onDismissRequested: root.dismissRequested()
        }

        NotifActions {
            id: actions

            QQL.Layout.fillWidth: true
            visible: root.expanded && !root.replying && hasActions
            actions: root.expanded ? root._actions : []
            link: root._link
            canReply: root.expanded && root._canReply
            onActionRequested: action => root.actionRequested(action)
            onReplyRequested: reply.startEditing()
        }

        NotifReply {
            id: reply

            QQL.Layout.fillWidth: true
            visible: root.replying
            placeholder: root.notification?.inlineReplyPlaceholder || qsTr("Type a reply")
            onCancelled: actions.focusReply()
            onSubmitted: text => {
                if (root._canReply && root.notification.tracked)
                    root.notification.sendInlineReply(text);
                if (root.notification?.tracked)
                    actions.focusReply();
            }
        }
    }
}
