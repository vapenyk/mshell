pragma ComponentBehavior: Bound

import qs.components as Components
import qs.config
import qs.services
import "pages"

import Quickshell
import Quickshell.Hyprland
import Quickshell.Io

import QtQuick

Scope {
    id: root

    required property list<QtObject> barWindows

    readonly property Item requestedAnchor: UiState.openPopup === "controlcenter" ? UiState.popupAnchor : null
    property Item _mountedAnchor: null

    onRequestedAnchorChanged: {
        UiState.editMode = false;
        Qt.callLater(_syncPopup);
    }

    function _syncPopup(): void {
        if (!requestedAnchor) {
            if (UiState.openPopup === "controlcenter")
                UiState.close();
            if (!_mountedAnchor)
                _unmountPopup();
            return;
        }

        if (requestedAnchor !== _mountedAnchor) {
            popupLoader.active = false;
            _mountedAnchor = requestedAnchor;
            popupLoader.active = true;
        }
    }

    function _unmountPopup(): void {
        if (!requestedAnchor) {
            popupLoader.active = false;
            _mountedAnchor = null;
        }
    }

    function _dismissPopup(window: QtObject): void {
        if (window && popupLoader.item === window && window.opened)
            UiState.close();
    }

    LazyLoader {
        id: popupLoader

        active: false

        Components.PopupWindow {
            id: popup

            anchorItem: root._mountedAnchor
            opened: anchorItem !== null && root.requestedAnchor === anchorItem
            preferredWidth: Sizing.controlCenterWidth
            contentViewportHeight: pages.viewportHeight
            barWindows: root.barWindows
            onDismissRequested: Qt.callLater(root._dismissPopup, popup)
            onExited: Qt.callLater(root._unmountPopup)

            Components.PageStack {
                id: pages

                width: parent.width
                initialPage: MainPage {
                    onMixerRequested: pages.push(audioPage)
                    onSettingsRequested: tileId => {
                        if (tileId === "modes")
                            pages.push(modesPage);
                        else if (tileId === "wifi")
                            pages.push(networkPage);
                        else if (tileId === "bluetooth")
                            pages.push(bluetoothPage);
                    }
                }

                onRootEscapePressed: event => {
                    if (UiState.editMode) {
                        UiState.editMode = false;
                        event.accepted = true;
                    }
                }
            }

            Component {
                id: modesPage

                ModesPage {}
            }

            Component {
                id: networkPage

                NetworkPage {}
            }

            Component {
                id: bluetoothPage

                BluetoothPage {}
            }

            Component {
                id: audioPage

                AudioPage {}
            }
        }
    }

    IpcHandler {
        target: "controlcenter"

        function toggle(): void {
            if (UiState.openPopup === "controlcenter") {
                UiState.close();
                return;
            }

            const focusedName = Hyprland.focusedMonitor?.name;
            const bar = root.barWindows.find(window => window?.screen?.name === focusedName) ?? root.barWindows[0];
            if (bar)
                UiState.openAt("controlcenter", bar.statusAnchor);
        }

        function close(): void {
            if (UiState.openPopup === "controlcenter")
                UiState.close();
        }
    }
}
