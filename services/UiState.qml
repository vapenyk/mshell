pragma Singleton

import Quickshell

Singleton {
    id: root

    readonly property string openPopup: _openPopup
    property bool editMode: false

    property string _openPopup: ""

    function open(name: string): void {
        _openPopup = name;
    }

    function close(): void {
        open("");
    }

    function toggle(name: string): void {
        if (openPopup === name)
            close();
        else
            open(name);
    }
}
