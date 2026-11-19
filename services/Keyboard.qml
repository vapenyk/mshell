pragma Singleton

import "Keyboard.model.js" as Model

import Quickshell
import Quickshell.Hyprland
import Quickshell.Io
import QtQml

Singleton {
    id: root

    readonly property var layouts: Model.configuredLayouts(_keyboard, _names)
    readonly property var current: layouts.find(layout => layout.index === _keyboard?.active_layout_index) ?? null
    readonly property string _xkbRoot: Quickshell.env("XKB_CONFIG_ROOT") || "/usr/share/X11/xkb"
    readonly property var _names: Model.layoutNames(registry.text())
    property var _keyboard: null
    property bool _refreshPending: false

    Component.onCompleted: refresh()

    function refresh(): void {
        if (devices.running)
            _refreshPending = true;
        else
            devices.running = true;
    }

    function switchTo(index: int): void {
        if (_keyboard && !switcher.running && current?.index !== index && layouts.some(layout => layout.index === index))
            switcher.exec(["hyprctl", "switchxkblayout", _keyboard.name, String(index)]);
    }

    Connections {
        target: Hyprland

        function onRawEvent(event: HyprlandEvent): void {
            if (event.name === "activelayout" || event.name === "configreloaded")
                Qt.callLater(root.refresh);
        }
    }

    FileView {
        id: registry

        path: root._xkbRoot + "/rules/" + (root._keyboard?.rules || "evdev") + ".lst"
        printErrors: false
    }

    Process {
        id: devices

        command: ["hyprctl", "-j", "devices"]
        stdout: StdioCollector { id: output }
        onExited: code => {
            if (code === 0)
                root._keyboard = Model.mainKeyboard(output.text);
            if (root._refreshPending) {
                root._refreshPending = false;
                Qt.callLater(root.refresh);
            }
        }
    }

    Process {
        id: switcher

        onExited: Qt.callLater(root.refresh)
    }
}
