.pragma library

function statusFromReply(code, text) {
    // hyprctl uses status 3 when it cannot connect to the hyprsunset socket.
    if (code === 3)
        return "stopped";
    if (code === 0) {
        var identity = text.trim();
        if (identity === "true")
            return "off";
        if (identity === "false")
            return "on";
    }
    return "unavailable";
}
