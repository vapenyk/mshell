import qs.config

import QtQuick
import QtQuick.Effects

Rectangle {
    id: root

    property color container: Theme.surfaceContainer
    property bool shadow: false

    color: container
    radius: Shape.none

    RectangularShadow {
        anchors.fill: parent
        z: -1
        visible: root.shadow
        color: Theme.shadow
        opacity: Theme.popupShadow.opacity
        blur: Theme.popupShadow.blur
        offset.y: Theme.popupShadow.offsetY
        radius: root.radius
    }

    Behavior on color {
        ColorAnimation {
            duration: Motion.short2
            easing.type: Easing.BezierSpline
            easing.bezierCurve: Motion.standard
        }
    }
}
