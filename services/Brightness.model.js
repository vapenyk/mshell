.pragma library

function parseInfo(text, deviceClass = "backlight", deviceName) {
    for (var line of text.trim().split(/\r?\n/)) {
        var fields = line.split(",");
        if (fields.length !== 5 || !/^[\w.:-]+$/.test(fields[0]) || fields[1] !== deviceClass ||
            (deviceName && !deviceName.test(fields[0])) ||
            !/^\d+$/.test(fields[2]) || !/^\d+%$/.test(fields[3]) || !/^\d+$/.test(fields[4]))
            continue;

        var current = Number(fields[2]);
        var max = Number(fields[4]);
        if (Number.isSafeInteger(max) && max > 0 && current <= max)
            return { device: fields[0], current: current, max: max };
    }
    return null;
}

function parseDevices(text) {
    return {
        display: parseInfo(text),
        keyboard: parseInfo(text, "leds", /(?:^|:)kbd_backlight$/),
    };
}

function rawValue(value, max) {
    if (!Number.isFinite(value) || !Number.isSafeInteger(max) || max <= 0)
        return -1;
    return Math.max(Math.ceil(max / 100), Math.round(Math.min(1, value) * max));
}

function absoluteWrite(display, value, target) {
    const next = rawValue(value, display?.max ?? 0);
    if (next < 0 || next === (target === undefined ? display.current : target))
        return null;
    return { kind: "display", device: display.device, value: String(next), target: next };
}

function relativeWrite(kind, device, direction) {
    if (!device || (direction !== -1 && direction !== 1))
        return null;
    const step = kind === "display" ? "5%" : "1";
    return { kind, device: device.device, value: step + (direction > 0 ? "+" : "-"), target: null };
}

function writeCommand(write, device) {
    const display = write.kind === "display";
    const minimum = display ? ["--min-value=" + rawValue(0, device.max)] : [];
    return ["brightnessctl", "-m", "-c", display ? "backlight" : "leds", "-d", write.device,
        ...minimum, "set", write.value];
}

function enqueue(queue, write) {
    const last = queue[queue.length - 1];
    if (write.target !== null && last?.target != null && last.device === write.device)
        return [...queue.slice(0, -1), write];
    return [...queue, write];
}

function displayTarget(queue, active, device) {
    for (var index = queue.length - 1; index >= 0; --index) {
        if (queue[index].kind === "display" && queue[index].device === device)
            return queue[index].target;
    }
    return active?.kind === "display" && active.device === device ? active.target : undefined;
}
