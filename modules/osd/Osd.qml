import qs.components as Components
import qs.components.sliders as Sliders
import qs.config
import qs.services
import "Osd.model.js" as Model

import Quickshell
import Quickshell.Wayland
import QtQuick

PanelWindow {
    id: root

    property ShellScreen _targetScreen: null
    property var _previous: ({})
    property var _presentation: null
    property string _kind: ""
    property bool _shown: false

    readonly property var _output: Audio.available
        ? ({ device: Audio.output.id, current: Audio.volume, max: 1, muted: Audio.muted }) : null
    on_OutputChanged: Qt.callLater(_updateOutput)

    function _updateOutput(): void {
        _record("volume", _output);
    }

    function _record(kind: string, reading: var): void {
        const previous = _previous[kind];
        _previous[kind] = reading;
        if (!Model.changed(previous, reading) || !Compositor.focusedScreen)
            return;

        _targetScreen = Compositor.focusedScreen;
        _kind = kind;
        _presentation = Model.presentation(kind, reading);
        _shown = true;
        timeout.restart();
    }

    Component.onCompleted: {
        _updateOutput();
        _record("display", Brightness.display);
        _record("keyboard", Brightness.keyboard);
    }

    Connections {
        target: Brightness
        function onDisplayChanged(): void { root._record("display", Brightness.display); }
        function onKeyboardChanged(): void { root._record("keyboard", Brightness.keyboard); }
    }

    screen: _targetScreen
    visible: _targetScreen !== null && (_shown || pill.opacity > 0)
    anchors { top: true; right: true }
    margins.top: Sizing.barHeight + Sizing.popupGap
    margins.right: Sizing.barSideMargin
    implicitWidth: Math.max(1, Math.min(Sizing.osdWidth,
        (_targetScreen?.width ?? 0) - 2 * Sizing.barSideMargin))
    implicitHeight: Sizing.sliderHeight + 2 * Sizing.pillHorizontalPadding
    exclusionMode: ExclusionMode.Ignore
    color: Theme.transparent
    mask: Region {}
    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.keyboardFocus: WlrKeyboardFocus.None
    WlrLayershell.namespace: "mshell-osd"

    Timer {
        id: timeout

        interval: Motion.osdTimeout
        onTriggered: root._shown = false
    }

    Components.Surface {
        id: pill

        width: parent.width
        height: parent.height
        radius: Shape.full
        opacity: root._shown ? 1 : 0

        transform: Translate {
            y: root._shown || pill.opacity > 0 ? 0 : -Motion.popupSlideDistance

            Behavior on y {
                enabled: root._shown
                SpringAnimation {
                    spring: Motion.spatialFast.spring
                    damping: Motion.spatialFast.damping
                    mass: Motion.spatialFast.mass
                }
            }
        }

        Behavior on opacity {
            NumberAnimation {
                duration: root._shown ? Motion.short2 : Motion.short3
                easing.type: Easing.BezierSpline
                easing.bezierCurve: root._shown ? Motion.standardDecelerate : Motion.standardAccelerate
            }
        }

        Sliders.ValueSlider {
            id: slider

            anchors.left: parent.left
            anchors.right: parent.right
            anchors.leftMargin: Sizing.pillHorizontalPadding
            anchors.rightMargin: Sizing.pillHorizontalPadding + (showStops ? glyph.width + Sizing.pillGap : 0)
            anchors.verticalCenter: parent.verticalCenter
            accessibleName: root._kind === "keyboard" ? qsTr("Keyboard backlight")
                          : root._kind === "display" ? qsTr("Display brightness") : qsTr("Volume")
            interactive: false
            showStops: root._presentation?.discrete ?? false
            value: root._presentation?.value ?? 0
            maximumValue: root._presentation?.maximum ?? 1
            stepSize: showStops ? 1 : 0
            icon: showStops ? "" : (root._presentation?.icon ?? "")
        }

        Components.Icon {
            id: glyph

            anchors.right: parent.right
            anchors.rightMargin: Sizing.pillHorizontalPadding
            anchors.verticalCenter: parent.verticalCenter
            visible: slider.showStops
            name: visible ? root._presentation.icon : ""
            size: Sizing.smallIconSize
            color: Theme.onSurfaceVariant
        }
    }
}
