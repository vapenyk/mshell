.pragma library

function route(urgency, dndOn, low, critical) {
    const silent = dndOn || urgency === low;
    return { silent, popup: !silent || urgency === critical };
}

function groupByApp(list) {
    const newestFirst = Array.from(list).reverse().sort((a, b) => b.arrivedAt - a.arrivedAt);
    const groups = new Map();

    for (const entry of newestFirst) {
        const key = entry.desktopEntry || entry.appName || entry.notificationId;
        let group = groups.get(key);
        if (!group) {
            group = { key, appName: entry.appName, items: [], count: 0 };
            groups.set(key, group);
        }
        group.items.push(entry);
        group.count++;
    }

    return Array.from(groups.values());
}

function sections(list) {
    const entries = Array.from(list);
    const alerting = entries.filter(entry => !entry.silent);
    const silent = entries.filter(entry => entry.silent);
    return {
        alerting: { groups: groupByApp(alerting), count: alerting.length },
        silent: { groups: groupByApp(silent), count: silent.length },
    };
}
