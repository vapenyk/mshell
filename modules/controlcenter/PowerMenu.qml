pragma ComponentBehavior: Bound

import qs.components as Components
import qs.config
import qs.services

import Quickshell
import QtQml
import QtQuick as QQ
import QtQuick.Controls as QQC

Scope {
    id: root

    required property QQ.Item anchorItem
    property var _request: null
    readonly property ShellScreen confirmScreen: _request?.screen ?? null

    onConfirmScreenChanged: {
        if (!confirmScreen && _request !== null)
            _request = null;
    }

    readonly property Component button: Components.IconButton {
        id: powerButton

        readonly property QQ.Item controlCenterAnchor: root.anchorItem

        iconName: "power_settings_new"
        trailingIconName: selected ? "expand_less" : "expand_more"
        text: qsTr("Power")
        toggle: true
        selected: dropdown.visible
        tooltipEnabled: !selected
        onClicked: dropdown.visible ? dropdown.close() : dropdown.open()
        onControlCenterAnchorChanged: dropdown.close()

        QQC.Popup {
            id: dropdown

            parent: powerButton
            width: Sizing.powerMenuWidth
            padding: Sizing.pillGap
            margins: Sizing.pillGap
            x: powerButton.width - width
            y: powerButton.height + Sizing.pillGap
            popupType: QQC.Popup.Item
            focus: true
            modal: true
            dim: false
            closePolicy: QQC.Popup.CloseOnEscape | QQC.Popup.CloseOnPressOutside

            contentItem: QQ.Loader {
                active: dropdown.visible
                focus: true
                sourceComponent: root._actions
            }

            background: Components.Surface {
                container: Theme.surfaceContainer
                radius: Shape.extraLarge
                border.color: Theme.outlineVariant
                border.width: Sizing.outlineWidth
            }

            enter: QQ.Transition {
                QQ.NumberAnimation { property: "opacity"; from: 0; to: 1; duration: Motion.fadeThroughInDuration }
            }
            exit: QQ.Transition {
                QQ.NumberAnimation { property: "opacity"; to: 0; duration: Motion.fadeThroughOutDuration }
            }
        }
    }

    readonly property Component _actions: QQ.Column {
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
        const screen = anchorItem?.QsWindow.window?.screen ?? null;
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
