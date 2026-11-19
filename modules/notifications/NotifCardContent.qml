pragma ComponentBehavior: Bound

import "NotifCard.model.js" as Model

import qs.components as Components
import qs.config

import Quickshell.Widgets as Widgets
import QtQuick as QQ
import QtQuick.Layouts as QQL

QQL.RowLayout {
    id: root
    required property string appLabel
    required property string title
    required property string body
    required property url appIcon
    required property url image
    required property string category
    required property bool expanded
    required property int groupCount
    required property bool groupExpanded

    signal groupToggleRequested()
    signal expandRequested()
    signal dismissRequested()

    readonly property bool _hasImage: imageProbe.status === QQ.Image.Ready
    readonly property bool _avatar: _hasImage
        && Model.conversationAvatar(category, imageProbe.sourceSize.width, imageProbe.sourceSize.height)
    readonly property bool _preview: _hasImage && !_avatar
    readonly property QQ.Item _imageSlot: (root._avatar ? avatar.item : root.expanded ? preview.item : thumbnail.item)?.contentItem ?? null

    spacing: Sizing.popupGap
    QQ.Image {
        id: imageProbe
        source: root.image
        visible: false
        asynchronous: true
    }
    QQ.Item {
        id: leading
        QQL.Layout.alignment: Qt.AlignTop
        QQL.Layout.minimumWidth: implicitWidth
        QQL.Layout.maximumWidth: implicitWidth
        implicitWidth: Sizing.notificationAvatarSize
        implicitHeight: implicitWidth

        QQ.Image {
            parent: root._imageSlot ?? leading
            visible: root._imageSlot !== null
            anchors.fill: parent
            fillMode: root.expanded && !root._avatar ? QQ.Image.PreserveAspectFit : QQ.Image.PreserveAspectCrop
            source: root._hasImage ? root.image : ""
            asynchronous: true
        }

        QQ.Loader {
            id: avatar
            anchors.fill: parent
            active: root._avatar
            sourceComponent: Widgets.ClippingRectangle { radius: Shape.full; color: Theme.transparent }
        }

        QQ.Rectangle {
            width: root._avatar ? Sizing.notificationBadgeSize : leading.width
            height: width
            anchors.right: parent.right
            anchors.bottom: parent.bottom
            radius: Shape.full
            color: root._avatar ? Theme.surfaceContainerHigh : Theme.transparent
            visible: !root._avatar || appImage.status === QQ.Image.Ready

            QQ.Image {
                id: appImage

                anchors.fill: parent
                anchors.margins: root._avatar ? Sizing.outlineWidth : Shape.none
                fillMode: QQ.Image.PreserveAspectFit
                source: root.appIcon
            }

            Components.Icon {
                anchors.centerIn: parent
                visible: appImage.status !== QQ.Image.Ready
                name: "notifications"
                color: Theme.onSurfaceVariant
            }
        }
    }

    QQL.ColumnLayout {
        QQL.Layout.fillWidth: true
        QQL.Layout.minimumWidth: Shape.none
        spacing: Sizing.pillGap

        QQL.RowLayout {
            QQL.Layout.fillWidth: true
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

        QQL.RowLayout {
            QQL.Layout.fillWidth: true
            spacing: Sizing.popupGap

            QQL.ColumnLayout {
                QQL.Layout.fillWidth: true
                QQL.Layout.minimumWidth: Shape.none
                spacing: Sizing.pillGap

                Components.Text {
                    QQL.Layout.fillWidth: true
                    visible: text.length > 0
                    role: "titleSmall"
                    text: root.title
                    wrapMode: root.expanded ? QQ.Text.Wrap : QQ.Text.NoWrap
                    elide: root.expanded ? QQ.Text.ElideNone : QQ.Text.ElideRight
                }

                Components.Text {
                    QQL.Layout.fillWidth: true
                    visible: text.length > 0
                    role: "bodyMedium"
                    color: Theme.onSurfaceVariant
                    text: root.expanded ? root.body : root.body.replace(/\s+/g, " ")
                    wrapMode: root.expanded ? QQ.Text.Wrap : QQ.Text.NoWrap
                    elide: root.expanded ? QQ.Text.ElideNone : QQ.Text.ElideRight
                }
            }

            QQ.Loader {
                id: thumbnail
                active: root._preview && !root.expanded
                visible: active
                QQL.Layout.preferredWidth: Sizing.notificationThumbnailWidth
                QQL.Layout.preferredHeight: Sizing.notificationThumbnailHeight
                sourceComponent: attachmentClip
            }
        }

        QQ.Loader {
            id: preview
            QQL.Layout.fillWidth: true
            active: root._preview && root.expanded
            visible: active
            QQL.Layout.preferredHeight: visible ? Math.min(Sizing.notificationPreviewMaxHeight,
                width * imageProbe.sourceSize.height / Math.max(1, imageProbe.sourceSize.width)) : 0
            sourceComponent: attachmentClip
        }
    }

    QQ.Component {
        id: attachmentClip
        Widgets.ClippingRectangle { radius: Shape.small; color: Theme.transparent }
    }
}
