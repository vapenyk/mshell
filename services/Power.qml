pragma Singleton

import "Power.model.js" as Model

import Quickshell
import Quickshell.Io

Singleton {
    id: root

    property bool _gracefulLogout: false

    function requiresConfirmation(action: string): bool {
        return Model.requiresConfirmation(action);
    }

    function run(action: string): void {
        const command = Model.commandFor(action, _gracefulLogout);
        if (command.length > 0)
            Quickshell.execDetached(command);
    }

    Process {
        command: ["sh", "-c", "command -v hyprshutdown >/dev/null"]
        running: true
        onExited: code => root._gracefulLogout = code === 0
    }
}
