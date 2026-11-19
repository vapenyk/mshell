pragma ComponentBehavior: Bound

import qs.components as Components
import qs.config
import qs.services
import ".."

import QtQuick
import QtQuick.Controls as QQC

Item {
    id: root

    required property Component powerActions

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

        Components.IconButton {
            id: powerButton

            anchors.right: parent.right
            anchors.verticalCenter: parent.verticalCenter
            iconName: "power_settings_new"
            trailingIconName: selected ? "expand_less" : "expand_more"
            text: qsTr("Power")
            toggle: true
            selected: UiState.powerMenuOpen
            tooltipEnabled: !selected
            onClicked: UiState.powerMenuOpen = !UiState.powerMenuOpen
        }

        QQC.Popup {
            id: dropdown

            parent: powerButton
            width: Sizing.powerMenuWidth
            padding: Sizing.pillGap
            margins: Sizing.pillGap
            x: powerButton.width - width
            y: powerButton.height + Sizing.pillGap
            popupType: QQC.Popup.Item
            visible: UiState.powerMenuOpen
            focus: true
            modal: true
            dim: false
            closePolicy: QQC.Popup.CloseOnEscape | QQC.Popup.CloseOnPressOutside

            onAboutToHide: UiState.powerMenuOpen = false
            onOpened: actionsLoader.item?.focusFirst()

            contentItem: Loader {
                id: actionsLoader

                active: dropdown.visible
                sourceComponent: root.powerActions
            }

            background: Components.Surface {
                container: Theme.surfaceContainerHigh
                radius: Shape.large
            }

            enter: Transition {
                NumberAnimation { property: "opacity"; from: 0; to: 1; duration: Motion.fadeThroughInDuration }
            }
            exit: Transition {
                NumberAnimation { property: "opacity"; to: 0; duration: Motion.fadeThroughOutDuration }
            }
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
