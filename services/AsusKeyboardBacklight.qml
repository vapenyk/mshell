pragma Singleton

import Quickshell
import Quickshell.Io

Singleton {
    id: root

    signal hardwareChanged()

    FileView {
        path: Brightness.keyboard?.device === "asus::kbd_backlight"
            ? "/sys/class/leds/asus::kbd_backlight/brightness_hw_changed" : ""
        preload: false
        printErrors: false
        watchChanges: true
        onFileChanged: {
            Brightness.refresh();
            root.hardwareChanged();
        }
    }
}
