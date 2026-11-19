import qs.config
import ".."

import QtQuick

Item {
    readonly property string title: qsTr("Control center")

    implicitHeight: grid.y + grid.implicitHeight

    TopControls {
        id: controls

        anchors {
            top: parent.top
            topMargin: Sizing.popupGap
            left: parent.left
            right: parent.right
        }
    }

    TileGrid {
        id: grid

        anchors {
            top: controls.bottom
            topMargin: Sizing.tileGridGap
            left: parent.left
            right: parent.right
        }
    }
}
