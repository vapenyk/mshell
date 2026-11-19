import qs.config

import QtQuick as QQ

QQ.Item {
    id: root

    required property string name
    property int size: Sizing.iconSize
    property QQ.color color: Theme.onSurface
    property bool filled: false

    property real _fill: filled ? 1 : 0

    implicitWidth: size
    implicitHeight: size

    QQ.Behavior on _fill {
        QQ.NumberAnimation {
            duration: Motion.short2
            easing.type: QQ.Easing.BezierSpline
            easing.bezierCurve: Motion.standard
        }
    }

    QQ.Text {
        anchors.centerIn: parent
        text: root.name
        textFormat: QQ.Text.PlainText
        color: root.color
        font.family: Typography.iconFamily
        font.pixelSize: root.size
        font.features: ({ liga: 1 })
        font.variableAxes: ({ FILL: root._fill, opsz: root.size })
    }
}
