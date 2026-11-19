const assert = require("node:assert/strict");
const test = require("node:test");
const { loadModel } = require("../../load.js");

const { webLink } = loadModel("modules/notifications/NotifCard.model.js");

test("extracts the first web link and removes surrounding punctuation", () => {
    assert.equal(webLink("Read (https://example.org/update). Try https://example.com next."), "https://example.org/update");
    assert.equal(webLink("https://example.org/wiki/Topic_(example)"), "https://example.org/wiki/Topic_(example)");
    assert.equal(webLink("http://localhost:8080/report?view=full"), "http://localhost:8080/report?view=full");
});

test("ignores missing, malformed, and non-web links", () => {
    assert.equal(webLink("No links. file:///tmp/report"), "");
    assert.equal(webLink("https:///path https://user@example.org"), "");
});
