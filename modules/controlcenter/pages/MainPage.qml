pragma ComponentBehavior: Bound

import qs.components as Components
import qs.config
import qs.services
import ".."

import QtQuick

Item {
    id: root

    required property Component powerButton

    signal settingsRequested(tileId: string)
    signal mixerRequested()

    readonly property Component headerContent: Item {
        implicitHeight: actions.implicitHeight

        Row {
            id: actions

            spacing: Sizing.pillGap

            Components.IconButton {
                iconName: "edit"
                text: qsTr("Edit tiles")
                toggle: true
                selected: UiState.editMode
                onClicked: UiState.editMode = !UiState.editMode
            }

            Components.IconButton {
                iconName: "settings"
                text: qsTr("Settings")
                enabled: false
            }
        }

        Loader {
            anchors.right: parent.right
            anchors.verticalCenter: parent.verticalCenter
            sourceComponent: root.powerButton
        }
    }

    implicitHeight: grid.y + grid.implicitHeight

    TopControls {
        id: controls

        onMixerRequested: root.mixerRequested()

        anchors {
            top: parent.top
            topMargin: Sizing.popupGap
            left: parent.left
            right: parent.right
        }
    }

    TileGrid {
        id: grid

        onSettingsRequested: tileId => root.settingsRequested(tileId)

        anchors {
            top: controls.bottom
            topMargin: Sizing.tileGridGap
            left: parent.left
            right: parent.right
        }
    }
}
