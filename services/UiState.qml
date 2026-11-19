pragma Singleton

import Quickshell
import QtQuick

Singleton {
    id: root

    readonly property string openPopup: _popup.name
    readonly property Item popupAnchor: _popup.anchor
    property bool editMode: false

    property var _popup: ({ name: "", anchor: null, anchored: false })

    onPopupAnchorChanged: {
        if (!popupAnchor && _popup.anchored)
            close();
    }

    function openAt(name: string, anchor: Item): void {
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
