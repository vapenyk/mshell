pragma ComponentBehavior: Bound

import qs.components as Components
import qs.config
import "Calendar.model.js" as Model

import QtQuick as QQ
import QtQuick.Controls as QQC

QQ.GridView {
    id: root

    required property int displayedYear
    readonly property int columns: 3

    signal yearChosen(year: int)

    cellWidth: Math.floor(width / columns)
    cellHeight: Sizing.calendarDayHeight
    model: Model.lastYear - Model.firstYear + 1
    currentIndex: displayedYear - Model.firstYear
    activeFocusOnTab: true
    keyNavigationEnabled: true
    boundsBehavior: QQ.Flickable.StopAtBounds
    clip: true
    QQ.Accessible.name: qsTr("Years")

    QQ.Component.onCompleted: positionViewAtIndex(currentIndex, QQ.GridView.Center)

    QQ.Keys.onReturnPressed: yearChosen(Model.firstYear + currentIndex)
    QQ.Keys.onEnterPressed: yearChosen(Model.firstYear + currentIndex)
    QQ.Keys.onSpacePressed: yearChosen(Model.firstYear + currentIndex)

    delegate: QQC.AbstractButton {
        id: yearButton

        required property int index
        readonly property int year: Model.firstYear + index
        readonly property bool selected: year === root.displayedYear
        readonly property bool current: QQ.GridView.isCurrentItem
        readonly property QQ.color foreground: selected ? Theme.onPrimary : Theme.onSurface

        width: root.cellWidth
        height: root.cellHeight
        padding: 0
        hoverEnabled: true
        focusPolicy: Qt.NoFocus
        text: String(year)
        QQ.Accessible.checkable: true
        QQ.Accessible.checked: selected
        onClicked: root.yearChosen(year)

        background: QQ.Item {
            Components.Surface {
                anchors.centerIn: parent
                width: Math.min(parent.width, 2 * Sizing.calendarDayMarkerSize)
                height: Sizing.calendarDayMarkerSize
                radius: Shape.full
                container: yearButton.selected ? Theme.primary : Theme.transparent

                Components.StateLayer {
                    anchors.fill: parent
                    radius: Shape.full
                    contentColor: yearButton.foreground
                    hovered: yearButton.hovered
                    pressed: yearButton.down
                    focused: root.activeFocus && yearButton.current
                }
            }
        }

        contentItem: Components.Text {
            text: yearButton.text
            role: "bodyLarge"
            color: yearButton.foreground
            horizontalAlignment: QQ.Text.AlignHCenter
            verticalAlignment: QQ.Text.AlignVCenter
        }
    }
}
