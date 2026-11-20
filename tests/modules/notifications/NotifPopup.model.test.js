const assert = require("node:assert/strict");
const test = require("node:test");
const { loadModel } = require("../../load.js");

const { timeoutFor, remainingAfterPause, enqueue, overflowCandidate } = loadModel("modules/notifications/NotifPopup.model.js");

test("respects explicit timeout, never-expire, and critical urgency", () => {
    assert.equal(timeoutFor(-1, false, 5000), 5000);
    assert.equal(timeoutFor(1400, false, 5000), 1400);
    assert.equal(timeoutFor(0, false, 5000), 0);
    assert.equal(timeoutFor(1400, true, 5000), 0);
});

test("pausing deducts elapsed time and resumes a near-expired timer", () => {
    assert.equal(remainingAfterPause(1400, 1000, 1600), 800);
    assert.equal(remainingAfterPause(800, 1600, 2500), 1);
    assert.equal(remainingAfterPause(800, 1600, 1500), 800);
});

test("queue gives critical arrivals priority and coalesces ordinary arrivals and replacements", () => {
    const first = { entry: 1, critical: true };
    const second = { entry: 2, critical: true };
    const ordinary = { entry: 3, critical: false };
    const newer = { entry: 4, critical: false };
    assert.deepEqual(Array.from(enqueue([first, ordinary], second)), [first, second, ordinary]);
    assert.deepEqual(Array.from(enqueue([first, second, ordinary], newer)), [first, second, newer]);
    assert.deepEqual(Array.from(enqueue([first, second, ordinary], { ...second, critical: false }))
        .map(item => [item.entry, item.critical]), [[1, true], [2, false]]);
});

test("critical overflow can make room in a full critical stack", () => {
    const critical = { critical: true };
    const exiting = { leaving: true };
    const older = { critical: false };
    const newer = { critical: false };

    assert.equal(overflowCandidate([critical, older, newer], true), older);
    assert.equal(overflowCandidate([critical], false), null);
    assert.equal(overflowCandidate([critical], true), critical);
    assert.equal(overflowCandidate([critical, exiting], true), null);
    assert.equal(overflowCandidate([], true), null);
});
