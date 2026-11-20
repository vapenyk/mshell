pragma Singleton

import Quickshell
import QtQuick

Singleton {
    id: root

    readonly property string openPopup: _popup.name
    readonly property Item popupAnchor: _popup.anchor
    property bool editMode: false
    property bool lockActive: false
    signal lockRequested()

    property var _popup: ({ name: "", anchor: null, anchored: false })

    onPopupAnchorChanged: {
        if (!popupAnchor && _popup.anchored)
            close();
    }

    onLockActiveChanged: {
        if (lockActive)
            close();
    }

    function openAt(name: string, anchor: Item): void {
        if (lockActive && name !== "")
            return;
        _popup = { name: name, anchor: anchor, anchored: anchor !== null };
    }

    function open(name: string): void {
        openAt(name, null);
    }

    function close(): void {
        open("");
    }

    function toggleAt(name: string, anchor: Item): void {
        if (openPopup === name && (!anchor || anchor === popupAnchor))
            close();
        else
            openAt(name, anchor);
    }

    function toggle(name: string): void {
        toggleAt(name, null);
    }
}
