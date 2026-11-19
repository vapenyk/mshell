const assert = require("node:assert/strict");
const test = require("node:test");
const { loadModel } = require("../../load.js");

const { conversationAvatar, webLink } = loadModel("modules/notifications/NotifCard.model.js");

test("extracts the first web link and removes surrounding punctuation", () => {
    assert.equal(webLink("Read (https://example.org/update). Try https://example.com next."), "https://example.org/update");
    assert.equal(webLink("https://example.org/wiki/Topic_(example)"), "https://example.org/wiki/Topic_(example)");
    assert.equal(webLink("http://localhost:8080/report?view=full"), "http://localhost:8080/report?view=full");
});

test("ignores missing, malformed, and non-web links", () => {
    assert.equal(webLink("No links. file:///tmp/report"), "");
    assert.equal(webLink("https:///path https://user@example.org"), "");
});

test("uses square images from instant-message categories as conversation avatars", () => {
    assert.equal(conversationAvatar("im.received", 64, 64), true);
    assert.equal(conversationAvatar("im", 128, 128), true);
    assert.equal(conversationAvatar("im.received", 120, 60), false);
    assert.equal(conversationAvatar("", 64, 64), false);
    assert.equal(conversationAvatar("transfer.complete", 64, 64), false);
    assert.equal(conversationAvatar("im.received", 0, 0), false);
});
