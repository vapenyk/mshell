const assert = require("node:assert/strict");
const test = require("node:test");
const { loadModel } = require("../load.js");

const { groupByApp, sections, route } = loadModel("utils/Grouping.js");

test("groups by desktop ID or app name, newest groups and items first", () => {
    const mail1 = { appName: "Mail", desktopEntry: "org.example.Mail", arrivedAt: 1 };
    const chat1 = { appName: "Chat", arrivedAt: 2 };
    const mail2 = { appName: "Mail alias", desktopEntry: "org.example.Mail", arrivedAt: 3 };
    const chat2 = { appName: "Chat", arrivedAt: 4 };
    const groups = groupByApp([mail1, chat1, mail2, chat2]);

    assert.deepEqual(groups.map(group => group.key), ["Chat", "org.example.Mail"]);
    assert.deepEqual(Array.from(groups[0].items), [chat2, chat1]);
    assert.deepEqual(Array.from(groups[1].items), [mail2, mail1]);
    assert.equal(groups[1].count, 2);
});

test("later arrivals win ties when notifications share a timestamp", () => {
    const first = { appName: "First", arrivedAt: 1 };
    const second = { appName: "Second", arrivedAt: 1 };
    assert.deepEqual(groupByApp([first, second]).map(group => group.appName), ["Second", "First"]);
});

test("notifications without an app name or desktop ID stay separate", () => {
    const first = { notificationId: 1, appName: "", arrivedAt: 1 };
    const second = { notificationId: 2, appName: "", arrivedAt: 2 };
    const groups = groupByApp([first, second]);

    assert.deepEqual(groups.map(group => group.key), [2, 1]);
    assert.deepEqual(Array.from(groups[0].items), [second]);
});

test("sections count notifications independently even when the application is the same", () => {
    const alert = { appName: "Mail", arrivedAt: 1, silent: false };
    const quiet = { appName: "Mail", arrivedAt: 2, silent: true };
    const result = sections([alert, quiet]);

    assert.deepEqual(Array.from(result.alerting.groups[0].items), [alert]);
    assert.deepEqual(Array.from(result.silent.groups[0].items), [quiet]);
    assert.equal(result.alerting.count, 1);
    assert.equal(result.silent.count, 1);
    assert.deepEqual(groupByApp([]), []);
    assert.equal(sections([]).alerting.count, 0);
    assert.equal(sections([]).silent.count, 0);
});

test("DND suppresses ordinary popups while allowing critical ones", () => {
    const low = 0;
    const normal = 1;
    const critical = 2;

    assert.deepEqual({ ...route(low, false, low, critical) }, { silent: true, popup: false });
    assert.deepEqual({ ...route(normal, false, low, critical) }, { silent: false, popup: true });
    assert.deepEqual({ ...route(normal, true, low, critical) }, { silent: true, popup: false });
    assert.deepEqual({ ...route(critical, true, low, critical) }, { silent: true, popup: true });
    assert.deepEqual({ ...route(critical, false, low, critical) }, { silent: false, popup: true });
});
