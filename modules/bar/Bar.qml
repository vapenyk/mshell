pragma ComponentBehavior: Bound

import qs.config
import qs.services

import Quickshell
import QtQuick

Variants {
    model: Quickshell.screens
    readonly property Component lockContent: BarContent {}

    PanelWindow {
        id: barWindow

        required property ShellScreen modelData
        readonly property Item statusAnchor: barContent.statusAnchor

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

        BarContent {
            id: barContent

            anchors.fill: parent
            screen: barWindow.modelData
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
                if (!barContent.containsAction(point.position))
                    UiState.close();
            }
        }
    }
}
