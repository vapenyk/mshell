.pragma library

var daysPerWeek = 7;
var weeksPerMonth = 6;
var firstYear = 1;
var lastYear = 9999;

function dateInMonth(year, monthIndex, day) {
    var date = new Date(0);
    date.setFullYear(year, monthIndex, day);
    date.setHours(12, 0, 0, 0);
    return date;
}

function month(year, monthIndex, weekStart) {
    var first = dateInMonth(year, monthIndex, 1);
    var leading = (first.getDay() - weekStart + daysPerWeek) % daysPerWeek;
    var weeks = [];
    for (var row = 0; row < weeksPerMonth; row++) {
        var week = [];
        for (var column = 0; column < daysPerWeek; column++) {
            var day = dateInMonth(year, monthIndex, 1 - leading + row * daysPerWeek + column);
            week.push({ date: day, inMonth: day.getMonth() === first.getMonth() });
        }
        weeks.push(week);
    }
    return weeks;
}

function daysForMonth(year, monthIndex, weekStart) {
    return month(year, monthIndex, weekStart).reduce(function(days, week) {
        return days.concat(week);
    }, []);
}

function shiftMonth(date, offset) {
    var target = dateInMonth(date.getFullYear(), date.getMonth() + offset, 1);
    var year = target.getFullYear();
    return year >= firstYear && year <= lastYear ? target : date;
}

function monthInYear(date, year) {
    return dateInMonth(year, date.getMonth(), 1);
}

function sameDay(first, second) {
    return first.getFullYear() === second.getFullYear() &&
           first.getMonth() === second.getMonth() && first.getDate() === second.getDate();
}

function dayState(cell, selectedDate, today) {
    if (!cell.inMonth)
        return "blank";
    if (sameDay(cell.date, selectedDate))
        return "selected";
    return sameDay(cell.date, today) ? "today" : "plain";
}

function focusDayIndex(days, selectedDate, today) {
    var selected = days.findIndex(function(cell) {
        return cell.inMonth && sameDay(cell.date, selectedDate);
    });
    if (selected >= 0)
        return selected;
    var current = days.findIndex(function(cell) {
        return cell.inMonth && sameDay(cell.date, today);
    });
    return current >= 0 ? current : days.findIndex(function(cell) { return cell.inMonth; });
}
