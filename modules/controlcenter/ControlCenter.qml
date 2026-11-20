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

    onRequestedAnchorChanged: {
        UiState.editMode = false;
    }

    PowerMenu {
        id: powerMenu

        anchorItem: root.requestedAnchor
    }

    Components.AnchoredPopup {
        requestedAnchor: root.requestedAnchor
        preferredWidth: Sizing.controlCenterWidth
        barWindows: root.barWindows
        onDismissRequested: UiState.close()

        content: Components.PageStack {
            id: pages

            width: parent.width
            initialPage: MainPage {
                powerButton: powerMenu.button
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
