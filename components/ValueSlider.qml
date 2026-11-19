pragma ComponentBehavior: Bound

import qs.config
import "ValueSlider.model.js" as Model

import QtQuick as QQ

QQ.Item {
    id: root

    required property string accessibleName
    property string icon: ""
    property real minimumValue: 0
    property real maximumValue: 1
    property real stepSize: 0.01
    property real value: minimumValue

    signal moved(value: real)

    readonly property real _handleWidth: Math.min(width, Sizing.sliderHandleWidth)
    readonly property real _travel: width - _handleWidth
    readonly property real _valuePosition: Model.posFromValue(value, _travel, minimumValue, maximumValue)
    readonly property real _position: pointer.pressed ? _pointerPosition(pointer.mouseX)
                                      : settle.running ? _settlingPosition : _valuePosition
    readonly property real _handleCenter: _handleWidth / 2 + Model.clamp(_position, 0, _travel)
    property real _settlingPosition: 0

    implicitHeight: Sizing.sliderHeight
    activeFocusOnTab: enabled
    onValueChanged: settle.stop()

    function _requestValue(next: real): void {
        if (next !== value)
            moved(next);
    }

    function _requestAt(x: real): void {
        _requestValue(Model.valueFromPos(x - _handleWidth / 2, _travel, minimumValue, maximumValue, stepSize));
    }

    function _pointerPosition(x: real): real {
        return Model.clamp(x - _handleWidth / 2, 0, _travel);
    }

    function _step(direction: int): void {
        if (enabled)
            _requestValue(Model.stepValue(value, minimumValue, maximumValue, stepSize, direction));
    }

    QQ.Keys.onLeftPressed: root._step(-1)
    QQ.Keys.onDownPressed: root._step(-1)
    QQ.Keys.onRightPressed: root._step(1)
    QQ.Keys.onUpPressed: root._step(1)
    QQ.Accessible.role: QQ.Accessible.Slider
    QQ.Accessible.name: accessibleName
    QQ.Accessible.focusable: enabled
    QQ.Accessible.onDecreaseAction: root._step(-1)
    QQ.Accessible.onIncreaseAction: root._step(1)

    QQ.SpringAnimation {
        id: settle

        target: root
        property: "_settlingPosition"
        to: root._valuePosition
        spring: Motion.spatialFast.spring
        damping: Motion.spatialFast.damping
        mass: Motion.spatialFast.mass
    }

    TrackSegment {
        id: filled

        leading: true
        width: Math.max(0, root._handleCenter - root._handleWidth / 2 - Sizing.sliderHandleGap)
        color: root.enabled ? Theme.primary : Theme.onSurface
        contentColor: Theme.onPrimary
    }

    TrackSegment {
        leading: false
        anchors.right: parent.right
        width: Math.max(0, root.width - root._handleCenter - root._handleWidth / 2 - Sizing.sliderHandleGap)
        color: root.enabled ? Theme.surfaceContainerHighest : Theme.onSurface
        contentColor: Theme.onSurfaceVariant
    }

    QQ.Rectangle {
        x: root._handleCenter - width / 2
        width: root._handleWidth
        height: root.height
        color: root.enabled ? Theme.primary : Theme.onSurface
        opacity: root.enabled ? 1 : Theme.disabledContentOpacity
        radius: Shape.full
    }

    Icon {
        anchors.right: parent.right
        anchors.rightMargin: Sizing.pillHorizontalPadding
        anchors.verticalCenter: parent.verticalCenter
        visible: root.icon.length > 0 && root.width >= width + 2 * Sizing.pillHorizontalPadding
        name: root.icon
        size: Sizing.smallIconSize
        color: !root.enabled ? Theme.onSurface
             : filled.width >= x + width / 2 ? Theme.onPrimary : Theme.onSurfaceVariant
        opacity: root.enabled ? 1 : Theme.disabledContentOpacity
    }

    QQ.MouseArea {
        id: pointer

        anchors.fill: parent
        hoverEnabled: true
        preventStealing: true
        scrollGestureEnabled: false
        onWheel: event => {
            if (event.angleDelta.y !== 0)
                root._step(Math.sign(event.angleDelta.y));
            else
                event.accepted = false;
        }
        onPressed: mouse => {
            settle.stop();
            root.forceActiveFocus(Qt.MouseFocusReason);
            root._requestAt(mouse.x);
        }
        onPositionChanged: mouse => {
            if (pressed)
                root._requestAt(mouse.x);
        }
        onReleased: mouse => {
            root._requestAt(mouse.x);
            settle.from = root._pointerPosition(mouse.x);
            if (settle.from !== settle.to) {
                root._settlingPosition = settle.from;
                settle.start();
            }
        }
    }

    component TrackSegment: QQ.Rectangle {
        id: segment

        required property bool leading
        required property QQ.color contentColor

        height: root.height
        opacity: root.enabled ? 1 : Theme.disabledContainerOpacity
        radius: Shape.full
        topLeftRadius: leading ? radius : Shape.extraSmall
        bottomLeftRadius: topLeftRadius
        topRightRadius: leading ? Shape.extraSmall : radius
        bottomRightRadius: topRightRadius

        StateLayer {
            anchors.fill: parent
            radius: segment.radius
            topLeftRadius: segment.topLeftRadius
            bottomLeftRadius: segment.bottomLeftRadius
            topRightRadius: segment.topRightRadius
            bottomRightRadius: segment.bottomRightRadius
            contentColor: segment.contentColor
            hovered: root.enabled && pointer.containsMouse
            pressed: root.enabled && pointer.pressed
            focused: root.enabled && root.activeFocus
        }
    }
}
