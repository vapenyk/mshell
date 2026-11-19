pragma Singleton

import Quickshell

Singleton {
    id: root

    readonly property bool dndOn: _dndOn
    property bool _dndOn: false

    function toggleDnd(): void {
        root._dndOn = !root._dndOn;
    }
}
