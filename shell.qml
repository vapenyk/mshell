import qs.config
import qs.modules.bar
import qs.modules.calendar
import qs.modules.controlcenter
import qs.modules.keyboard
import qs.modules.lock
import qs.modules.notifications
import qs.modules.osd
import qs.modules.powermenu
import qs.services

import Quickshell
import QtQml

ShellRoot {
    Bar { id: bar }

    ControlCenter {
        barWindows: bar.instances
        powerActions: powerMenu.actions
    }

    PowerMenu {
        id: powerMenu

        barWindows: bar.instances
    }

    NotifPopup {}
    Osd {}

    NotifCenter { barWindows: bar.instances }
    CalendarPopup { barWindows: bar.instances }
    KeyboardPopup { barWindows: bar.instances }
    Lock { barContent: bar.lockContent }

    Component.onCompleted: {
        Network;
        Bluetooth;
        Battery;
        Notifs;
        Power;
        Compositor.focusedScreen;
        Shape;
        Motion;
    }
}
