import qs.config

import QtQuick

Rectangle {
    id: root

    required property color contentColor
    property bool hovered: false
    property bool pressed: false
    property bool focused: false

    color: contentColor
    radius: Shape.none
    opacity: pressed ? Theme.statePressed
           : focused ? Theme.stateFocus
           : hovered ? Theme.stateHover
           : 0

    Behavior on opacity {
        NumberAnimation {
            duration: Motion.short2
            easing.type: Easing.BezierSpline
            easing.bezierCurve: Motion.standard
        }
    }
}
