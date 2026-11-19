import qs.config
import qs.modules.bar
import qs.services

import Quickshell
import QtQml

ShellRoot {
    Bar {}

    Component.onCompleted: {
        Network;
        Bluetooth;
        Battery;
        Shape;
        Motion;
    }
}
