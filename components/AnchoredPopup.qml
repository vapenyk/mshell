import qs.components as Components

import Quickshell
import QtQuick

Scope {
    id: root

    required property Item requestedAnchor
    required property int preferredWidth
    required property Component content
    required property list<QtObject> barWindows
    property Item _mountedAnchor: null

    signal dismissRequested()

    onRequestedAnchorChanged: Qt.callLater(_mount)
    Component.onCompleted: Qt.callLater(_mount)

    function _mount(): void {
        if (requestedAnchor && requestedAnchor !== _mountedAnchor) {
            windowLoader.active = false;
            _mountedAnchor = requestedAnchor;
            windowLoader.active = true;
        }
    }

    function _dismiss(window: QtObject): void {
        if (windowLoader.item === window && window.opened)
            dismissRequested();
    }

    function _unmount(): void {
        if (!requestedAnchor) {
            windowLoader.active = false;
            _mountedAnchor = null;
        }
    }

    LazyLoader {
        id: windowLoader

        active: false

        Components.PopupWindow {
            id: popup

            anchorItem: root._mountedAnchor
            opened: anchorItem !== null && root.requestedAnchor === anchorItem
            preferredWidth: root.preferredWidth
            barWindows: root.barWindows
            waitForContentLayout: true
            onDismissRequested: Qt.callLater(root._dismiss, popup)
            onExited: Qt.callLater(root._unmount)

            Loader {
                width: parent.width
                focus: true
                sourceComponent: root.content
            }
        }
    }
}
