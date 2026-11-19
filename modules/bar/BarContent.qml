import qs.config
import "pills"

import Quickshell
import QtQuick

Item {
    id: root

    property ShellScreen screen: null
    readonly property alias statusAnchor: statusPill
    implicitHeight: Sizing.barHeight

    function containsAction(position: point): bool {
        return [clockPill, statusPill, notifPill, keyboardPill].some(
            pill => pill.visible && pill.contains(pill.mapFromItem(root, position)));
    }

    ClockPill {
        id: clockPill

        anchors {
            left: parent.left
            leftMargin: Sizing.barSideMargin
            verticalCenter: parent.verticalCenter
        }
        sizeClass: Theme.sizeClass(root.screen)
    }

    StatusPill {
        id: statusPill

        anchors {
            right: parent.right
            rightMargin: Sizing.barSideMargin
            verticalCenter: parent.verticalCenter
        }
    }

    NotifPill {
        id: notifPill

        anchors {
            right: statusPill.left
            rightMargin: Sizing.pillGap
            verticalCenter: parent.verticalCenter
        }
    }

    KeyboardPill {
        id: keyboardPill

        anchors {
            right: notifPill.left
            rightMargin: Sizing.pillGap
            verticalCenter: parent.verticalCenter
        }
    }
}
