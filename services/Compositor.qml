pragma Singleton

import Quickshell
import Quickshell.Hyprland

Singleton {
    readonly property ShellScreen focusedScreen: Quickshell.screens.find(
        screen => screen.name === Hyprland.focusedMonitor?.name) ?? Quickshell.screens[0] ?? null
}
