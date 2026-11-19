pragma ComponentBehavior: Bound

import qs.components as Components
import qs.config

import QtQuick as QQ
import QtQuick.Layouts as QQL

QQL.RowLayout {
    id: root

    required property string placeholder
    property bool editing: false
    signal submitted(text: string)
    signal cancelled()

    spacing: Sizing.pillGap

    onVisibleChanged: {
        if (!visible && editing)
            _finish();
    }

    QQ.Keys.onEscapePressed: {
        root._finish();
        root.cancelled();
    }

    function startEditing(): void {
        editing = true;
        field.forceActiveFocus(Qt.OtherFocusReason);
    }

    function _finish(): void {
        editing = false;
        field.clear();
    }

    function _send(): void {
        if (field.text.trim().length === 0)
            return;
        const text = field.text;
        _finish();
        submitted(text);
    }

    Components.TextField {
        id: field

        QQL.Layout.fillWidth: true
        implicitHeight: Sizing.notificationReplyHeight
        placeholderText: root.placeholder
        QQ.Accessible.name: qsTr("Reply")
        onAccepted: root._send()
    }

    Components.IconButton {
        QQL.Layout.preferredWidth: Sizing.notificationReplyHeight
        QQL.Layout.preferredHeight: Sizing.notificationReplyHeight
        standardColor: Theme.primary
        enabled: field.text.trim().length > 0
        iconName: "send"
        text: qsTr("Send reply")
        onClicked: root._send()
    }
}
