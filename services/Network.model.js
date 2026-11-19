.pragma library

function deviceOfType(devices, type, connectedOnly = false) {
    return devices.find(device => device.type === type && (!connectedOnly || device.connected)) ?? null;
}

function connectedNetwork(networks) {
    return networks.find(network => network.connected) ?? null;
}

function listNetworks(networks) {
    return Array.from(networks)
        .filter(network => network.name.length > 0)
        .sort((left, right) => Number(right.connected) - Number(left.connected)
            || Number(right.known) - Number(left.known)
            || left.name.localeCompare(right.name));
}

function canConnect(network, openSecurity, oweSecurity) {
    return Boolean(network && (network.known
        || network.security === openSecurity || network.security === oweSecurity));
}

function activateNetwork(network, openSecurity, oweSecurity) {
    if (!network || network.stateChanging)
        return;
    if (network.connected)
        network.disconnect();
    else if (canConnect(network, openSecurity, oweSecurity))
        network.connect();
}
