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
    property real _previousHeight: 0
    property bool _animateHeight: false
    readonly property bool _shrinking: header.height + _pageHeight < _previousHeight
    property bool _popPending: false
    property real viewportHeight: header.height + _pageHeight
    // Keep the window large enough for both pages while the visible panel animates.
    implicitHeight: stack.busy || heightAnimation.running
        ? Math.max(_previousHeight, header.height + _pageHeight) : viewportHeight
    clip: true
    focus: true

    QQ.Behavior on viewportHeight {
        enabled: root._animateHeight
        QQ.SequentialAnimation {
            id: heightAnimation
            QQ.PauseAnimation { duration: root._shrinking ? root._exitDuration : 0 }
            QQ.NumberAnimation {
                duration: root._shrinking ? root._enterDuration : Motion.medium2
                easing.type: QQ.Easing.BezierSpline
                easing.bezierCurve: Motion.emphasized
            }

            onRunningChanged: {
                if (!running && !stack.busy)
                    root._animateHeight = false;
            }
        }
    }

    function push(page: Component, props: var): void {
        if (depth === 1 && !stack.busy) {
            _previousHeight = viewportHeight;
            _animateHeight = true;
            stack.pushItem(page, props ?? {}, QQC.StackView.PushTransition);
        }
    }

    function pop(): bool {
        if (depth <= 1)
            return false;
        if (stack.busy) {
            _popPending = true;
        } else {
            _previousHeight = viewportHeight;
            _animateHeight = true;
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
        // StackView skips the push transition when the viewport is empty.
        height: Math.max(1, parent.height - header.height)
        clip: true
        focus: true
        initialItem: root.initialPage
        pushEnter: PageTransition { entering: true; offset: Motion.sharedAxisDistance }
        pushExit: PageTransition { entering: false; offset: -Motion.sharedAxisDistance }
        popEnter: PageTransition { entering: true; offset: -Motion.sharedAxisDistance }
        popExit: PageTransition { entering: false; offset: Motion.sharedAxisDistance }

        onBusyChanged: {
            if (!busy && !heightAnimation.running)
                root._animateHeight = false;
            if (!busy && root._popPending) {
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
