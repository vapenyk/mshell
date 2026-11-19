pragma Singleton

import "NightLight.model.js" as Model

import Quickshell
import Quickshell.Io

import QtQml

Singleton {
    id: root

    readonly property bool active: _status === "on"
    readonly property bool available: _status === "on" || _status === "off" ||
                                      (_status === "stopped" && !daemon.running)

    readonly property list<string> _command: ["hyprctl", "hyprsunset"]
    readonly property string _temperature: "4500"
    property string _status: "unavailable"
    property bool _querying: false
    property bool _togglePending: false

    function refresh(): void {
        if (!ipc.running) {
            _querying = true;
            ipc.exec([..._command, "identity", "get"]);
        }
    }

    function toggle(): void {
        if (!available)
            return;
        if (ipc.running) {
            _togglePending = !_togglePending;
        } else if (_status === "stopped") {
            daemon.running = true;
        } else {
            _querying = false;
            ipc.exec(active ? [..._command, "identity"] : [..._command, "temperature", _temperature]);
        }
    }

    Process {
        id: ipc

        stdout: StdioCollector { id: output }
        onExited: code => {
            if (root._querying) {
                root._status = Model.statusFromReply(code, output.text);
                if (root._togglePending) {
                    root._togglePending = false;
                    Qt.callLater(root.toggle);
                }
            } else {
                Qt.callLater(root.refresh);
            }
        }
    }

    Process {
        id: daemon

        command: ["hyprsunset", "--temperature", root._temperature]
    }
}
