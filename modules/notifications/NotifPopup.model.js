.pragma library

function timeoutFor(expireTimeout, critical, defaultTimeout) {
    // Quickshell 0.3.2 exposes the D-Bus timeout in milliseconds.
    if (critical)
        return 0;
    return expireTimeout >= 0 ? expireTimeout : defaultTimeout;
}

function remainingAfterPause(remaining, startedAt, now) {
    return Math.max(1, remaining - Math.max(0, now - startedAt));
}

function enqueue(pending, incoming) {
    const others = pending.filter(item => item.entry !== incoming.entry);
    const critical = others.filter(item => item.critical);
    if (incoming.critical)
        return [...critical, incoming, ...others.filter(item => !item.critical)];
    return [...critical, incoming];
}

function overflowCandidate(popups, critical) {
    if (popups.some(popup => popup.leaving))
        return null;
    return popups.find(popup => !popup.critical) ?? (critical ? popups[0] ?? null : null);
}
