.pragma library

function pickScheme(accents, name) {
    return Object.prototype.hasOwnProperty.call(accents, name) ? accents[name] : accents.blue;
}

function sizeClass(width) {
    if (width < 600)
        return "compact";
    if (width < 840)
        return "medium";
    if (width < 1200)
        return "expanded";
    if (width < 1600)
        return "large";
    return "extraLarge";
}
