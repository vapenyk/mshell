const assert = require("node:assert/strict");
const test = require("node:test");
const { loadModel } = require("../load.js");

const { month, daysForMonth, shiftMonth, monthInYear, sameDay, dayState, focusDayIndex, firstYear, lastYear } =
    loadModel("modules/calendar/Calendar.model.js");

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
    assert.ok(sameDay(shiftMonth(new Date(2026, 11, 31), 1), new Date(2027, 0, 1)));
    assert.ok(sameDay(shiftMonth(new Date(2027, 0, 30), -1), new Date(2026, 11, 1)));
    assert.equal(sameDay(new Date(2027, 0, 1), new Date(2026, 0, 1)), false);
});

test("today is selected initially and gets an outline when another date is selected", () => {
    const today = new Date(2026, 10, 19, 8);
    const selected = new Date(2026, 10, 25);
    const days = daysForMonth(2026, 10, 0);
    assert.equal(dayState(days[18], today, today), "selected");
    assert.equal(dayState(days[18], selected, today), "today");
    assert.equal(dayState(days[24], selected, today), "selected");
    assert.equal(dayState(days[17], selected, today), "plain");
});

test("adjacent-month cells stay blank even for today or the retained selected date", () => {
    const september = daysForMonth(2026, 8, 0);
    const date = new Date(2026, 9, 1);
    const cell = september.find(cell => sameDay(cell.date, date));
    assert.equal(dayState(cell, date, date), "blank");
    assert.equal(focusDayIndex(september, date, date), 2);
});

test("calendar tab enters at the selected date, then today, then the first displayed day", () => {
    const days = daysForMonth(2026, 10, 0);
    const today = new Date(2026, 10, 19);
    const selected = new Date(2026, 10, 25);
    assert.equal(focusDayIndex(days, selected, today), 24);
    assert.equal(focusDayIndex(days, new Date(2026, 11, 1), today), 18);
});

test("choosing a year retains the month and year boundaries constrain month navigation", () => {
    const leap = new Date(2024, 1, 29);
    assert.ok(sameDay(monthInYear(leap, 2027), new Date(2027, 1, 1)));
    const firstMonth = monthInYear(new Date(2026, 0, 1), firstYear);
    const lastMonth = monthInYear(new Date(2026, 11, 1), lastYear);
    assert.equal(firstMonth.getFullYear(), 1);
    assert.equal(shiftMonth(firstMonth, -1), firstMonth);
    assert.equal(shiftMonth(lastMonth, 1), lastMonth);
});
