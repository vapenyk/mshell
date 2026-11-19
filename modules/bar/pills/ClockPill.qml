import qs.components as Components
import qs.services
import "ClockPill.model.js" as Model

Components.Pill {
    id: root

    required property string sizeClass

    text: Model.label(Time.date, root.sizeClass, true)
    onClicked: UiState.toggle("calendar")
}
