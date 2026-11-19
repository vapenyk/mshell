.pragma library

function mainKeyboard(text) {
    try {
        var keyboards = JSON.parse(text)?.keyboards;
        return Array.isArray(keyboards) ? keyboards.find(function(keyboard) {
            return keyboard?.main && keyboard.name;
        }) ?? null : null;
    } catch (error) {
        return null;
    }
}

function layoutNames(text) {
    var names = {};
    var section = "";
    for (var line of text.split("\n")) {
        var header = /^!\s+(\w+)/.exec(line);
        if (header) {
            section = header[1];
        } else if (section === "layout") {
            var layout = /^\s+(\S+)\s+(.+)$/.exec(line);
            if (layout)
                names[layout[1]] = layout[2].trim();
        } else if (section === "variant") {
            var variant = /^\s+(\S+)\s+(\S+):\s+(.+)$/.exec(line);
            if (variant)
                names[variant[2] + ":" + variant[1]] = variant[3].trim();
        }
    }
    return names;
}

function configuredLayouts(keyboard, names) {
    var codes = (keyboard?.layout ?? "").split(",");
    var variants = (keyboard?.variant ?? "").split(",");
    var layouts = [];
    for (var index = 0; index < codes.length; index++) {
        var code = codes[index].trim();
        if (!code)
            continue;
        var variant = (variants.length === 1 ? variants[0] : variants[index] ?? "").trim();
        var label = names[code] ?? code.toUpperCase();
        if (variant)
            label = names[code + ":" + variant] ?? label + " (" + variant + ")";
        layouts.push({ index: index, code: code.toUpperCase(), label: label });
    }
    return layouts;
}
