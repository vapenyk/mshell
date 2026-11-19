// Loads a QML-style `.pragma library` JS file into a plain Node context.
// Rule for model files: top-level `function` declarations and `var` only
// (no const/let/class/import/export) so they work in both QML and here.
const fs = require("node:fs");
const vm = require("node:vm");
const path = require("node:path");

exports.loadModel = function loadModel(rel) {
  const file = path.join(__dirname, "..", rel);
  const src = fs.readFileSync(file, "utf8").replace(/^\s*\.pragma\s+library\s*$/m, "");
  const ctx = vm.createContext({ console, Math, Date, JSON, Object, Array, Number, String });
  vm.runInContext(src, ctx, { filename: file });
  return ctx;
};
