pragma ComponentBehavior: Bound

import qs.config
import qs.services
import "pills"

import Quickshell
import QtQuick

Variants {
    model: Quickshell.screens

    PanelWindow {
        id: barWindow

        required property ShellScreen modelData
        readonly property alias statusAnchor: statusPill

        screen: modelData
        anchors {
            top: true
            left: true
            right: true
        }
        implicitHeight: Sizing.barHeight
        exclusiveZone: Sizing.barHeight
        focusable: false
        color: Theme.transparent

        ClockPill {
            id: clockPill

            anchors {
                left: parent.left
                leftMargin: Sizing.barSideMargin
                verticalCenter: parent.verticalCenter
            }
            sizeClass: Theme.sizeClass(modelData)
        }

        StatusPill {
            id: statusPill

            anchors {
                right: parent.right
                rightMargin: Sizing.barSideMargin
                verticalCenter: parent.verticalCenter
            }
        }

        NotifPill {
            id: notifPill

            anchors {
                right: statusPill.left
                rightMargin: Sizing.pillGap
                verticalCenter: parent.verticalCenter
            }
        }

        KeyboardPill {
            id: keyboardPill

            anchors {
                right: notifPill.left
                rightMargin: Sizing.pillGap
                verticalCenter: parent.verticalCenter
            }
        }

        // The open popup's focus grab can leave keyboard focus on the bar.
        Shortcut {
            sequence: "Escape"
            enabled: UiState.openPopup === "calendar" || UiState.openPopup === "keyboard"
            onActivated: UiState.close()
        }

        TapHandler {
            enabled: UiState.openPopup !== ""
            acceptedButtons: Qt.AllButtons
            onTapped: point => {
                const overClock = clockPill.contains(clockPill.mapFromItem(barWindow.contentItem, point.position));
                const overStatus = statusPill.contains(statusPill.mapFromItem(barWindow.contentItem, point.position));
                const overNotif = notifPill.contains(notifPill.mapFromItem(barWindow.contentItem, point.position));
                const overKeyboard = keyboardPill.visible
                    && keyboardPill.contains(keyboardPill.mapFromItem(barWindow.contentItem, point.position));
                if (!overClock && !overStatus && !overNotif && !overKeyboard)
                    UiState.close();
            }
        }
    }
}
