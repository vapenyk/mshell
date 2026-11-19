.pragma library

function clamp(value, min, max) {
    return Math.max(min, Math.min(max, value));
}

function posFromValue(value, width, min, max) {
    if (width <= 0 || max <= min)
        return 0;
    return width * clamp((value - min) / (max - min), 0, 1);
}

function valueFromPos(x, width, min, max, step) {
    if (width <= 0 || max <= min || x <= 0)
        return min;
    if (x >= width)
        return max;

    var value = min + x / width * (max - min);
    if (!(step > 0))
        return value;

    var snapped = clamp(min + Math.round((value - min) / step) * step, min, max);
    return max - value <= Math.abs(snapped - value) ? max : snapped;
}

function stepValue(value, min, max, step, direction) {
    if (max <= min)
        return min;
    if (!(step > 0))
        return clamp(value + direction * (max - min) / 100, min, max);

    var bounded = clamp(value, min, max);
    var index = (bounded - min) / step;
    var nearest = Math.round(index);
    var tolerance = Number.EPSILON * Math.max(Math.abs(bounded), Math.abs(min), step);
    if (Math.abs(min + nearest * step - bounded) <= tolerance)
        index = nearest;

    var nextIndex = direction > 0 ? Math.floor(index) + 1 : Math.ceil(index) - 1;
    return clamp(min + nextIndex * step, min, max);
}
