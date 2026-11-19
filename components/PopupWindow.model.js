.pragma library

function placement(screenWidth, screenHeight, anchorX, anchorWidth, barHeight,
                   preferredWidth, contentHeight, margin, gap, centerOnAnchor) {
    var width = Math.max(1, Math.min(preferredWidth, screenWidth - 2 * margin));
    var anchorRight = anchorX + anchorWidth;
    var anchorCenter = anchorX + anchorWidth / 2;
    var left = centerOnAnchor ? anchorCenter - width / 2
             : anchorCenter >= screenWidth / 2 ? anchorRight - width : anchorX;
    var top = barHeight + gap;

    return {
        x: Math.round(Math.max(margin, Math.min(left, screenWidth - margin - width))),
        y: top,
        width: width,
        height: Math.max(1, Math.min(contentHeight, screenHeight - top - margin)),
    };
}
