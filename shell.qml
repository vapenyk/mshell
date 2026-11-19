import qs.config
import qs.modules.bar
import qs.modules.controlcenter
import qs.modules.notifications
import qs.services

import Quickshell
import QtQml

ShellRoot {
    Bar { id: bar }

    ControlCenter {
        barWindows: bar.instances
    }

    NotifPopup {}

    Component.onCompleted: {
        Network;
        Bluetooth;
        Battery;
        Notifs;
        Compositor.focusedScreen;
        Shape;
        Motion;
    }
}
