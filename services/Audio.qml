pragma Singleton

import "Audio.model.js" as Model

import Quickshell
import Quickshell.Services.Pipewire

Singleton {
    id: root

    readonly property bool available: _sink?.ready === true && _sink.audio !== null
    readonly property real volume: available ? _sink.audio.volume : 0
    readonly property bool muted: available && _sink.audio.muted
    readonly property bool sourceAvailable: _source?.ready === true && _source.audio !== null
    readonly property bool sourceMuted: sourceAvailable && _source.audio.muted

    readonly property PwNode output: _sink
    readonly property PwNode input: _source
    property bool mixerOpen: false
    readonly property var outputs: mixerOpen
        ? Model.nodesOfType(Pipewire.nodes.values, PwNodeType.AudioSink, PwNodeType.AudioDuplex) : []
    readonly property var streams: mixerOpen
        ? Model.nodesOfType(Pipewire.nodes.values, PwNodeType.AudioOutStream) : []

    readonly property PwNode _sink: Pipewire.defaultAudioSink
    readonly property PwNode _source: Pipewire.defaultAudioSource

    function deviceName(node: PwNode): string {
        return Model.deviceName(node);
    }

    function streamName(node: PwNode): string {
        return Model.streamName(node);
    }

    function setOutput(node: PwNode): void {
        if (node && outputs.includes(node) && node !== _sink)
            Pipewire.preferredDefaultAudioSink = node;
    }

    function setStreamVolume(node: PwNode, value: real): void {
        if (node?.ready && node.audio && streams.includes(node))
            node.audio.volume = value;
    }

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
        objects: [root._sink, root._source, ...root.streams]
    }
}
