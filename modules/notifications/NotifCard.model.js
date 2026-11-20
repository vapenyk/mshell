.pragma library

function webLink(body) {
    const candidates = body.match(/\bhttps?:\/\/[^\s<>"'\\\x00-\x1f]+/gi) ?? [];
    const webUrl = /^https?:\/\/(?:\[[\da-f:.]+\]|[a-z\d](?:[a-z\d.-]*[a-z\d])?)(?::\d+)?(?:[/?#].*)?$/i;

    for (const candidate of candidates) {
        let link = candidate.replace(/[.,;!?]+$/, "");
        const excess = (link.match(/\)/g) ?? []).length - (link.match(/\(/g) ?? []).length;
        const trailing = link.match(/\)+$/)?.[0].length ?? 0;
        if (excess > 0 && trailing > 0)
            link = link.slice(0, -Math.min(excess, trailing));
        if (webUrl.test(link))
            return link;
    }
    return "";
}

function webHost(link) {
    return /^https?:\/\/([^/?#]+)/i.exec(link)?.[1] ?? "";
}

function conversationAvatar(category, width, height) {
    return (category === "im" || category === "im.received") && width > 0 && width === height;
}
