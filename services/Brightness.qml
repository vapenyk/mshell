pragma Singleton

import "Brightness.model.js" as Model

import Quickshell
import Quickshell.Io

import QtQml

Singleton {
    id: root

    readonly property bool available: _backlight !== null
    readonly property real value: available ? _desired / _backlight.max : 0
    readonly property int refreshInterval: 1000

    readonly property list<string> _command: ["brightnessctl", "-m", "-c", "backlight"]
    property var _backlight: null
    property int _pending: -1
    property int _writing: -1
    readonly property int _desired: _pending >= 0 ? _pending
                                  : _writing >= 0 ? _writing
                                  : (_backlight?.current ?? -1)

    function refresh(): void {
        if (!worker.running && _pending < 0)
            worker.exec([..._command, "info"]);
    }

    function set(value: real): void {
        const target = Model.rawValue(value, _backlight?.max ?? 0);
        if (target >= 0 && target !== _desired) {
            _pending = target;
            _writePending();
        }
    }

    function _writePending(): void {
        if (worker.running || _pending < 0)
            return;
        const target = _pending;
        if (available && target !== _backlight.current) {
            _writing = target;
            worker.exec([..._command, "-d", _backlight.device, "set", String(target)]);
        }
        _pending = -1;
    }

    Process {
        id: worker

        stdout: StdioCollector { id: output }
        onExited: code => {
            const state = code === 0 ? Model.parseInfo(output.text) : null;
            if (state || root._writing < 0)
                root._backlight = state;
            root._writing = -1;
            Qt.callLater(root._writePending);
        }
    }
}
