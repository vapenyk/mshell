const assert = require("node:assert/strict");
const test = require("node:test");
const { loadModel } = require("../load.js");

const { month, daysForMonth, shiftMonth, isToday } = loadModel("modules/calendar/Calendar.model.js");

test("February has 29 days in a leap year and 28 otherwise", () => {
    const count = year => month(year, 1, 1).flat().filter(day => day.inMonth).length;
    assert.equal(count(2024), 29);
    assert.equal(count(2025), 28);
});

test("week start follows the locale and leading dates belong to the prior month", () => {
    const sundayStart = month(2026, 10, 0);
    const mondayStart = month(2026, 10, 1);
    assert.equal(sundayStart[0][0].date.getDate(), 1);
    assert.equal(sundayStart[0][0].inMonth, true);
    assert.equal(mondayStart[0][0].date.getDate(), 26);
    assert.equal(mondayStart[0][0].inMonth, false);
    assert.equal(mondayStart[0][6].date.getDate(), 1);
});

test("a six-week month fits without changing the fixed grid size", () => {
    const weeks = month(2026, 7, 1);
    assert.equal(weeks.length, 6);
    assert.equal(weeks[5][0].date.getDate(), 31);
    assert.equal(weeks[5][0].inMonth, true);
    assert.equal(weeks[5][1].inMonth, false);
    assert.equal(daysForMonth(2026, 7, 1)[35].date.getDate(), 31);
});

test("month navigation crosses the year boundary from a late day of the month", () => {
    assert.ok(isToday(shiftMonth(new Date(2026, 11, 31), 1), new Date(2027, 0, 1)));
    assert.ok(isToday(shiftMonth(new Date(2027, 0, 30), -1), new Date(2026, 11, 1)));
    assert.equal(isToday(new Date(2027, 0, 1), new Date(2026, 0, 1)), false);
});
