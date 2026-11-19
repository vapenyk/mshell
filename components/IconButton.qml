pragma ComponentBehavior: Bound

import qs.config

import QtQuick as QQ
import QtQuick.Controls as QQC

QQC.AbstractButton {
    id: root

    required property string iconName
    property string trailingIconName: ""
    property string variant: "standard"
    property QQ.color standardColor: Theme.onSurfaceVariant
    property bool toggle: false
    property bool selected: false
    property bool tooltipEnabled: true

    readonly property bool _filled: selected || variant === "filled"
    readonly property bool _tonal: variant === "tonal" && !_filled
    readonly property QQ.color _container: !_filled && !_tonal ? Theme.transparent
                                           : !enabled ? Theme.onSurface
                                           : _filled ? Theme.primary : Theme.secondaryContainer
    readonly property QQ.color _contentColor: !enabled ? Theme.onSurface
                                              : _filled ? Theme.onPrimary
                                              : _tonal ? Theme.onSecondaryContainer : standardColor

    implicitWidth: implicitHeight + (trailingIconName.length > 0 ? Sizing.smallIconSize + Sizing.pillGap : 0)
    implicitHeight: Sizing.sliderHeight
    padding: 0
    focusPolicy: Qt.StrongFocus
    hoverEnabled: true

    QQ.Keys.onReturnPressed: root.click()
    QQ.Keys.onEnterPressed: root.click()
    QQ.Accessible.name: text
    QQ.Accessible.checkable: toggle
    QQ.Accessible.checked: selected

    background: QQ.Rectangle {
        radius: Shape.full
        color: root._container
        opacity: root.enabled ? 1 : Theme.disabledContainerOpacity

        StateLayer {
            anchors.fill: parent
            radius: Shape.full
            contentColor: root._contentColor
            hovered: root.enabled && root.hovered
            pressed: root.enabled && root.down
            focused: root.enabled && root.visualFocus
        }
    }

    contentItem: QQ.Item {
        QQ.Row {
            anchors.centerIn: parent
            opacity: root.enabled ? 1 : Theme.disabledContentOpacity
            spacing: Sizing.pillGap

            Icon {
                name: root.iconName
                size: Sizing.smallIconSize
                color: root._contentColor
                filled: root.selected
            }

            Icon {
                visible: root.trailingIconName.length > 0
                name: root.trailingIconName
                size: Sizing.smallIconSize
                color: root._contentColor
            }
        }
    }

    Tooltip {
        text: root.text
        requested: root.tooltipEnabled && root.enabled && root.hovered && !root.down
    }
}
