const assert = require("node:assert/strict");
const test = require("node:test");
const { loadModel } = require("../load.js");

const { mainKeyboard, layoutNames, configuredLayouts } = loadModel("services/Keyboard.model.js");

const names = layoutNames(`
! model
  pc105           Generic 105-key PC
! layout
  us              English (US)
  ru              Russian
  ua              Ukrainian
! variant
  intl            us: English (US, intl., with dead keys)
  phonetic        ru: Russian (phonetic)
! option
  grp:alt_shift_toggle  Alt+Shift
`);

test("selects the main keyboard and retains Hyprland's current index", () => {
    const keyboard = mainKeyboard(JSON.stringify({ keyboards: [
        { name: "power-button", main: false },
        { name: "physical-keyboard", main: true, layout: "us,ru,ua", active_layout_index: 1 },
    ] }));
    assert.equal(keyboard.name, "physical-keyboard");
    const layouts = configuredLayouts(keyboard, names);
    assert.equal(layouts[1].index, keyboard.active_layout_index);
    assert.equal(layouts[1].code, "RU");
    assert.equal(layouts[2].label, "Ukrainian");
});

test("variants with the same layout code retain distinct names and indices", () => {
    const layouts = configuredLayouts({ layout: "us, us, ru", variant: ",intl,phonetic" }, names);
    assert.equal(layouts[0].label, "English (US)");
    assert.equal(layouts[1].label, "English (US, intl., with dead keys)");
    assert.equal(layouts[1].index, 1);
    assert.equal(layouts[2].label, "Russian (phonetic)");
});

test("missing metadata and unavailable keyboards degrade to codes or an empty list", () => {
    assert.equal(mainKeyboard("not-json"), null);
    assert.equal(mainKeyboard('{"keyboards":[]}'), null);
    assert.equal(configuredLayouts(null, names).length, 0);
    assert.equal(configuredLayouts({ layout: "us" }, {})[0].label, "US");
    assert.equal(configuredLayouts({ layout: "us,ru", variant: "phonetic" }, names)[1].label, "Russian (phonetic)");
});
