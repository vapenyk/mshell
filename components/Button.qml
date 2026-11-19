pragma ComponentBehavior: Bound

import qs.config

import QtQuick as QQ
import QtQuick.Controls as QQC
import QtQuick.Layouts as QQL

QQC.AbstractButton {
    id: root

    property string variant: "filled"
    property string iconName: ""
    property bool alignLeading: false
    readonly property QQ.color _container: variant === "error" ? Theme.errorContainer
        : variant === "filled" ? Theme.primary
        : variant === "tonal" ? Theme.secondaryContainer : Theme.transparent
    readonly property QQ.color _foreground: !enabled ? Theme.onSurface
        : variant === "error" ? Theme.onErrorContainer
        : variant === "filled" ? Theme.onPrimary
        : variant === "tonal" ? Theme.onSecondaryContainer
        : variant === "outlined" ? Theme.primary : Theme.onSurface

    implicitWidth: implicitContentWidth + leftPadding + rightPadding
    implicitHeight: Sizing.sliderHeight
    leftPadding: Sizing.popupInnerPadding
    rightPadding: Sizing.popupInnerPadding
    topPadding: 0
    bottomPadding: 0
    hoverEnabled: true
    focusPolicy: Qt.StrongFocus

    QQ.Keys.onReturnPressed: click()
    QQ.Keys.onEnterPressed: click()

    background: QQ.Rectangle {
        id: shape

        color: root._container
        radius: root.down ? Shape.large : height / 2
        border.width: root.variant === "outlined" ? Sizing.outlineWidth : Shape.none
        border.color: Theme.outline
        opacity: root.enabled ? 1 : Theme.disabledContainerOpacity

        QQ.Behavior on radius {
            QQ.SpringAnimation {
                spring: Motion.spatialFast.spring
                damping: Motion.spatialFast.damping
                mass: Motion.spatialFast.mass
            }
        }

        StateLayer {
            anchors.fill: parent
            radius: shape.radius
            contentColor: root._foreground
            hovered: root.enabled && root.hovered
            pressed: root.enabled && root.down
            focused: root.visualFocus
        }
    }

    contentItem: QQL.RowLayout {
        spacing: Sizing.popupGap
        opacity: root.enabled ? 1 : Theme.disabledContentOpacity

        Icon {
            visible: root.iconName.length > 0
            name: root.iconName
            size: Sizing.smallIconSize
            color: root._foreground
        }

        Text {
            QQL.Layout.fillWidth: true
            QQL.Layout.minimumWidth: Shape.none
            text: root.text
            role: "labelLarge"
            horizontalAlignment: root.alignLeading ? QQ.Text.AlignLeft : QQ.Text.AlignHCenter
            color: root._foreground
        }
    }
}
