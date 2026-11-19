pragma Singleton

import Quickshell
import Quickshell.Services.Pipewire

Singleton {
    id: root

    readonly property bool available: _sink?.ready === true && _sink.audio !== null
    readonly property real volume: available ? _sink.audio.volume : 0
    readonly property bool muted: available && _sink.audio.muted
    readonly property bool sourceAvailable: _source?.ready === true && _source.audio !== null
    readonly property bool sourceMuted: sourceAvailable && _source.audio.muted

    readonly property PwNode _sink: Pipewire.defaultAudioSink
    readonly property PwNode _source: Pipewire.defaultAudioSource

    function setVolume(value: real): void {
        if (available)
            _sink.audio.volume = value;
    }

    function toggleMute(): void {
        if (available)
            _sink.audio.muted = !muted;
    }

    function toggleSourceMute(): void {
        if (sourceAvailable)
            _source.audio.muted = !sourceMuted;
    }

    PwObjectTracker {
        objects: [root._sink, root._source]
    }
}
