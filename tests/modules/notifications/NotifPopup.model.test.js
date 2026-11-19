const assert = require("node:assert/strict");
const test = require("node:test");
const { loadModel } = require("../../load.js");

const { timeoutFor, overflowCandidate } = loadModel("modules/notifications/NotifPopup.model.js");

test("respects explicit timeout, never-expire, and critical urgency", () => {
    assert.equal(timeoutFor(-1, false, 5000), 5000);
    assert.equal(timeoutFor(1400, false, 5000), 1400);
    assert.equal(timeoutFor(0, false, 5000), 0);
    assert.equal(timeoutFor(1400, true, 5000), 0);
});

test("overflow prefers the oldest ordinary card and protects critical cards", () => {
    const critical = { critical: true };
    const exiting = { leaving: true };
    const older = { critical: false };
    const newer = { critical: false };

    assert.equal(overflowCandidate([critical, exiting, older, newer]), older);
    assert.equal(overflowCandidate([critical, exiting]), null);
    assert.equal(overflowCandidate([]), null);
});
