import qs.config

import Quickshell
import QtQml

ShellRoot {
    // Initialize the singleton so its IPC handler is available at startup.
    Component.onCompleted: Config
}
