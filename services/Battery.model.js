.pragma library

function percent(fraction) {
    if (!Number.isFinite(fraction))
        return 0;
    return Math.round(Math.max(0, Math.min(1, fraction)) * 100);
}

function isLow(present, percent) {
    return present && percent <= 15;
}
