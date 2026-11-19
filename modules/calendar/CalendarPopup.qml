pragma ComponentBehavior: Bound

import qs.components as Components
import qs.config
import qs.services
import "Calendar.model.js" as Model

import QtQuick as QQ
import QtQuick.Controls as QQC
import QtQuick.Layouts as QQL

Components.AnchoredPopup {
    id: popup

    requestedAnchor: UiState.openPopup === "calendar" ? UiState.popupAnchor : null
    preferredWidth: Sizing.calendarWidth
    compactWidth: Sizing.calendarCompactWidth
    onDismissRequested: UiState.close()

    content: QQ.Column {
        id: calendar

        readonly property var locale: Qt.locale()
        readonly property date today: Time.date
        property date month: Model.shiftMonth(today, 0)
        property date selectedDate: today
        property bool choosingYear: false

        spacing: Sizing.popupGap

        QQ.Connections {
            target: popup

            function onRequestedAnchorChanged(): void {
                if (!popup.requestedAnchor)
                    return;
                calendar.selectedDate = Qt.binding(() => calendar.today);
                calendar.month = Qt.binding(() => Model.shiftMonth(calendar.today, 0));
                calendar.choosingYear = false;
                monthButton.forceActiveFocus(Qt.OtherFocusReason);
            }
        }

        QQL.RowLayout {
            width: parent.width
            spacing: Sizing.pillGap

            QQC.AbstractButton {
                id: monthButton

                QQL.Layout.minimumWidth: Sizing.sliderHeight
                implicitWidth: implicitContentWidth + leftPadding + rightPadding
                implicitHeight: previousMonth.implicitHeight
                leftPadding: Sizing.pillHorizontalPadding
                rightPadding: Sizing.pillHorizontalPadding
                focus: true
                hoverEnabled: true
                text: qsTr("%1 %2").arg(calendar.locale.standaloneMonthName(calendar.month.getMonth()))
                                    .arg(calendar.month.getFullYear())
                QQ.Accessible.checkable: true
                QQ.Accessible.checked: calendar.choosingYear
                QQ.Accessible.description: qsTr("Choose year")
                QQ.Keys.onReturnPressed: click()
                QQ.Keys.onEnterPressed: click()
                onClicked: calendar.choosingYear = !calendar.choosingYear

                background: Components.StateLayer {
                    radius: Shape.full
                    contentColor: Theme.onSurface
                    hovered: monthButton.hovered
                    pressed: monthButton.down
                    focused: monthButton.visualFocus
                }

                contentItem: QQL.RowLayout {
                    spacing: Sizing.pillGap

                    Components.Text {
                        QQL.Layout.fillWidth: true
                        text: monthButton.text
                        role: "titleMedium"
                    }

                    Components.Icon {
                        name: calendar.choosingYear ? "expand_less" : "expand_more"
                        size: Sizing.smallIconSize
                        color: Theme.onSurfaceVariant
                    }
                }
            }

            QQ.Item { QQL.Layout.fillWidth: true }

            Components.IconButton {
                id: previousMonth

                visible: !calendar.choosingYear
                enabled: calendar.month.getFullYear() > Model.firstYear || calendar.month.getMonth() > 0
                iconName: "chevron_left"
                text: qsTr("Previous month")
                onClicked: calendar.month = Model.shiftMonth(calendar.month, -1)
            }

            Components.IconButton {
                visible: !calendar.choosingYear
                enabled: calendar.month.getFullYear() < Model.lastYear || calendar.month.getMonth() < 11
                iconName: "chevron_right"
                text: qsTr("Next month")
                onClicked: calendar.month = Model.shiftMonth(calendar.month, 1)
            }
        }

        QQ.Loader {
            width: parent.width
            height: Sizing.pillHeight + Sizing.popupGap + Model.weeksPerMonth * Sizing.calendarDayHeight
            sourceComponent: calendar.choosingYear ? yearPicker : monthGrid
            onLoaded: {
                if (calendar.choosingYear)
                    item.forceActiveFocus(Qt.TabFocusReason);
            }
        }

        QQ.Component {
            id: monthGrid

            CalendarMonthGrid {
                locale: calendar.locale
                month: calendar.month
                today: calendar.today
                selectedDate: calendar.selectedDate
                onDateChosen: day => calendar.selectedDate = day
            }
        }

        QQ.Component {
            id: yearPicker

            CalendarYearGrid {
                displayedYear: calendar.month.getFullYear()
                onYearChosen: year => {
                    calendar.month = Model.monthInYear(calendar.month, year);
                    calendar.choosingYear = false;
                    monthButton.forceActiveFocus(Qt.TabFocusReason);
                }
            }
        }
    }
}
