.pragma library

function visibleTiles(order, defs, includeUnavailable = false) {
    const seen = new Set();
    const ids = Array.from(order ?? []).concat(Object.keys(defs));

    return ids.filter(id => {
        if (typeof id !== "string" || seen.has(id) || !Object.prototype.hasOwnProperty.call(defs, id) || (!includeUnavailable && !defs[id].available))
            return false;
        seen.add(id);
        return true;
    });
}

function columnsFor(width) {
    return width < 320 ? 2 : 4;
}

function spanWidth(span, cols, cell, gap) {
    const columns = Math.min(span, cols);
    return columns * cell + (columns - 1) * gap;
}

function move(list, from, to) {
    const result = list.slice();
    if (Number.isInteger(from) && Number.isInteger(to)
        && from >= 0 && from < result.length && to >= 0 && to < result.length) {
        const [item] = result.splice(from, 1);
        result.splice(to, 0, item);
    }
    return result;
}

function reorderVisible(order, defs, from, to) {
    const reordered = move(visibleTiles(order, defs), from, to);
    let index = 0;
    return visibleTiles(order, defs, true).map(id => defs[id].available ? reordered[index++] : id);
}
