.pragma library

const HISTORY_LIMIT = 100;

function historyAfterClose(history, entry) {
    if (entry.notification.transient)
        return history;
    return [{
        appName: entry.appName,
        summary: entry.notification.summary,
        body: entry.notification.body,
        arrivedAt: entry.arrivedAt,
        replyDraft: entry.replyDraft,
    }, ...history.slice(0, HISTORY_LIMIT - 1)];
}
