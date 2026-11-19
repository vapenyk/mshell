.pragma library

function requiresConfirmation(action) {
    return action === "restart" || action === "poweroff";
}

function commandFor(action, gracefulLogout) {
    switch (action) {
    case "logout":
        return gracefulLogout ? ["hyprshutdown"] : ["hyprctl", "dispatch", "hl.dsp.exit()"];
    case "restart":
        return ["systemctl", "reboot"];
    case "poweroff":
        return ["systemctl", "poweroff"];
    default:
        return [];
    }
}
