import qs.components as Components
import qs.components.sliders as Sliders
import qs.config
import qs.services
import "Osd.model.js" as Model

import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import QtQuick

PanelWindow {
    id: root

    property ShellScreen _targetScreen: null
    property string _kind: ""
    property bool _shown: false

    readonly property bool _suppressed: UiState.openPopup === "controlcenter" || UiState.lockActive
    readonly property var _reading: _kind === "display" ? Brightness.display
        : _kind === "keyboard" ? Brightness.keyboard
        : _kind === "volume" && Audio.available ? ({ current: Audio.volume, max: 1, muted: Audio.muted }) : null
    readonly property var _presentation: Model.presentation(_kind, _reading)

    on_SuppressedChanged: {
        if (_suppressed)
            _close();
    }
    on_TargetScreenChanged: {
        if (!_targetScreen)
            _close();
    }
    on_ReadingChanged: {
        if (!_reading && _shown)
            _close();
    }

    function _close(): void {
        timeout.stop();
        _shown = false;
    }

    function _show(kind: string, accepted: bool): void {
        if (!accepted || _suppressed || !Compositor.focusedScreen)
            return;

        _targetScreen = Compositor.focusedScreen;
        _kind = kind;
        _shown = true;
        timeout.restart();
    }

    IpcHandler {
        target: "osd"

        function volumeUp(): void { root._show("volume", Audio.stepVolume(1)); }
        function volumeDown(): void { root._show("volume", Audio.stepVolume(-1)); }
        function toggleMute(): void { root._show("volume", Audio.toggleMute()); }
        function brightnessUp(): void { root._show("display", Brightness.step("display", 1)); }
        function brightnessDown(): void { root._show("display", Brightness.step("display", -1)); }
        function keyboardBrightnessUp(): void { root._show("keyboard", Brightness.step("keyboard", 1)); }
        function keyboardBrightnessDown(): void { root._show("keyboard", Brightness.step("keyboard", -1)); }
    }

    Connections {
        target: AsusKeyboardBacklight
        function onHardwareChanged(): void { root._show("keyboard", Brightness.keyboard !== null); }
    }

    screen: _targetScreen
    visible: !_suppressed && _targetScreen !== null && _reading !== null && (_shown || pill.opacity > 0)
    anchors.bottom: true
    margins.bottom: Sizing.osdBottomMargin
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
            y: root._shown || pill.opacity > 0 ? 0 : Motion.popupSlideDistance

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
            enabled: !root._suppressed && root._targetScreen !== null
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
