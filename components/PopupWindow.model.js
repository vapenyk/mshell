.pragma library

function placement(screenWidth, screenHeight, anchorX, anchorWidth, barHeight,
                   preferredWidth, contentHeight, margin, gap, centerOnAnchor, shadow, slideDistance) {
    var width = Math.max(1, Math.min(preferredWidth, screenWidth - 2 * margin));
    var anchorRight = anchorX + anchorWidth;
    var anchorCenter = anchorX + anchorWidth / 2;
    var left = centerOnAnchor ? anchorCenter - width / 2
             : anchorCenter >= screenWidth / 2 ? anchorRight - width : anchorX;
    var x = Math.round(Math.max(margin, Math.min(left, screenWidth - margin - width)));
    var y = barHeight + gap;
    var height = Math.max(1, Math.round(Math.min(contentHeight, screenHeight - y - margin)));
    var leftPadding = Math.min(x, shadow.blur);
    var rightPadding = Math.min(Math.max(0, screenWidth - x - width), shadow.blur);
    var topPadding = Math.min(y, Math.max(0, shadow.blur - shadow.offsetY) + slideDistance);
    var bottomPadding = Math.min(Math.max(0, screenHeight - y - height), shadow.blur + shadow.offsetY);

    return {
        x: x,
        y: y,
        width: width,
        height: height,
        window: {
            x: x - leftPadding,
            y: y - topPadding,
            width: width + leftPadding + rightPadding,
            height: height + topPadding + bottomPadding,
        },
    };
}
