import qs.components
import qs.services

Tile {
    active: Modes.dndOn
    iconOnly: true
    icon: "do_not_disturb_on"
    title: qsTr("Do Not Disturb")
    onToggled: Modes.toggleDnd()
}
