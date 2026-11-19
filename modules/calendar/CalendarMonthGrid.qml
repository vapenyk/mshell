pragma ComponentBehavior: Bound

import qs.components as Components
import qs.config
import "Calendar.model.js" as Model

import QtQuick as QQ
import QtQuick.Controls as QQC

QQ.Column {
    id: root

    required property var locale
    required property date month
    required property date today
    required property date selectedDate
    readonly property int columns: Model.daysPerWeek
    readonly property real cellWidth: width / columns
    readonly property var _days: Model.daysForMonth(month.getFullYear(), month.getMonth(),
                                                    locale.firstDayOfWeek % columns)
    readonly property int _tabIndex: Model.focusDayIndex(_days, selectedDate, today)

    signal dateChosen(day: date)

    spacing: Sizing.popupGap

    QQ.Row {
        QQ.Repeater {
            model: root.columns

            Components.Text {
                required property int index

                width: root.cellWidth
                height: Sizing.pillHeight
                text: root.locale.standaloneDayName((root.locale.firstDayOfWeek + index - 1)
                                                   % root.columns + 1, QQ.Locale.NarrowFormat)
                horizontalAlignment: QQ.Text.AlignHCenter
                verticalAlignment: QQ.Text.AlignVCenter
                role: "labelLarge"
                color: Theme.onSurfaceVariant
            }
        }
    }

    QQ.Grid {
        columns: root.columns

        QQ.Repeater {
            id: days

            model: root._days

            QQC.AbstractButton {
                id: cell

                required property var modelData
                required property int index
                readonly property string dateState: Model.dayState(modelData, root.selectedDate, root.today)
                readonly property bool selected: dateState === "selected"
                readonly property QQ.color foreground: selected ? Theme.onPrimary : Theme.onSurface

                width: root.cellWidth
                height: Sizing.calendarDayHeight
                enabled: modelData.inMonth
                hoverEnabled: enabled
                focusPolicy: index === root._tabIndex ? Qt.StrongFocus : Qt.ClickFocus
                padding: 0
                text: modelData.inMonth ? String(modelData.date.getDate()) : ""
                QQ.Accessible.ignored: !modelData.inMonth
                QQ.Accessible.name: Qt.formatDate(modelData.date, QQ.Locale.LongFormat)
                QQ.Accessible.checkable: modelData.inMonth
                QQ.Accessible.checked: selected

                function focusDay(): void {
                    if (enabled)
                        forceActiveFocus(Qt.TabFocusReason);
                }

                QQ.Keys.onLeftPressed: days.itemAt(index - 1)?.focusDay()
                QQ.Keys.onRightPressed: days.itemAt(index + 1)?.focusDay()
                QQ.Keys.onUpPressed: days.itemAt(index - root.columns)?.focusDay()
                QQ.Keys.onDownPressed: days.itemAt(index + root.columns)?.focusDay()
                QQ.Keys.onReturnPressed: click()
                QQ.Keys.onEnterPressed: click()
                onClicked: root.dateChosen(modelData.date)

                background: QQ.Item {
                    Components.Surface {
                        anchors.centerIn: parent
                        width: Math.min(parent.width, Sizing.calendarDayMarkerSize)
                        height: width
                        radius: Shape.full
                        container: cell.selected ? Theme.primary : Theme.transparent
                        border.width: cell.dateState === "today" ? Sizing.outlineWidth : Shape.none
                        border.color: Theme.outline

                        Components.StateLayer {
                            anchors.fill: parent
                            radius: Shape.full
                            contentColor: cell.foreground
                            hovered: cell.hovered
                            pressed: cell.down
                            focused: cell.visualFocus
                        }
                    }
                }

                contentItem: Components.Text {
                    text: cell.text
                    role: "bodyLarge"
                    color: cell.foreground
                    horizontalAlignment: QQ.Text.AlignHCenter
                    verticalAlignment: QQ.Text.AlignVCenter
                }
            }
        }
    }
}
