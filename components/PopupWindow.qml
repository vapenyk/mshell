import qs.config
import "PopupWindow.model.js" as Model

import Quickshell
import Quickshell.Hyprland
import Quickshell.Wayland

import QtQuick

PanelWindow {
    id: root

    required property Item anchorItem
    required property bool opened
    required property int preferredWidth
    property list<QtObject> barWindows
    property real contentViewportHeight: body.implicitHeight
    property bool waitForContentLayout: false
    property bool centerOnAnchor: false
    default property alias content: body.data

    signal dismissRequested()
    signal exited()

    readonly property QsWindow _anchorWindow: anchorItem?.QsWindow.window ?? null
    readonly property ShellScreen _anchorScreen: _anchorWindow?.screen ?? null
    readonly property bool _shown: _ready && opened && (!waitForContentLayout || _layoutSettled)
    property bool _ready: false
    property bool _layoutSettled: false
    readonly property var _placement: Model.placement(
        _anchorScreen?.width ?? 0, _anchorScreen?.height ?? 0,
        anchorItem?.x ?? 0, anchorItem?.width ?? 0, _anchorWindow?.height ?? Sizing.barHeight,
        preferredWidth, body.implicitHeight + 2 * Sizing.popupInnerPadding,
        Sizing.barSideMargin, Sizing.popupGap, centerOnAnchor)

    screen: _anchorScreen
    visible: _anchorScreen !== null
    anchors {
        left: true
        top: true
    }
    margins.left: _placement.x
    margins.top: _placement.y
    implicitWidth: _placement.width
    implicitHeight: _placement.height
    exclusionMode: ExclusionMode.Ignore
    color: Theme.transparent
    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.keyboardFocus: opened ? WlrKeyboardFocus.OnDemand : WlrKeyboardFocus.None
    WlrLayershell.namespace: "mshell-popup"

    mask: Region {
        item: root._shown ? surface : null
    }

    Component.onCompleted: _ready = true
    onClosed: dismissRequested()
    onOpenedChanged: {
        if (!opened) {
            _layoutSettled = false;
            if (_ready && surface.opacity === 0)
                exited();
        }
    }

    FrameAnimation {
        running: root.waitForContentLayout && root._ready && root.opened && !root._layoutSettled

        onTriggered: {
            // Start the reveal after the window has adopted the content size.
            if (root.contentViewportHeight > 0
                    && root.width === Math.round(root._placement.width)
                    && root.height === Math.round(root._placement.height))
                root._layoutSettled = true;
        }
    }

    HyprlandFocusGrab {
        active: root._shown && root.backingWindowVisible && surface.opacity > 0
        windows: [root, ...root.barWindows]
        onCleared: {
            if (root.opened)
                root.dismissRequested();
        }
    }

    FocusScope {
        anchors.fill: parent
        focus: true
        Keys.onEscapePressed: root.dismissRequested()

        Surface {
            id: surface

            width: parent.width
            height: Math.min(root.height, root.contentViewportHeight + 2 * Sizing.popupInnerPadding)
            container: Theme.surfaceContainer
            radius: Shape.extraLarge
            scale: Motion.enterScale + (1 - Motion.enterScale) * _progress
            y: Motion.popupSlideDistance * (_progress - 1)
            opacity: root._shown ? 1 : 0
            enabled: root.opened

            property real _progress: root._shown ? 1 : 0

            Behavior on _progress {
                SpringAnimation {
                    readonly property var preset: root._shown ? Motion.spatialDefault : Motion.spatialFast
                    spring: preset.spring
                    damping: preset.damping
                    mass: preset.mass
                }
            }

            Behavior on opacity {
                NumberAnimation {
                    duration: root._shown ? Motion.short4 : Motion.short3
                    easing.type: Easing.BezierSpline
                    easing.bezierCurve: root._shown ? Motion.standard : Motion.emphasizedAccelerate
                }
            }

            onOpacityChanged: {
                if (opacity === 0 && !root.opened)
                    root.exited();
            }

            Flickable {
                id: viewport

                anchors.fill: parent
                anchors.margins: Sizing.popupInnerPadding
                contentWidth: width
                contentHeight: root.contentViewportHeight
                clip: true
                interactive: contentHeight > height

                Item {
                    id: body

                    width: viewport.width
                    implicitHeight: childrenRect.height
                    height: implicitHeight
                }
            }
        }
    }
}
