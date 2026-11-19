const assert = require("node:assert/strict");
const test = require("node:test");
const { loadModel } = require("../load.js");

const { commandFor, requiresConfirmation } = loadModel("services/Power.model.js");

test("restart and power off map to distinct commands and require confirmation", () => {
    assert.deepEqual(Array.from(commandFor("restart")), ["systemctl", "reboot"]);
    assert.deepEqual(Array.from(commandFor("poweroff")), ["systemctl", "poweroff"]);
    assert.equal(requiresConfirmation("restart"), true);
    assert.equal(requiresConfirmation("poweroff"), true);
});

test("sign out prefers the graceful Hyprland tool with a compositor fallback", () => {
    assert.deepEqual(Array.from(commandFor("logout", true)), ["hyprshutdown"]);
    assert.deepEqual(Array.from(commandFor("logout", false)), ["hyprctl", "dispatch", "hl.dsp.exit()"]);
    assert.equal(requiresConfirmation("logout"), false);
});

test("lock and unrecognized actions do not launch external commands", () => {
    assert.equal(commandFor("lock").length, 0);
    assert.equal(commandFor("unknown").length, 0);
});
