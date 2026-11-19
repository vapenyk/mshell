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
    property real _previousPageHeight: 0
    property bool _popPending: false

    implicitHeight: header.height + (stack.busy ? Math.max(_previousPageHeight, _pageHeight) : _pageHeight)
    clip: true
    focus: true

    // Pages provide a title, their implicit content height, and an optional headerAction or headerContent component.
    function push(page: Component, props: var): void {
        if (depth === 1 && !stack.busy) {
            _previousPageHeight = _pageHeight;
            stack.pushItem(page, props ?? {}, QQC.StackView.PushTransition);
        }
    }

    function pop(): bool {
        if (depth <= 1)
            return false;
        if (stack.busy) {
            _popPending = true;
        } else {
            _previousPageHeight = _pageHeight;
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
            activeFocusOnTab: true
            QQ.Keys.onReturnPressed: root.pop()
            QQ.Keys.onSpacePressed: root.pop()
            QQ.Accessible.role: QQ.Accessible.Button
            QQ.Accessible.name: qsTr("Back")
            QQ.Accessible.onPressAction: root.pop()
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
        pushEnter: PageEnter { offset: Motion.sharedAxisDistance }
        pushExit: PageExit { offset: -Motion.sharedAxisDistance }
        popEnter: PageEnter { offset: -Motion.sharedAxisDistance }
        popExit: PageExit { offset: Motion.sharedAxisDistance }

        onBusyChanged: {
            if (!busy && root._popPending) {
                root._popPending = false;
                Qt.callLater(root.pop);
            }
        }
    }

    component PageEnter: QQ.Transition {
        id: enter

        required property real offset

        QQ.SequentialAnimation {
            QQ.PropertyAction { property: "x"; value: enter.offset }
            QQ.PropertyAction { property: "opacity"; value: 0 }
            QQ.PauseAnimation { duration: root._exitDuration }
            QQ.ParallelAnimation {
                QQ.NumberAnimation {
                    property: "x"
                    from: enter.offset
                    to: 0
                    duration: root._enterDuration
                    easing.type: QQ.Easing.BezierSpline
                    easing.bezierCurve: Motion.emphasized
                }
                QQ.NumberAnimation {
                    property: "opacity"
                    from: 0
                    to: 1
                    duration: root._enterDuration
                    easing.type: QQ.Easing.BezierSpline
                    easing.bezierCurve: Motion.emphasized
                }
            }
        }
    }

    component PageExit: QQ.Transition {
        id: exit

        required property real offset

        QQ.NumberAnimation {
            property: "x"
            from: 0
            to: exit.offset
            duration: root._exitDuration
            easing.type: QQ.Easing.BezierSpline
            easing.bezierCurve: Motion.emphasized
        }
        QQ.NumberAnimation {
            property: "opacity"
            from: 1
            to: 0
            duration: root._exitDuration
            easing.type: QQ.Easing.BezierSpline
            easing.bezierCurve: Motion.emphasized
        }
    }
}
