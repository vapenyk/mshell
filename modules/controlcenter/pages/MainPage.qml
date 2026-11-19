import qs.config
import ".."

import QtQuick

Item {
    readonly property string title: qsTr("Control center")

    implicitHeight: controls.implicitHeight + Sizing.popupGap

    TopControls {
        id: controls

        anchors {
            top: parent.top
            topMargin: Sizing.popupGap
            left: parent.left
            right: parent.right
        }
    }
}
