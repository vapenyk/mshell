pragma ComponentBehavior: Bound

import qs.config
import qs.services

import Quickshell
import QtQuick

Item {
    id: root

    required property QtObject toast
    signal exited()

    property double _startedAt: 0
    property int _remaining: toast.timeout

    implicitHeight: card.implicitHeight
    opacity: 0
    enabled: !toast.leaving

    function _syncTimer(): void {
        if (hover.hovered || toast.leaving || toast.timeout === 0) {
            if (expiry.running) {
                _remaining = Math.max(1, _remaining - (Date.now() - _startedAt));
                expiry.stop();
            }
        } else if (!expiry.running) {
            expiry.interval = _remaining;
            _startedAt = Date.now();
            expiry.start();
        }
    }

    Component.onCompleted: {
        enter.start();
        _syncTimer();
    }

    Connections {
        target: root.toast

        function onLeavingChanged(): void {
            if (root.toast.leaving) {
                enter.stop();
                exit.start();
                root._syncTimer();
            }
        }

        function onTimeoutChanged(): void {
            expiry.stop();
            root._remaining = root.toast.timeout;
            root._syncTimer();
        }
    }

    RetainableLock {
        object: root.toast.notification
        locked: true
    }

    NotifCard {
        id: card

        anchors.fill: parent
        notification: root.toast.notification
        arrivedAt: root.toast.arrivedAt
        onDismissRequested: Notifs.dismiss(root.toast.entry)
        onActionRequested: action => {
            root.toast.leaving = true;
            Notifs.invoke(action);
        }
    }

    HoverHandler {
        id: hover
        onHoveredChanged: root._syncTimer()
    }

    Timer {
        id: expiry
        onTriggered: root.toast.leaving = true
    }

    transform: Translate {
        id: slide
        y: -Motion.popupSlideDistance
    }

    ParallelAnimation {
        id: enter

        SpringAnimation {
            target: slide
            property: "y"
            to: 0
            spring: Motion.spatialDefault.spring
            damping: Motion.spatialDefault.damping
            mass: Motion.spatialDefault.mass
        }

        NumberAnimation {
            target: root
            property: "opacity"
            to: 1
            duration: Motion.short4
        }
    }

    ParallelAnimation {
        id: exit

        NumberAnimation {
            target: slide
            property: "y"
            to: -Motion.popupSlideDistance
            duration: Motion.short4
            easing.type: Easing.BezierSpline
            easing.bezierCurve: Motion.standardAccelerate
        }

        NumberAnimation {
            target: root
            property: "opacity"
            to: 0
            duration: Motion.short4
        }

        onFinished: root.exited()
    }
}
