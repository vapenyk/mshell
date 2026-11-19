// Loads a QML-style `.pragma library` JS file and its relative imports into Node.
// Rule for model files: top-level `function` declarations and `var` only
// (no const/let/class/import/export) so they work in both QML and here.
const fs = require("node:fs");
const vm = require("node:vm");
const path = require("node:path");

exports.loadModel = function loadModel(rel) {
  const file = path.join(__dirname, "..", rel);
  const ctx = vm.createContext({ console, Math, Date, JSON, Object, Array, Number, String });
  const src = fs.readFileSync(file, "utf8")
    .replace(/^\s*\.pragma\s+library\s*$/m, "")
    .replace(/^[ \t]*\.import[ \t]+"([^"]+)"[ \t]+as[ \t]+(\w+)[ \t]*$/gm, (_, importPath, alias) => {
      ctx[alias] = loadModel(path.join(path.dirname(rel), importPath));
      return "";
    });
  vm.runInContext(src, ctx, { filename: file });
  return ctx;
};
