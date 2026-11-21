pragma ComponentBehavior: Bound

import qs.config

import QtQml
import QtQuick as QQ
import QtQuick.Controls as QQC

QQ.FocusScope {
    id: root
    required property Component initialPage
    readonly property int depth: stack.depth
    signal rootEscapePressed(event: var)
    readonly property int _exitDuration: Math.round(Motion.medium2 * Motion.sharedAxisFadeOutFraction)
    readonly property int _enterDuration: Motion.medium2 - _exitDuration
    readonly property real _pageHeight: stack.currentItem?.implicitHeight ?? 0
    readonly property real _wantedHeight: header.height + _pageHeight
    property real _targetHeight: 0
    property bool _transitioning: false
    property bool _ready: false
    property bool _popPending: false

    // Visible height of the stack. It follows the current page's height, so
    // late changes (lists filling in after the transition) animate instead of jumping.
    // The popup window must not depend on this value: it keeps its own fixed size.
    property real viewportHeight: 0
    readonly property real _timeConstant: Motion.medium2 / 4000
    implicitHeight: viewportHeight
    clip: true
    focus: true

    on_TargetHeightChanged: {
        if (!_ready)
            viewportHeight = _targetHeight;
    }

    // Exponential approach to the target. Changing the target while it runs only moves
    // the goal, so rows arriving mid-animation do not restart the motion. It settles in
    // about Motion.medium2 and stops running once it has arrived.
    QQ.FrameAnimation {
        running: root._ready && root.viewportHeight !== root._targetHeight
        onTriggered: {
            const distance = root._targetHeight - root.viewportHeight;
            root.viewportHeight = Math.abs(distance) < 0.5 ? root._targetHeight
                : root.viewportHeight + distance * (1 - Math.exp(-frameTime / root._timeConstant));
        }
    }

    on_WantedHeightChanged: _retarget()

    Component.onCompleted: {
        _targetHeight = _wantedHeight;
        Qt.callLater(() => { root._ready = true; });
    }

    // Growing starts at once. Shrinking during a page transition waits until the
    // outgoing page has faded out, so its content is not clipped while visible.
    function _retarget(): void {
        if (_wantedHeight < _targetHeight && _transitioning) {
            shrinkDelay.restart();
        } else {
            shrinkDelay.stop();
            _targetHeight = _wantedHeight;
        }
    }

    function push(page: Component, props: var): void {
        if (depth === 1 && !stack.busy) {
            _transitioning = true;
            stack.pushItem(page, props ?? {}, QQC.StackView.PushTransition);
        }
    }

    function pop(): bool {
        if (depth <= 1)
            return false;
        if (stack.busy) {
            _popPending = true;
        } else {
            _transitioning = true;
            stack.popCurrentItem(QQC.StackView.PopTransition);
        }
        return true;
    }

    QQ.Keys.onEscapePressed: event => {
        event.accepted = root.pop();
        if (!event.accepted)
            root.rootEscapePressed(event);
    }
    QQ.Keys.onPressed: event => {
        if (event.key === Qt.Key_Backspace) {
            const focusedItem = root.QQ.Window.window?.activeFocusItem;
            if (!(focusedItem instanceof QQ.TextInput) && !(focusedItem instanceof QQ.TextEdit))
                event.accepted = root.pop();
        }
    }

    QQ.TapHandler {
        acceptedButtons: Qt.BackButton
        onTapped: root.pop()
    }

    QQ.Timer {
        id: shrinkDelay

        interval: root._exitDuration
        onTriggered: root._targetHeight = root._wantedHeight
    }

    QQ.Item {
        id: header
        width: root.width
        height: Math.max(Sizing.pillHeight, action.implicitHeight, customHeader.implicitHeight)
        readonly property real sideSpace: Math.min(width / 2, Math.max(
            backButton.visible ? backButton.width + Sizing.pillGap : 0,
            action.visible ? action.width + Sizing.pillGap : 0))

        Pill {
            id: backButton
            anchors.left: parent.left
            anchors.verticalCenter: parent.verticalCenter
            visible: root.depth > 1
            icon: "arrow_back"
            onClicked: root.pop()
            QQ.Accessible.name: qsTr("Back")
        }

        Text {
            anchors {
                left: parent.left
                right: parent.right
                leftMargin: header.sideSpace
                rightMargin: header.sideSpace
                verticalCenter: parent.verticalCenter
            }
            visible: !customHeader.item
            text: stack.currentItem?.title ?? ""
            role: "titleLarge"
            horizontalAlignment: QQ.Text.AlignHCenter
        }

        QQ.Loader {
            id: customHeader
            width: parent.width
            anchors.verticalCenter: parent.verticalCenter
            sourceComponent: stack.currentItem?.headerContent ?? null
        }

        QQ.Loader {
            id: action
            anchors.right: parent.right
            anchors.verticalCenter: parent.verticalCenter
            sourceComponent: customHeader.item ? null : stack.currentItem?.headerAction ?? null
            visible: item !== null
        }
    }

    QQC.StackView {
        id: stack
        anchors {
            top: header.bottom
            left: parent.left
            right: parent.right
        }
        // Tall enough for the current page and for the visible area, so pages keep
        // their natural size while the panel animates. StackView skips the push
        // transition when its viewport is empty, hence the minimum of 1.
        height: Math.max(1, root._pageHeight, root.viewportHeight - header.height)
        clip: true
        focus: true
        initialItem: root.initialPage
        pushEnter: PageTransition { entering: true; offset: Motion.sharedAxisDistance }
        pushExit: PageTransition { entering: false; offset: -Motion.sharedAxisDistance }
        popEnter: PageTransition { entering: true; offset: -Motion.sharedAxisDistance }
        popExit: PageTransition { entering: false; offset: Motion.sharedAxisDistance }

        onBusyChanged: {
            if (busy)
                return;
            root._transitioning = false;
            if (root._popPending) {
                root._popPending = false;
                Qt.callLater(root.pop);
            }
        }
    }
    component PageTransition: QQ.Transition {
        id: pageTransition
        required property bool entering
        required property real offset
        readonly property int duration: entering ? root._enterDuration : root._exitDuration

        QQ.SequentialAnimation {
            QQ.PropertyAction {
                property: "x"
                value: pageTransition.entering ? pageTransition.offset : 0
            }
            QQ.PropertyAction {
                property: "opacity"
                value: pageTransition.entering ? 0 : 1
            }
            QQ.PauseAnimation { duration: pageTransition.entering ? root._exitDuration : 0 }
            QQ.ParallelAnimation {
                QQ.NumberAnimation {
                    property: "x"
                    from: pageTransition.entering ? pageTransition.offset : 0
                    to: pageTransition.entering ? 0 : pageTransition.offset
                    duration: pageTransition.duration
                    easing.type: QQ.Easing.BezierSpline
                    easing.bezierCurve: Motion.emphasized
                }
                QQ.NumberAnimation {
                    property: "opacity"
                    from: pageTransition.entering ? 0 : 1
                    to: pageTransition.entering ? 1 : 0
                    duration: pageTransition.duration
                    easing.type: QQ.Easing.BezierSpline
                    easing.bezierCurve: Motion.emphasized
                }
            }
        }
    }
}
