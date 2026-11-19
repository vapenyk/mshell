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
