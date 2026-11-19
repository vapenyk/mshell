pragma ComponentBehavior: Bound

import qs.config

import QtQuick as QQ
import QtQuick.Controls as QQC

QQC.ToolTip {
    id: root

    property bool requested: false
    property real _anchorTop: 0

    visible: requested && text.length > 0
    delay: Motion.long2
    padding: Sizing.pillHorizontalPadding
    margins: Sizing.pillGap
    x: parent ? (parent.width - width) / 2 : 0
    y: !parent ? 0
       : _anchorTop >= height + Sizing.pillGap ? -height - Sizing.pillGap : parent.height + Sizing.pillGap
    onAboutToShow: _anchorTop = parent?.mapToItem(null, 0, 0).y ?? 0

    contentItem: Text {
        text: root.text
        color: Theme.inverseOnSurface
        role: "labelLarge"
    }

    background: Surface {
        container: Theme.inverseSurface
        radius: Shape.small
    }

    enter: QQ.Transition {
        QQ.NumberAnimation { property: "opacity"; from: 0; to: 1; duration: Motion.short3 }
    }

    exit: QQ.Transition {
        QQ.NumberAnimation { property: "opacity"; to: 0; duration: Motion.short3 }
    }
}
