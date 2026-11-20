pragma ComponentBehavior: Bound

import qs.config

import Quickshell
import Quickshell.Hyprland
import Quickshell.Wayland
import QtQuick

PanelWindow {
    id: root

    required property ShellScreen screenModel
    required property var toasts
    readonly property Item _replyingToast: column.children.find(item => item.replying === true) ?? null
    signal toastExited(toast: QtObject)

    screen: screenModel
    visible: cards.count > 0
    anchors { top: true; right: true }
    margins.top: Sizing.barHeight + Sizing.popupGap
    margins.right: Sizing.barSideMargin
    implicitWidth: Math.max(1, Math.min(Sizing.notificationPopupWidth,
        (screenModel?.width ?? 0) - 2 * Sizing.barSideMargin))
    implicitHeight: Math.min(column.implicitHeight,
        Math.max(1, (screenModel?.height ?? 0) - margins.top - Sizing.barSideMargin))
    exclusionMode: ExclusionMode.Ignore
    color: Theme.transparent
    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.keyboardFocus: _replyingToast ? WlrKeyboardFocus.OnDemand : WlrKeyboardFocus.None
    WlrLayershell.namespace: "mshell-notifications"

    mask: Region {
        id: inputMask
    }

    HyprlandFocusGrab {
        // Request focus on Reply and release it when the user clicks outside.
        active: root._replyingToast !== null
        windows: [root]
        onCleared: root._replyingToast?.stopReply()
    }

    Flickable {
        anchors.fill: parent
        contentWidth: width
        contentHeight: column.implicitHeight
        interactive: contentHeight > height
        clip: true
        onContentYChanged: inputMask.changed()

        Column {
            id: column

            width: parent.width
            spacing: Sizing.popupGap

            Repeater {
                id: cards
                onItemAdded: (_, item) => inputMask.regions.push(item.inputRegion)

                model: ScriptModel {
                    values: root.toasts
                }

                delegate: NotifToast {
                    required property QtObject modelData

                    toast: modelData
                    width: column.width
                    onExited: {
                        const finishedToast = modelData;
                        // Use a separate callback for each card that finishes on the same frame.
                        Qt.callLater(() => root.toastExited(finishedToast));
                    }
                }
            }
        }
    }
}
