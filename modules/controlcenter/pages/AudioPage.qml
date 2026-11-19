pragma ComponentBehavior: Bound

import qs.components as Components
import qs.config
import qs.services

import Quickshell
import Quickshell.Services.Pipewire as Native
import QtQuick as QQ
import QtQuick.Controls as QQC
import QtQuick.Layouts as QQL

QQL.ColumnLayout {
    id: root

    readonly property string title: qsTr("Audio")
    readonly property QQ.Component headerAction: Components.IconButton {
        iconName: "settings"
        text: qsTr("Settings")
        enabled: false
    }

    spacing: Sizing.popupGap

    QQ.Binding {
        target: Audio
        property: "mixerOpen"
        value: true
        when: root.QQC.StackView.status === QQC.StackView.Active
    }

    SectionLabel {
        text: qsTr("Output")
    }

    QQ.Repeater {
        model: ScriptModel {
            values: Audio.outputs
        }

        delegate: ConnectionRow {
            required property Native.PwNode modelData
            readonly property bool current: Audio.output === modelData

            QQL.Layout.fillWidth: true
            QQ.Accessible.name: current ? qsTr("%1, current output").arg(text)
                : qsTr("Use %1 for output").arg(text)
            connected: current
            iconName: "speaker"
            trailingIcon: current ? "check" : "chevron_right"
            text: Audio.deviceName(modelData)
            subtitle: current ? qsTr("Current output") : qsTr("Available output")
            onClicked: Audio.setOutput(modelData)
        }
    }

    Components.ValueSlider {
        QQL.Layout.fillWidth: true
        enabled: Audio.available
        accessibleName: qsTr("Output volume")
        value: Audio.volume
        icon: Audio.muted ? "volume_off" : "music_note"
        onMoved: value => Audio.setVolume(value)
    }

    SectionLabel {
        visible: Audio.sourceAvailable
        text: qsTr("Input")
    }

    ConnectionRow {
        QQL.Layout.fillWidth: true
        visible: Audio.sourceAvailable
        QQ.Accessible.name: Audio.sourceMuted ? qsTr("Unmute %1").arg(text) : qsTr("Mute %1").arg(text)
        text: Audio.deviceName(Audio.input)
        subtitle: Audio.sourceMuted ? qsTr("Microphone muted") : qsTr("Current microphone")
        iconName: Audio.sourceMuted ? "mic_off" : "mic"
        trailingIcon: Audio.sourceMuted ? "mic" : "mic_off"
        onClicked: Audio.toggleSourceMute()
    }

    SectionLabel {
        visible: Audio.streams.length > 0
        text: qsTr("Applications")
    }

    QQ.Repeater {
        model: ScriptModel {
            values: Audio.streams
        }

        delegate: QQL.ColumnLayout {
            id: stream

            required property Native.PwNode modelData
            readonly property string applicationName: Audio.streamName(modelData)

            QQL.Layout.fillWidth: true
            spacing: Sizing.pillGap

            Components.Text {
                QQL.Layout.fillWidth: true
                role: "labelLarge"
                text: stream.applicationName
            }

            Components.ValueSlider {
                QQL.Layout.fillWidth: true
                accessibleName: qsTr("%1 volume").arg(stream.applicationName)
                enabled: stream.modelData.ready && stream.modelData.audio !== null
                value: stream.modelData.audio?.volume ?? 0
                icon: stream.modelData.audio?.muted ? "volume_off" : "music_note"
                onMoved: value => Audio.setStreamVolume(stream.modelData, value)
            }
        }
    }

    component SectionLabel: Components.Text {
        QQL.Layout.fillWidth: true
        QQL.Layout.topMargin: Sizing.popupGap
        role: "titleMedium"
    }
}
