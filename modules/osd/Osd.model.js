.pragma library

function levelChange(previous, current, writtenByShell) {
    if (previous == null || current == null || previous.device !== current.device || previous.max !== current.max)
        return "";
    if (previous.muted !== current.muted)
        return "external";

    // PipeWire rounds volume when it converts to and from its float channel scale.
    const tolerance = current.muted === undefined ? 0 : 0.000001;
    if (Math.abs(previous.current - current.current) <= tolerance)
        return "";
    return writtenByShell ? "local" : "external";
}

function presentation(kind, reading) {
    const { current, max, muted } = reading;
    if (kind === "keyboard") {
        return { value: current, maximum: max, discrete: true,
            icon: current === 0 ? "keyboard_off" : "keyboard" };
    }
    if (kind === "display")
        return { value: current / max, maximum: 1, discrete: false, icon: "brightness_6" };

    const value = muted ? 0 : current;
    return { value, maximum: 1, discrete: false,
        icon: value <= 0 ? "volume_off" : value < 0.5 ? "volume_down" : "volume_up" };
}
