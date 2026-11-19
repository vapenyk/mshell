.pragma library

function dateInMonth(year, monthIndex, day) {
    var date = new Date(0);
    date.setFullYear(year, monthIndex, day);
    date.setHours(12, 0, 0, 0);
    return date;
}

function month(year, monthIndex, weekStart) {
    var first = dateInMonth(year, monthIndex, 1);
    var leading = (first.getDay() - weekStart + 7) % 7;
    var weeks = [];
    for (var row = 0; row < 6; row++) {
        var week = [];
        for (var column = 0; column < 7; column++) {
            var day = dateInMonth(year, monthIndex, 1 - leading + row * 7 + column);
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
    return dateInMonth(date.getFullYear(), date.getMonth() + offset, 1);
}

function isToday(day, now) {
    return day.getFullYear() === now.getFullYear() &&
           day.getMonth() === now.getMonth() && day.getDate() === now.getDate();
}
