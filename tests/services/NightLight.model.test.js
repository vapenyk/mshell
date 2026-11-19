const assert = require("node:assert/strict");
const test = require("node:test");
const { loadModel } = require("../load.js");

const { statusFromReply } = loadModel("services/NightLight.model.js");

test("maps the identity matrix to the off state", () => {
    assert.equal(statusFromReply(0, "true\n"), "off");
    assert.equal(statusFromReply(0, "false\n"), "on");
});

test("distinguishes a missing backend from an unrecognized or failed command", () => {
    assert.equal(statusFromReply(3, ""), "stopped");
    assert.equal(statusFromReply(0, "invalid command"), "unavailable");
    assert.equal(statusFromReply(1, "false"), "unavailable");
});
