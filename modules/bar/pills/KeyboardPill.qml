import qs.components as Components
import qs.config
import qs.services

import QtQuick

Components.Pill {
    id: root

    visible: Keyboard.layouts.length > 1 && Keyboard.current !== null
    active: UiState.openPopup === "keyboard" && UiState.popupAnchor === root
    idleContainer: Theme.transparent
    text: Keyboard.current?.code ?? ""
    Accessible.name: qsTr("Keyboard layout: %1").arg(Keyboard.current?.label ?? "")

    onClicked: UiState.toggleAt("keyboard", root)
}
