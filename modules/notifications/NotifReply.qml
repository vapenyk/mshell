pragma ComponentBehavior: Bound

import qs.components as Components
import qs.config

import QtQuick as QQ
import QtQuick.Controls.Basic as Basic
import QtQuick.Layouts as QQL

QQL.RowLayout {
    id: root

    required property string placeholder
    property bool editing: false
    signal submitted(text: string)

    spacing: Sizing.pillGap

    onVisibleChanged: {
        if (!visible)
            editing = false;
    }

    function _send(): void {
        if (field.text.trim().length === 0)
            return;
        const text = field.text;
        field.clear();
        editing = false;
        submitted(text);
    }

    NotifActionButton {
        visible: !root.editing
        text: qsTr("Reply")
        onClicked: {
            root.editing = true;
            field.forceActiveFocus(Qt.OtherFocusReason);
        }
    }

    Basic.TextField {
        id: field

        QQL.Layout.fillWidth: true
        visible: root.editing
        implicitHeight: Sizing.pillHeight
        leftPadding: Sizing.pillHorizontalPadding
        rightPadding: Sizing.pillHorizontalPadding
        color: Theme.onSurface
        placeholderTextColor: Theme.onSurfaceVariant
        selectionColor: Theme.primary
        selectedTextColor: Theme.onPrimary
        placeholderText: root.placeholder
        font.family: Typography.family
        font.pixelSize: Typography.bodyMedium.size
        selectByMouse: true
        QQ.Accessible.name: qsTr("Reply")
        onAccepted: root._send()
        QQ.Keys.onEscapePressed: {
            root.editing = false;
        }

        background: QQ.Rectangle {
            color: Theme.surfaceContainerHighest
            radius: Shape.small
            border.width: Sizing.outlineWidth
            border.color: field.activeFocus ? Theme.primary : Theme.outline
        }
    }

    Components.IconButton {
        QQL.Layout.preferredWidth: Sizing.pillHeight
        QQL.Layout.preferredHeight: Sizing.pillHeight
        visible: root.editing
        enabled: field.text.trim().length > 0
        iconName: "send"
        text: qsTr("Send reply")
        onClicked: root._send()
    }

    Components.IconButton {
        QQL.Layout.preferredWidth: Sizing.pillHeight
        QQL.Layout.preferredHeight: Sizing.pillHeight
        visible: root.editing
        iconName: "close"
        text: qsTr("Cancel reply")
        onClicked: root.editing = false
    }
}
