pragma ComponentBehavior: Bound

import qs.components as Components
import qs.services

import Quickshell
import Quickshell.Io
import QtQml
import QtQuick as QQ

Scope {
    id: root

    required property list<QtObject> barWindows
    property var _request: null
    readonly property ShellScreen confirmScreen: _request?.screen ?? null

    onConfirmScreenChanged: {
        if (!confirmScreen && _request !== null)
            _request = null;
    }

    readonly property Component actions: QQ.Column {
        ActionRow {
            id: lockAction

            text: qsTr("Lock")
            iconName: "lock"
            focus: true
            QQ.KeyNavigation.up: shutDown
            QQ.KeyNavigation.down: signOut
            onClicked: UiState.lockRequested()
        }

        ActionRow {
            id: signOut

            text: qsTr("Sign out")
            iconName: "logout"
            QQ.KeyNavigation.up: lockAction
            QQ.KeyNavigation.down: restart
            onClicked: root._select("logout")
        }

        ActionRow {
            id: restart

            text: qsTr("Restart")
            iconName: "restart_alt"
            QQ.KeyNavigation.up: signOut
            QQ.KeyNavigation.down: shutDown
            onClicked: root._select("restart")
        }

        ActionRow {
            id: shutDown

            text: qsTr("Power off")
            iconName: "power_settings_new"
            QQ.KeyNavigation.up: restart
            QQ.KeyNavigation.down: lockAction
            onClicked: root._select("poweroff")
        }
    }

    function _select(action: string): void {
        const screen = UiState.popupAnchor?.QsWindow.window?.screen ?? Compositor.focusedScreen;
        UiState.close();
        if (Power.requiresConfirmation(action))
            _request = screen ? { action: action, screen: screen } : null;
        else
            Power.run(action);
    }

    function _confirm(): void {
        const action = _request?.action;
        _request = null;
        if (action)
            Power.run(action);
    }

    QQ.Connections {
        target: UiState

        function onOpenPopupChanged(): void {
            if (UiState.openPopup !== "")
                root._request = null;
        }

        function onLockActiveChanged(): void {
            if (UiState.lockActive)
                root._request = null;
        }
    }

    IpcHandler {
        target: "powermenu"

        function toggle(): void {
            if (UiState.lockActive)
                return;
            if (root._request) {
                root._request = null;
            } else if (UiState.powerMenuOpen) {
                UiState.powerMenuOpen = false;
            } else {
                const bar = root.barWindows.find(window => window?.screen === Compositor.focusedScreen)
                    ?? root.barWindows[0];
                if (bar) {
                    UiState.openAt("controlcenter", bar.statusAnchor);
                    UiState.powerMenuOpen = true;
                }
            }
        }
    }

    LazyLoader {
        active: root.confirmScreen !== null

        Components.Dialog {
            readonly property bool restarting: root._request?.action === "restart"

            targetScreen: root.confirmScreen
            title: restarting ? qsTr("Restart?") : qsTr("Power off?")
            message: qsTr("Save your work before continuing.")
            confirmText: restarting ? qsTr("Restart") : qsTr("Power off")
            onAccepted: Qt.callLater(root._confirm)
            onRejected: root._request = null
        }
    }

    component ActionRow: Components.Button {
        width: parent.width
        variant: "text"
        alignLeading: true
    }
}
