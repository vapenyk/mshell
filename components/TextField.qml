import qs.config

import QtQuick as QQ
import QtQuick.Controls.Basic as Basic

Basic.TextField {
    id: root

    leftPadding: Sizing.popupInnerPadding
    rightPadding: Sizing.popupInnerPadding
    color: Theme.onSurface
    placeholderTextColor: Theme.onSurfaceVariant
    selectionColor: Theme.primary
    selectedTextColor: Theme.onPrimary
    font.family: Typography.family
    font.pixelSize: Typography.bodyMedium.size
    selectByMouse: true

    background: QQ.Rectangle {
        color: Theme.surfaceContainerLowest
        radius: Shape.full
        border.width: root.activeFocus ? Sizing.outlineWidth : Shape.none
        border.color: Theme.primary
    }
}
