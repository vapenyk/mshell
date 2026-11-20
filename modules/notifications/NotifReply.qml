pragma ComponentBehavior: Bound

import qs.components as Components
import qs.config

import QtQuick as QQ
import QtQuick.Layouts as QQL

QQ.FocusScope {
    id: root

    required property string placeholder
    required property string draft
    required property bool canSubmit
    property bool editing: false
    readonly property bool _windowActive: root.QQ.Window.window?.active ?? false
    signal submitted(text: string)
    signal cancelled()
    signal draftEdited(text: string)

    implicitHeight: editor.implicitHeight

    onVisibleChanged: {
        if (!visible && editing)
            editing = false;
    }

    onActiveFocusChanged: {
        if (!activeFocus && editing)
            editing = false;
    }

    on_WindowActiveChanged: {
        if (!_windowActive && editing)
            editing = false;
    }

    QQ.Keys.onEscapePressed: {
        root.editing = false;
        root.draftEdited("");
        root.cancelled();
    }

    function startEditing(): void {
        field.text = draft;
        editing = true;
        field.forceActiveFocus(Qt.OtherFocusReason);
    }

    function _send(): void {
        if (!canSubmit || field.text.trim().length === 0)
            return;
        const text = field.text;
        editing = false;
        draftEdited("");
        submitted(text);
    }

    QQL.RowLayout {
        id: editor

        anchors.fill: parent
        spacing: Sizing.pillGap

        Components.TextField {
            id: field

            QQL.Layout.fillWidth: true
            implicitHeight: Sizing.notificationReplyHeight
            placeholderText: root.placeholder
            QQ.Accessible.name: qsTr("Reply")
            onTextEdited: root.draftEdited(text)
            onAccepted: root._send()
        }

        Components.IconButton {
            QQL.Layout.preferredWidth: Sizing.notificationReplyHeight
            QQL.Layout.preferredHeight: Sizing.notificationReplyHeight
            standardColor: Theme.primary
            enabled: root.canSubmit && field.text.trim().length > 0
            iconName: "send"
            text: qsTr("Send reply")
            onClicked: root._send()
        }
    }
}
