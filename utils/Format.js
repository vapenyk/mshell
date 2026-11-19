.pragma library

function clock(date, use24h) {
    var hours = date.getHours();
    var minutes = String(date.getMinutes()).padStart(2, "0");

    if (use24h)
        return String(hours).padStart(2, "0") + ":" + minutes;

    var hour = hours % 12 || 12;
    var period = hours < 12 ? "AM" : "PM";
    return hour + ":" + minutes + " " + period;
}

function dateShort(date) {
    var days = ["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"];
    var months = ["Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"];
    return days[date.getDay()] + " " + date.getDate() + " " + months[date.getMonth()];
}
