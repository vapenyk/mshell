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
    readonly property real value: available ? _desired / display.max : 0

    property var _devices: ({ display: null, keyboard: null })
    property int _pending: -1
    property int _writing: -1
    readonly property int _desired: _pending >= 0 ? _pending
                                  : _writing >= 0 ? _writing
                                  : (display?.current ?? -1)

    function set(value: real): void {
        const target = Model.rawValue(value, display?.max ?? 0);
        if (target >= 0 && target !== _desired) {
            _pending = target;
            _writePending();
        }
    }

    function _writePending(): void {
        if (worker.running || _pending < 0)
            return;
        const target = _pending;
        if (available && target !== display.current) {
            _writing = target;
            worker.exec(["brightnessctl", "-m", "-c", "backlight", "-d", display.device, "set", String(target)]);
        }
        _pending = -1;
    }

    Timer {
        // Coalesce both device reads into one query while the OSD listens for external changes.
        interval: 200
        repeat: true
        running: true
        triggeredOnStart: true
        onTriggered: {
            if (!worker.running && root._pending < 0)
                worker.exec(["brightnessctl", "-m", "-l"]);
        }
    }

    Process {
        id: worker

        stdout: StdioCollector { id: output }
        onExited: code => {
            if (root._writing < 0) {
                root._devices = Model.parseDevices(code === 0 ? output.text : "");
            } else if (code === 0) {
                const display = Model.parseInfo(output.text);
                if (display) {
                    display.writtenByShell = true;
                    root._devices = { display, keyboard: root.keyboard };
                }
            }
            root._writing = -1;
            Qt.callLater(root._writePending);
        }
    }
}
