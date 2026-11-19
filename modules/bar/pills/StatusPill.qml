pragma ComponentBehavior: Bound

import qs.components as Components
import qs.config
import qs.services
import "StatusPill.model.js" as Model

import QtQuick

Item {
    id: root

    readonly property var icons: Model.icons({
        network: Network,
        bluetooth: Bluetooth,
        battery: Battery,
    })
    readonly property bool _shown: icons.length > 0
    property var _outgoingIcons: []
    property real _animatedWidth: _shown ? pill.implicitWidth : 0

    onIconsChanged: {
        if (_shown)
            _outgoingIcons = icons;
    }

    implicitWidth: Math.max(0, _animatedWidth)
    implicitHeight: pill.implicitHeight
    clip: true
    enabled: _shown
    opacity: _shown ? 1 : 0

    Behavior on _animatedWidth {
        SpringAnimation {
            spring: Motion.spatialDefault.spring
            damping: Motion.spatialDefault.damping
            mass: Motion.spatialDefault.mass
        }
    }

    Behavior on opacity {
        NumberAnimation {
            duration: Motion.short2
            easing.type: Easing.BezierSpline
            easing.bezierCurve: Motion.standard
        }
    }

    Components.Pill {
        id: pill

        anchors.right: parent.right
        active: UiState.openPopup === "controlcenter" && UiState.popupAnchor === root
        onClicked: UiState.toggleAt("controlcenter", root)

        trailing: Row {
            spacing: Sizing.pillGap

            Repeater {
                // Keep the outgoing icons in place until the pill finishes fading out.
                model: root._shown ? root.icons : root.opacity > 0 ? root._outgoingIcons : []

                delegate: Row {
                    id: indicator

                    required property var modelData
                    readonly property color contentColor: modelData.low ? Theme.error : pill.contentColor

                    spacing: Sizing.pillGap

                    Components.Icon {
                        anchors.verticalCenter: parent.verticalCenter
                        name: indicator.modelData.name
                        filled: indicator.modelData.filled
                        size: Sizing.smallIconSize
                        color: indicator.contentColor
                    }

                    Components.Text {
                        anchors.verticalCenter: parent.verticalCenter
                        visible: text.length > 0
                        text: indicator.modelData.text ?? ""
                        role: "labelLarge"
                        color: indicator.contentColor
                    }
                }
            }
        }
    }
}
