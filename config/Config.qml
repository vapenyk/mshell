pragma Singleton

import Quickshell
import Quickshell.Io

Singleton {
    id: root

    readonly property string accent: settings.accent
    readonly property var tiles: settings.tiles
    readonly property string _defaultAccent: "blue"

    function setTiles(order: var): void {
        settings.tiles = order;
        settingsFile.writeAdapter();
    }

    FileView {
        id: settingsFile

        path: (Quickshell.env("XDG_CONFIG_HOME") || Quickshell.env("HOME") + "/.config") + "/mshell/settings.json"
        printErrors: false
        watchChanges: true
        blockWrites: true

        onFileChanged: reload()
        onLoadFailed: function(error: int): void {
            if (error === FileViewError.FileNotFound) {
                settings.accent = root._defaultAccent;
                settings.tiles = [];
                writeAdapter();
            } else {
                console.warn("Could not load settings:", FileViewError.toString(error));
            }
        }
        onSaveFailed: function(error: int): void {
            console.warn("Could not save settings:", FileViewError.toString(error));
        }

        JsonAdapter {
            id: settings

            property string accent: root._defaultAccent
            property var tiles: []
        }
    }

    IpcHandler {
        target: "config"

        function setAccent(name: string): void {
            settings.accent = name;
            settingsFile.writeAdapter();
        }
    }
}
