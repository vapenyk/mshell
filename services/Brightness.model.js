.pragma library

function parseInfo(text) {
    for (var line of text.trim().split(/\r?\n/)) {
        var fields = line.split(",");
        if (fields.length !== 5 || !/^[\w.:-]+$/.test(fields[0]) || fields[1] !== "backlight" ||
            !/^\d+$/.test(fields[2]) || !/^\d+%$/.test(fields[3]) || !/^\d+$/.test(fields[4]))
            continue;

        var current = Number(fields[2]);
        var max = Number(fields[4]);
        if (Number.isSafeInteger(max) && max > 0 && current <= max)
            return { device: fields[0], current: current, max: max };
    }
    return null;
}

function rawValue(value, max) {
    if (!Number.isFinite(value) || !Number.isSafeInteger(max) || max <= 0)
        return -1;
    return Math.max(Math.ceil(max * 0.05), Math.round(Math.min(1, value) * max));
}
