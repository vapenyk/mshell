pragma ComponentBehavior: Bound

import qs.components as Components
import qs.config
import qs.services
import "Calendar.model.js" as Model

import QtQuick as QQ
import QtQuick.Controls as QQC
import QtQuick.Layouts as QQL

Components.AnchoredPopup {
    id: root

    requestedAnchor: UiState.openPopup === "calendar" ? UiState.popupAnchor : null
    preferredWidth: requestedAnchor?.sizeClass === "compact" ? Sizing.calendarCompactWidth : Sizing.calendarWidth
    onDismissRequested: UiState.close()

    content: QQ.Column {
        id: calendar

        readonly property var locale: Qt.locale()
        property date month: Model.shiftMonth(Time.date, 0)
        readonly property int columns: 7
        readonly property bool currentMonth: Model.isToday(month, Model.shiftMonth(Time.date, 0))
        readonly property real cellWidth: width / columns

        spacing: Sizing.popupGap

        QQL.RowLayout {
            width: parent.width
            spacing: Sizing.pillGap

            Components.Text {
                QQL.Layout.fillWidth: true
                text: qsTr("%1 %2").arg(calendar.locale.standaloneMonthName(calendar.month.getMonth()))
                                    .arg(calendar.month.getFullYear())
                role: "titleMedium"
            }

            Components.IconButton {
                iconName: "chevron_left"
                text: qsTr("Previous month")
                focus: true
                onClicked: calendar.month = Model.shiftMonth(calendar.month, -1)
            }

            Components.IconButton {
                iconName: "chevron_right"
                text: qsTr("Next month")
                onClicked: calendar.month = Model.shiftMonth(calendar.month, 1)
            }
        }

        QQ.Row {
            QQ.Repeater {
                model: calendar.columns

                Components.Text {
                    required property int index

                    width: calendar.cellWidth
                    height: Sizing.pillHeight
                    text: calendar.locale.standaloneDayName((calendar.locale.firstDayOfWeek + index - 1)
                                                           % calendar.columns + 1, QQ.Locale.NarrowFormat)
                    horizontalAlignment: QQ.Text.AlignHCenter
                    verticalAlignment: QQ.Text.AlignVCenter
                    role: "labelLarge"
                    color: Theme.onSurfaceVariant
                }
            }
        }

        QQ.Grid {
            columns: calendar.columns

            QQ.Repeater {
                id: days

                model: Model.daysForMonth(calendar.month.getFullYear(), calendar.month.getMonth(),
                                          calendar.locale.firstDayOfWeek % calendar.columns)

                QQC.Control {
                    id: cell

                    required property var modelData
                    required property int index
                    readonly property bool today: modelData.inMonth && Model.isToday(modelData.date, Time.date)
                    readonly property int day: modelData.date.getDate()

                    width: calendar.cellWidth
                    height: Sizing.calendarDayHeight
                    activeFocusOnTab: modelData.inMonth && (calendar.currentMonth ? today : day === 1)
                    QQ.Accessible.ignored: !modelData.inMonth
                    QQ.Accessible.name: Qt.formatDate(modelData.date, QQ.Locale.LongFormat)

                    function focusDay(): void {
                        if (modelData.inMonth)
                            forceActiveFocus(Qt.TabFocusReason);
                    }

                    QQ.Keys.onLeftPressed: days.itemAt(index - 1)?.focusDay()
                    QQ.Keys.onRightPressed: days.itemAt(index + 1)?.focusDay()
                    QQ.Keys.onUpPressed: days.itemAt(index - calendar.columns)?.focusDay()
                    QQ.Keys.onDownPressed: days.itemAt(index + calendar.columns)?.focusDay()

                    Components.Surface {
                        anchors.centerIn: parent
                        width: Math.min(parent.width, Sizing.calendarDayMarkerSize)
                        height: width
                        radius: Shape.full
                        container: cell.today ? Theme.primary : Theme.transparent

                        Components.StateLayer {
                            anchors.fill: parent
                            radius: Shape.full
                            contentColor: cell.today ? Theme.onPrimary : Theme.onSurface
                            focused: cell.visualFocus
                        }
                    }

                    Components.Text {
                        anchors.centerIn: parent
                        text: cell.modelData.inMonth ? cell.day : ""
                        role: "bodyLarge"
                        color: cell.today ? Theme.onPrimary : Theme.onSurface
                    }
                }
            }
        }
    }
}
