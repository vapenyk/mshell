const assert = require("node:assert/strict");
const test = require("node:test");
const { loadModel } = require("../load.js");

const { historyAfterClose } = loadModel("services/Notifs.model.js");

test("history keeps the newest 100 entries and any unsent reply", () => {
    const history = Array.from({ length: 100 }, (_, index) => ({ index }));
    const entry = {
        appName: "Chat", arrivedAt: 123, replyDraft: "See you soon",
        notification: { summary: "Hello", body: "Meet at 5?" },
    };
    const result = historyAfterClose(history, entry);

    assert.equal(result.length, 100);
    assert.deepEqual({ ...result[0] }, {
        appName: "Chat", summary: "Hello", body: "Meet at 5?", arrivedAt: 123, replyDraft: "See you soon",
    });
    assert.equal(result[99], history[98]);
    assert.equal(history.length, 100);
});

test("transient notifications leave no history", () => {
    const history = [];
    assert.equal(historyAfterClose(history, { notification: { transient: true } }), history);
});
