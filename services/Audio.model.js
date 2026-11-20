.pragma library

function nodesOfType(nodes, type, alternate = type) {
    return Array.from(nodes).filter(node => node.type === type || node.type === alternate);
}

function deviceName(node) {
    return node?.description || node?.nickname || node?.name || "";
}

function streamName(node) {
    return node?.properties?.["application.name"] || deviceName(node);
}

function volumeStep(volume, muted, direction) {
    return {
        volume: Math.max(0, Math.min(1, volume + direction * 0.02)),
        muted: muted && direction < 0,
    };
}
