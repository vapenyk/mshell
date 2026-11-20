pragma Singleton

import "Brightness.model.js" as Model

import Quickshell
import Quickshell.Io

import QtQml

Singleton {
    id: root

    readonly property var display: _devices.display
    readonly property var keyboard: _devices.keyboard
    readonly property bool available: display !== null
    readonly property real value: available ? (_displayTarget ?? display.current) / display.max : 0

    property var _devices: ({ display: null, keyboard: null })
    property var _queue: []
    property var _writing: null
    property bool _refreshPending: false
    readonly property var _displayTarget: Model.displayTarget(_queue, _writing, display?.device)

    function set(value: real): void {
        _enqueue(Model.absoluteWrite(display, value, _displayTarget));
    }

    function step(kind: string, direction: int): bool {
        return _enqueue(Model.relativeWrite(kind, _devices[kind], direction));
    }

    function refresh(): void {
        _refreshPending = true;
        _runPending();
    }

    function _enqueue(write: var): bool {
        if (!write)
            return false;

        _queue = Model.enqueue(_queue, write);
        _runPending();
        return true;
    }

    function _runPending(): void {
        if (worker.running || _writing)
            return;

        if (!_queue.length) {
            if (_refreshPending) {
                _refreshPending = false;
                worker.exec(["brightnessctl", "-m", "-l"]);
            }
            return;
        }

        const write = _queue[0];
        const device = _devices[write.kind];
        if (device?.device === write.device) {
            _writing = write;
            worker.exec(Model.writeCommand(write, device));
        } else {
            Qt.callLater(_runPending);
        }
        _queue = _queue.slice(1);
    }

    Timer {
        interval: 200
        repeat: true
        running: true
        triggeredOnStart: true
        onTriggered: root.refresh()
    }

    Process {
        id: worker

        stdout: StdioCollector { id: output }
        onExited: code => {
            const write = root._writing;
            if (!write) {
                root._devices = Model.parseDevices(code === 0 ? output.text : "");
            } else if (code === 0) {
                const devices = Model.parseDevices(output.text);
                root._devices = {
                    display: devices.display ?? root.display,
                    keyboard: devices.keyboard ?? root.keyboard,
                };
            }
            root._writing = null;
            Qt.callLater(root._runPending);
        }
    }
}
