.pragma library

function presentation(kind, reading) {
    if (!reading)
        return null;

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
