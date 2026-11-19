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
    readonly property bool replying: expanded && reply.editing
    property int topRadius: Shape.large
    property int bottomRadius: Shape.large

    signal groupToggleRequested()
    signal dismissRequested()
    signal actionRequested(action: NotificationAction)
    readonly property var _actions: Array.from(notification?.actions ?? [])
    readonly property NotificationAction _defaultAction: _actions.find(action => action.identifier === "default") ?? null
    readonly property string _body: notification?.body ?? ""
    readonly property string _link: expanded ? Model.webLink(_body) : ""
    readonly property string _age: Format.relative(arrivedAt, Time.date)
    readonly property string _app: notification?.appName || qsTr("Notification")
    readonly property string _appIcon: notification?.appIcon || notification?.desktopEntry || ""

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

    QQL.RowLayout {
        id: content
        anchors {
            fill: parent
            margins: Sizing.popupInnerPadding
        }
        spacing: Sizing.popupGap
        QQ.Item {
            QQL.Layout.alignment: Qt.AlignTop
            QQL.Layout.minimumWidth: implicitWidth
            QQL.Layout.maximumWidth: implicitWidth
            implicitWidth: Sizing.pillHeight
            implicitHeight: implicitWidth

            QQ.Image {
                id: appImage
                anchors.fill: parent
                fillMode: QQ.Image.PreserveAspectFit
                source: root._appIcon.startsWith("/") ? "file://" + root._appIcon
                    : root._appIcon.startsWith("file:") ? root._appIcon
                    : root._appIcon ? Quickshell.iconPath(root._appIcon, true) : ""
            }

            Components.Icon {
                anchors.centerIn: parent
                visible: appImage.status !== QQ.Image.Ready
                name: "notifications"
                color: Theme.onSurfaceVariant
            }
        }

        QQL.ColumnLayout {
            QQL.Layout.fillWidth: true
            spacing: Sizing.pillGap

            QQL.RowLayout {
                QQL.Layout.fillWidth: true
                spacing: Sizing.pillGap
                Components.Text {
                    QQL.Layout.fillWidth: true
                    role: "labelMedium"
                    color: Theme.onSurfaceVariant
                    text: root._age ? qsTr("%1 · %2").arg(root._app).arg(root._age) : root._app
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
                    activeFocusOnTab: visible
                    QQ.Accessible.role: QQ.Accessible.Button
                    QQ.Accessible.name: root.groupExpanded ? qsTr("Collapse group") : qsTr("Expand group")
                    QQ.Accessible.onPressAction: root.groupToggleRequested()
                    QQ.Keys.onReturnPressed: root.groupToggleRequested()
                    QQ.Keys.onSpacePressed: root.groupToggleRequested()
                    onClicked: root.groupToggleRequested()
                }
                Components.IconButton {
                    QQL.Layout.preferredWidth: Sizing.pillHeight
                    QQL.Layout.preferredHeight: Sizing.pillHeight
                    visible: root.groupCount <= 1 || root.groupExpanded
                    text: root.expanded ? qsTr("Collapse notification") : qsTr("Expand notification")
                    iconName: root.expanded ? "expand_less" : "expand_more"
                    onClicked: root.expanded = !root.expanded
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

            Components.Text {
                QQL.Layout.fillWidth: true
                visible: text.length > 0
                role: "titleSmall"
                text: root.notification?.summary ?? ""
                wrapMode: root.expanded ? QQ.Text.Wrap : QQ.Text.NoWrap
                elide: root.expanded ? QQ.Text.ElideNone : QQ.Text.ElideRight
            }

            Components.Text {
                QQL.Layout.fillWidth: true
                visible: text.length > 0
                role: "bodyMedium"
                color: Theme.onSurfaceVariant
                text: root.expanded ? root._body : root._body.replace(/\s+/g, " ")
                wrapMode: root.expanded ? QQ.Text.Wrap : QQ.Text.NoWrap
                elide: root.expanded ? QQ.Text.ElideNone : QQ.Text.ElideRight
            }

            NotifActions {
                QQL.Layout.fillWidth: true
                visible: root.expanded && hasActions
                actions: root.expanded ? root._actions : []
                link: root._link
                onActionRequested: action => root.actionRequested(action)
            }

            NotifReply {
                id: reply

                QQL.Layout.fillWidth: true
                visible: root.expanded && (root.notification?.hasInlineReply ?? false)
                placeholder: root.notification?.inlineReplyPlaceholder || qsTr("Type a reply")
                onSubmitted: text => {
                    if (root.notification?.hasInlineReply)
                        root.notification.sendInlineReply(text);
                }
            }
        }
    }
}
