pragma ComponentBehavior: Bound

import qs.config

import QtQuick as QQ
import QtQuick.Controls as QQC

QQC.AbstractButton {
    id: root

    required property string iconName
    property string variant: "standard"
    property bool toggle: false
    property bool selected: false

    readonly property bool _filled: selected || variant === "filled"
    readonly property bool _tonal: variant === "tonal" && !_filled
    readonly property QQ.color _container: !_filled && !_tonal ? Theme.transparent
                                           : !enabled ? Theme.onSurface
                                           : _filled ? Theme.primary : Theme.secondaryContainer
    readonly property QQ.color _contentColor: !enabled ? Theme.onSurface
                                              : _filled ? Theme.onPrimary
                                              : _tonal ? Theme.onSecondaryContainer : Theme.onSurfaceVariant

    implicitWidth: Sizing.sliderHeight
    implicitHeight: implicitWidth
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
        Icon {
            anchors.centerIn: parent
            name: root.iconName
            size: Sizing.smallIconSize
            color: root._contentColor
            filled: root.selected
            opacity: root.enabled ? 1 : Theme.disabledContentOpacity
        }
    }

    QQC.ToolTip {
        text: root.text
        visible: root.enabled && root.hovered && text.length > 0
        delay: Motion.long2
        padding: Sizing.pillHorizontalPadding

        contentItem: Text {
            text: root.text
            role: "labelLarge"
        }

        background: Surface {
            container: Theme.surfaceContainerHighest
            radius: Shape.extraSmall
        }
    }
}
