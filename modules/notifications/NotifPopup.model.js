.pragma library

function timeoutFor(expireTimeout, critical, defaultTimeout) {
    if (critical)
        return 0;
    return expireTimeout >= 0 ? expireTimeout : defaultTimeout;
}

function overflowCandidate(popups) {
    return popups.find(popup => !popup.leaving && !popup.critical) ?? null;
}
