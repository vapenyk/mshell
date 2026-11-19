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

        Item {
            anchors.centerIn: parent
            implicitWidth: clockContent.implicitWidth + Sizing.pillHeight
            implicitHeight: Sizing.pillHeight

            Components.StateLayer {
                anchors.fill: parent
                contentColor: clockLabel.color
                hovered: clockHover.hovered
                pressed: clockTap.pressed
                radius: Shape.full
            }

            Row {
                id: clockContent

                anchors.centerIn: parent
                spacing: Sizing.pillGap

                Components.Icon {
                    anchors.verticalCenter: parent.verticalCenter
                    name: "schedule"
                    size: Sizing.smallIconSize
                    color: clockLabel.color
                }

                Components.Text {
                    id: clockLabel

                    anchors.verticalCenter: parent.verticalCenter
                    text: Format.clock(Time.date, true)
                    role: "labelLarge"
                }
            }

            HoverHandler {
                id: clockHover
            }

            TapHandler {
                id: clockTap

                gesturePolicy: TapHandler.WithinBounds
            }
        }
    }
}
