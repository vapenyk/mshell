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

    readonly property bool _hasImage: notificationImage.status === QQ.Image.Ready
    readonly property bool _avatar: _hasImage
        && Model.conversationAvatar(category, notificationImage.sourceSize.width, notificationImage.sourceSize.height)
    readonly property bool _preview: _hasImage && !_avatar
    readonly property QQ.Item _imageSlot: (root._avatar ? avatar.item : root.expanded ? preview.item : thumbnail.item)?.contentItem ?? null

    spacing: Sizing.popupGap
    QQ.Item {
        id: leading
        QQL.Layout.alignment: Qt.AlignTop
        QQL.Layout.minimumWidth: implicitWidth
        QQL.Layout.maximumWidth: implicitWidth
        implicitWidth: Sizing.notificationAvatarSize
        implicitHeight: implicitWidth

        QQ.Image {
            id: notificationImage

            parent: root._imageSlot ?? leading
            visible: root._imageSlot !== null
            anchors.fill: parent
            fillMode: root.expanded && !root._avatar ? QQ.Image.PreserveAspectFit : QQ.Image.PreserveAspectCrop
            source: root.image
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
                asynchronous: true
                readonly property int _decodeSize: Math.ceil(Sizing.notificationAvatarSize * QQ.Screen.devicePixelRatio)
                sourceSize: Qt.size(_decodeSize, _decodeSize)
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

        NotifCardHeader {
            QQL.Layout.fillWidth: true
            appLabel: root.appLabel
            groupCount: root.groupCount
            groupExpanded: root.groupExpanded
            expanded: root.expanded
            onGroupToggleRequested: root.groupToggleRequested()
            onExpandRequested: root.expandRequested()
            onDismissRequested: root.dismissRequested()
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
                width * notificationImage.sourceSize.height / Math.max(1, notificationImage.sourceSize.width)) : 0
            sourceComponent: attachmentClip
        }
    }

    QQ.Component {
        id: attachmentClip
        Widgets.ClippingRectangle { radius: Shape.small; color: Theme.transparent }
    }
}
