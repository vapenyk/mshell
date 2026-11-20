const assert = require("node:assert/strict");
const test = require("node:test");
const { loadModel } = require("../load.js");

const { nodesOfType, deviceName, streamName, volumeStep } = loadModel("services/Audio.model.js");

test("lists audio outputs and playback streams separately", () => {
    const sink = { type: 1 };
    const duplex = { type: 2 };
    const playback = { type: 3 };
    const capture = { type: 4 };
    const nodes = [sink, playback, duplex, capture];

    assert.deepEqual(nodesOfType(nodes, 1, 2), [sink, duplex]);
    assert.deepEqual(nodesOfType(nodes, 3), [playback]);
    assert.deepEqual(nodesOfType([], 1, 2), []);
});

test("uses readable device and application names with safe fallbacks", () => {
    assert.equal(deviceName({ description: "Headphones", name: "node" }), "Headphones");
    assert.equal(deviceName({ nickname: "Speakers" }), "Speakers");
    assert.equal(deviceName(null), "");
    assert.equal(streamName({ properties: { "application.name": "Browser" }, name: "playback" }), "Browser");
    assert.equal(streamName({ name: "playback" }), "playback");
});

test("steps output volume by two points and clears mute on volume up", () => {
    const up = volumeStep(0.4, true, 1);
    assert.ok(Math.abs(up.volume - 0.42) < Number.EPSILON);
    assert.equal(up.muted, false);
    assert.deepEqual({ ...volumeStep(0.4, true, -1) }, { volume: 0.38, muted: true });
    assert.deepEqual({ ...volumeStep(0.99, false, 1) }, { volume: 1, muted: false });
    assert.deepEqual({ ...volumeStep(0.01, false, -1) }, { volume: 0, muted: false });
});
