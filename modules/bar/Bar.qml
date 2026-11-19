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
            implicitWidth: clockLabel.implicitWidth + Sizing.pillHeight
            implicitHeight: Sizing.pillHeight

            StateLayer {
                anchors.fill: parent
                contentColor: clockLabel.color
                hovered: clockHover.hovered
                pressed: clockTap.pressed
                radius: Shape.full
            }

            Text {
                id: clockLabel

                anchors.centerIn: parent
                text: Format.clock(Time.date, true)
                color: Theme.onSurface
                font.family: Typography.family
                font.pixelSize: Typography.labelLarge.size
                font.weight: Typography.labelLarge.weight
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
