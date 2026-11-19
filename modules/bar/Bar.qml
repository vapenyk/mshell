pragma ComponentBehavior: Bound

import qs.components as Components
import qs.config
import qs.services
import "../../utils/Format.js" as Format

import Quickshell

import QtQuick

Variants {
    model: Quickshell.screens

    PanelWindow {
        required property ShellScreen modelData

        screen: modelData
        anchors {
            top: true
            left: true
            right: true
        }
        implicitHeight: Sizing.barHeight
        color: Theme.transparent

        Components.Pill {
            id: clockPill

            anchors {
                left: parent.left
                leftMargin: Sizing.barSideMargin
                verticalCenter: parent.verticalCenter
            }
            text: Format.clock(Time.date, true)
            onClicked: UiState.toggle("calendar")

            trailing: Components.Text {
                text: Format.dateShort(Time.date)
                role: "labelLarge"
                color: clockPill.contentColor
            }
        }
    }
}
