import qs.config
import qs.modules.bar
import qs.modules.controlcenter
import qs.services

import Quickshell
import QtQml

ShellRoot {
    Bar { id: bar }

    ControlCenter {
        barWindows: bar.instances
    }

    Component.onCompleted: {
        Network;
        Bluetooth;
        Battery;
        Notifs;
        Shape;
        Motion;
    }
}
