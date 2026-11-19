const assert = require("node:assert/strict");
const test = require("node:test");
const { loadModel } = require("../load.js");

const { clock, dateShort } = loadModel("utils/Format.js");

test("clock formats 24-hour time with padded hours and minutes", () => {
    assert.equal(clock(new Date(2026, 9, 12, 0, 0), true), "00:00");
    assert.equal(clock(new Date(2026, 9, 12, 7, 5), true), "07:05");
    assert.equal(clock(new Date(2026, 9, 12, 23, 59), true), "23:59");
});

test("clock formats 12-hour time across midnight and noon", () => {
    assert.equal(clock(new Date(2026, 9, 12, 0, 5), false), "12:05 AM");
    assert.equal(clock(new Date(2026, 9, 12, 9, 7), false), "9:07 AM");
    assert.equal(clock(new Date(2026, 9, 12, 12, 0), false), "12:00 PM");
    assert.equal(clock(new Date(2026, 9, 12, 13, 4), false), "1:04 PM");
});

test("dateShort formats the local weekday, day, and month", () => {
    assert.equal(dateShort(new Date(2026, 9, 12)), "Mon 12 Oct");
    assert.equal(dateShort(new Date(2026, 0, 1)), "Thu 1 Jan");
    assert.equal(dateShort(new Date(2026, 11, 31)), "Thu 31 Dec");
});
