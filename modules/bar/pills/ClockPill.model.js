.pragma library
.import "../../../utils/Format.js" as Format

function label(date, sizeClass, use24h) {
    var time = Format.clock(date, use24h);
    return sizeClass === "compact" ? time : time + " " + Format.dateShort(date);
}
