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

function relative(date, now) {
    const elapsed = now.getTime() - date.getTime();
    if (!Number.isFinite(elapsed))
        return "";

    const minutes = Math.floor(elapsed / 60000);
    if (minutes < 1)
        return "now";
    if (minutes < 60)
        return minutes + "m";

    const hours = Math.floor(minutes / 60);
    return hours < 24 ? hours + "h" : Math.floor(hours / 24) + "d";
}
