const assert = require("node:assert/strict");
const test = require("node:test");
const { loadModel } = require("../load.js");
const accents = require("../../config/accents.json");

const { pickScheme, sizeClass } = loadModel("config/Theme.model.js");

test("pickScheme selects each configured accent", () => {
    for (const [name, scheme] of Object.entries(accents))
        assert.equal(pickScheme(accents, name), scheme, name);
});

test("pickScheme falls back to blue for unknown accents", () => {
    for (const name of ["unknown", "", "constructor", "__proto__"])
        assert.equal(pickScheme(accents, name), accents.blue, name);
});

test("each accent has every color role", () => {
    const roles = [
        "primary", "onPrimary", "primaryContainer", "onPrimaryContainer",
        "secondary", "onSecondary", "secondaryContainer", "onSecondaryContainer",
        "tertiary", "onTertiary", "tertiaryContainer", "onTertiaryContainer",
        "error", "onError", "errorContainer", "onErrorContainer",
        "background", "onBackground", "surface", "onSurface",
        "surfaceVariant", "onSurfaceVariant", "surfaceDim", "surfaceBright",
        "surfaceContainerLowest", "surfaceContainerLow", "surfaceContainer",
        "surfaceContainerHigh", "surfaceContainerHighest", "outline", "outlineVariant",
        "inverseSurface", "inverseOnSurface", "inversePrimary", "shadow", "scrim", "surfaceTint",
    ];

    for (const name of Object.keys(accents)) {
        const scheme = pickScheme(accents, name);
        for (const role of roles)
            assert.match(scheme[role], /^#[0-9a-f]{6}$/i, `${name}.${role}`);
    }
});

test("sizeClass switches at each logical width boundary", () => {
    const widths = [
        [599, "compact"],
        [600, "medium"],
        [839, "medium"],
        [840, "expanded"],
        [1199, "expanded"],
        [1200, "large"],
        [1599, "large"],
        [1600, "extraLarge"],
    ];

    for (const [width, expected] of widths)
        assert.equal(sizeClass(width), expected, `${width} dp`);
});
