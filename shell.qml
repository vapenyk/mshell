import qs.config
import qs.modules.bar
import qs.modules.calendar
import qs.modules.controlcenter
import qs.modules.keyboard
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

    NotifCenter { barWindows: bar.instances }
    CalendarPopup { barWindows: bar.instances }
    KeyboardPopup { barWindows: bar.instances }

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
