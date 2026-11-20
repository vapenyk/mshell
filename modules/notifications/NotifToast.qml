pragma ComponentBehavior: Bound

import "NotifPopup.model.js" as Model

import qs.config
import qs.services

import Quickshell
import QtQuick

Item {
    id: root

    required property QtObject toast
    signal exited()
    readonly property bool replying: card.replying && !toast.leaving
    readonly property Region inputRegion: Region {
        item: root.toast.leaving ? null : root
    }
    readonly property bool _paused: hover.hovered || card.expanded || toast.leaving

    property double _startedAt: 0
    property int _remaining: toast.timeout

    implicitHeight: card.implicitHeight
    opacity: 0
    enabled: !toast.leaving

    function stopReply(): void {
        card.stopReply();
    }

    function _syncTimer(): void {
        if (_paused || toast.timeout === 0) {
            if (expiry.running) {
                _remaining = Model.remainingAfterPause(_remaining, _startedAt, Date.now());
                expiry.stop();
            }
        } else if (!expiry.running) {
            expiry.interval = _remaining;
            _startedAt = Date.now();
            expiry.start();
        }
    }

    function _restartTimer(): void {
        expiry.stop();
        _remaining = toast.timeout;
        _syncTimer();
    }

    on_PausedChanged: _syncTimer()

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
            }
        }

        function onTimeoutChanged(): void { root._restartTimer(); }
        function onRefreshed(): void { root._restartTimer(); }
    }

    RetainableLock {
        object: root.toast.notification
        locked: true
    }

    NotifCard {
        id: card

        anchors.fill: parent
        notification: root.toast.notification
        entry: root.toast.entry
        arrivedAt: root.toast.arrivedAt
        onDismissRequested: Notifs.dismiss(root.toast.entry)
        onActionRequested: action => {
            root.toast.leaving = true;
            Notifs.invoke(action);
        }
    }

    HoverHandler {
        id: hover
    }

    Timer {
        id: expiry
        onTriggered: root.toast.leaving = true
    }

    transform: Translate {
        id: slide
        y: -Motion.popupSlideDistance
        onYChanged: root.inputRegion?.changed()
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
