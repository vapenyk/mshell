pragma ComponentBehavior: Bound

import qs.components
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

            StateLayer {
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

                Icon {
                    anchors.verticalCenter: parent.verticalCenter
                    name: "schedule"
                    size: Sizing.smallIconSize
                    color: clockLabel.color
                }

                Text {
                    id: clockLabel

                    anchors.verticalCenter: parent.verticalCenter
                    text: Format.clock(Time.date, true)
                    color: Theme.onSurface
                    font.family: Typography.family
                    font.pixelSize: Typography.labelLarge.size
                    font.weight: Typography.labelLarge.weight
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
