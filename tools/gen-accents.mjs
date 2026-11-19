// One-off generator: writes config/accents.json (dark M3 schemes per accent seed).
// Not part of the shell runtime. Run only when changing the accent list.
//   cd tools && npm i @material/material-color-utilities@0.3.0   # newer versions fail to resolve under node ESM
//   node gen-accents.mjs > ../config/accents.json
import {
  Hct, SchemeTonalSpot, SchemeNeutral, MaterialDynamicColors as D,
  argbFromHex, hexFromArgb,
} from "@material/material-color-utilities";

const SEEDS = {            // name: [seed hex, scheme]
  blue:   ["#4a6fd6", SchemeTonalSpot],
  violet: ["#7e57c2", SchemeTonalSpot],
  pink:   ["#d6528a", SchemeTonalSpot],
  red:    ["#d6453d", SchemeTonalSpot],
  orange: ["#e07b2a", SchemeTonalSpot],
  yellow: ["#c9a21a", SchemeTonalSpot],
  green:  ["#4c9a5a", SchemeTonalSpot],
  teal:   ["#26a69a", SchemeTonalSpot],
  mono:   ["#8a8a8a", SchemeNeutral],
};

const ROLES = [
  "primary", "onPrimary", "primaryContainer", "onPrimaryContainer",
  "secondary", "onSecondary", "secondaryContainer", "onSecondaryContainer",
  "tertiary", "onTertiary", "tertiaryContainer", "onTertiaryContainer",
  "error", "onError", "errorContainer", "onErrorContainer",
  "background", "onBackground",
  "surface", "onSurface", "surfaceVariant", "onSurfaceVariant",
  "surfaceDim", "surfaceBright",
  "surfaceContainerLowest", "surfaceContainerLow", "surfaceContainer",
  "surfaceContainerHigh", "surfaceContainerHighest",
  "outline", "outlineVariant",
  "inverseSurface", "inverseOnSurface", "inversePrimary",
  "shadow", "scrim", "surfaceTint",
];

const out = {};
for (const [name, [hex, Scheme]] of Object.entries(SEEDS)) {
  const scheme = new Scheme(Hct.fromInt(argbFromHex(hex)), true, 0);
  out[name] = { seed: hex };
  for (const r of ROLES) out[name][r] = hexFromArgb(D[r].getArgb(scheme));
}
console.log(JSON.stringify(out, null, 2));
