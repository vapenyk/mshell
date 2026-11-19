pragma ComponentBehavior: Bound

import qs.components as Components
import qs.config
import qs.services
import "../../utils/Format.js" as Format

import Quickshell.Wayland
import QtQml
import QtQuick as QQ
import QtQuick.Effects as Effects

WlSessionLockSurface {
    id: root

    required property Component barContent
    required property url backgroundSource
    required property bool ready
    required property bool authenticating
    required property string errorMessage
    required property int failures

    signal unlockRequested(password: string)

    color: Theme.surface
    onFailuresChanged: {
        if (failures > 0)
            shake.restart();
    }

    QQ.FocusScope {
        id: scene

        anchors.fill: parent
        focus: true

        QQ.NumberAnimation on opacity {
            from: 0
            to: 1
            duration: Motion.short4
            easing.type: QQ.Easing.BezierSpline
            easing.bezierCurve: Motion.standard
        }

        QQ.Rectangle {
            anchors.fill: parent
            gradient: QQ.Gradient {
                QQ.GradientStop { position: 0; color: Theme.surfaceContainer }
                QQ.GradientStop { position: 1; color: Theme.surface }
            }
        }

        QQ.Image {
            id: wallpaper

            anchors.fill: parent
            source: root.backgroundSource
            sourceSize.width: Sizing.lockBackgroundImageWidth
            asynchronous: true
            fillMode: QQ.Image.PreserveAspectCrop
            visible: status === QQ.Image.Ready
            layer.enabled: visible
            layer.effect: Effects.MultiEffect {
                blurEnabled: true
                blur: 1
                blurMax: Sizing.lockBackgroundBlur
                autoPaddingEnabled: false
            }
        }

        QQ.Rectangle {
            anchors.fill: parent
            visible: wallpaper.visible
            color: Theme.scrim
            opacity: Theme.lockWallpaperScrimOpacity
        }

        QQ.Loader {
            id: bar

            width: parent.width
            height: Sizing.barHeight
            enabled: false
            sourceComponent: root.barContent
        }

        Binding {
            target: bar.item
            property: "screen"
            value: root.screen
            when: bar.item !== null
        }

        QQ.MouseArea {
            anchors.fill: bar
            acceptedButtons: Qt.AllButtons
            onPressed: password.forceActiveFocus(Qt.MouseFocusReason)
        }

        QQ.Item {
            id: clockArea

            readonly property string sizeClass: Theme.sizeClass(root.screen)
            readonly property real clockScale: sizeClass === "compact" ? Sizing.lockClockCompactScale
                : sizeClass === "medium" ? Sizing.lockClockMediumScale : 1

            anchors {
                top: bar.bottom
                bottom: credentials.top
                left: parent.left
                right: parent.right
            }

            QQ.Column {
                id: timeColumn

                anchors.centerIn: parent
                anchors.verticalCenterOffset: -Math.min(Sizing.lockClockLift,
                    Math.max(0, (clockArea.height - height) / 2))
                spacing: Sizing.pillGap

                QQ.Repeater {
                    model: Format.clock(Time.date, true).split(":")

                    Components.Text {
                        required property string modelData
                        anchors.horizontalCenter: timeColumn.horizontalCenter
                        text: modelData
                        role: "clockHuge"
                        font.pixelSize: Math.round(Typography.clockHuge.size * clockArea.clockScale)
                        lineHeight: Typography.clockHuge.lineHeight * clockArea.clockScale
                    }
                }

                Components.Text {
                    anchors.horizontalCenter: timeColumn.horizontalCenter
                    text: Format.dateShort(Time.date)
                    role: "titleMedium"
                }
            }
        }

        QQ.Column {
            id: credentials

            width: Math.min(Sizing.lockFieldWidth, parent.width - 2 * Sizing.barSideMargin)
            anchors.bottom: parent.bottom
            anchors.bottomMargin: Sizing.lockFieldBottomMargin
            anchors.horizontalCenter: parent.horizontalCenter
            spacing: Sizing.pillGap
            transform: QQ.Translate { id: shakeOffset }

            Components.TextField {
                id: password

                width: parent.width
                implicitHeight: Sizing.lockFieldHeight
                focus: true
                readOnly: root.authenticating
                placeholderText: qsTr("Password")
                echoMode: QQ.TextInput.Password
                inputMethodHints: Qt.ImhHiddenText | Qt.ImhSensitiveData
                    | Qt.ImhNoPredictiveText | Qt.ImhNoAutoUppercase
                QQ.Accessible.name: qsTr("Password")
                QQ.Keys.onEscapePressed: clear()
                onAccepted: {
                    if (root.ready && !root.authenticating && text.length > 0) {
                        const value = text;
                        clear();
                        root.unlockRequested(value);
                    }
                }
            }

            Components.Text {
                width: parent.width
                height: Typography.bodyMedium.lineHeight
                text: root.authenticating ? qsTr("Checking password…") : root.errorMessage
                horizontalAlignment: QQ.Text.AlignHCenter
                color: root.authenticating ? Theme.onSurfaceVariant : Theme.error
            }
        }
    }

    QQ.SequentialAnimation {
        id: shake

        QQ.NumberAnimation { target: shakeOffset; property: "x"; to: -Sizing.lockShakeDistance; duration: Motion.short1 }
        QQ.NumberAnimation { target: shakeOffset; property: "x"; to: Sizing.lockShakeDistance; duration: Motion.short1 }
        QQ.SpringAnimation {
            target: shakeOffset
            property: "x"
            to: 0
            spring: Motion.spatialFast.spring
            damping: Motion.spatialFast.damping
            mass: Motion.spatialFast.mass
        }
    }
}
