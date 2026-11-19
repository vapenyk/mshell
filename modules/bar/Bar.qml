pragma ComponentBehavior: Bound

import qs.config
import "pills"

import Quickshell

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
        exclusiveZone: Sizing.barHeight
        focusable: false
        color: Theme.transparent

        ClockPill {
            anchors {
                left: parent.left
                leftMargin: Sizing.barSideMargin
                verticalCenter: parent.verticalCenter
            }
            sizeClass: Theme.sizeClass(modelData)
        }

        StatusPill {
            anchors {
                right: parent.right
                rightMargin: Sizing.barSideMargin
                verticalCenter: parent.verticalCenter
            }
        }
    }
}
