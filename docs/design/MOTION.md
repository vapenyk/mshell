# MOTION — springs, easing, wavy bars

We want motion to feel physical (M3 Expressive), but cheap. Rules first, numbers second.

## Rules
1. **Spatial changes use springs** (position, size, shape, rotation): popup open/close, tile reorder, pill expand, media card expand, slider handle.
2. **Effects use fast springs or short easing** (opacity, color): fade, state-layer, tile on/off color.
3. Every animation takes its parameters from `Motion.*`. No literals in components.
4. Animate only what changed. Prefer `Behavior on x` over timelines. No animation on things that update >10 Hz (slider drag follows the pointer 1:1; only release settles with a spring).
5. There is no reduced-motion setting (no per-module config by design). Keep durations short instead.
6. Offscreen / hidden items must not run animations (`running: visible`).
7. Open: scale 0.92→1 + fade + slide 8 dp toward its anchor. Close: reverse, faster (use the "accelerate" curve / fast spring).

## Springs (`Motion.qml`) `verify`
M3 Expressive defines spring tokens as stiffness + damping ratio. Reference values:
| Token | Stiffness | Damping ratio |
|---|---|---|
| spatial fast | 1400 | 0.9 |
| spatial default | 700 | 0.9 |
| spatial slow | 300 | 0.9 |
| effects fast | 3800 | 1.0 |
| effects default | 1600 | 1.0 |
| effects slow | 800 | 1.0 |

QML's `SpringAnimation` has a different scale (`spring` ≈ 0–5, `damping` ≈ 0–1, plus `epsilon`, `mass`). **Do not convert mathematically.** Keep the M3 tokens as documentation, and in `Motion.qml` map each to a tuned `SpringAnimation` preset (`spring`, `damping`, `mass`) by eye against the feel of the reference videos. Tune only in `Motion.qml`.

If a spring is overkill (color, opacity) use `NumberAnimation`/`ColorAnimation` with the durations and curves below.

## Easing and duration (`Motion.qml`) `verify`
| Name | cubic-bezier |
|---|---|
| standard | 0.2, 0, 0, 1 |
| standardDecelerate | 0, 0, 0, 1 |
| standardAccelerate | 0.3, 0, 1, 1 |
| emphasized | 0.2, 0, 0, 1 (approximation of M3's path curve) |
| emphasizedDecelerate | 0.05, 0.7, 0.1, 1 |
| emphasizedAccelerate | 0.3, 0, 0.8, 0.15 |

Durations (ms): `short1 50 · short2 100 · short3 150 · short4 200 · medium1 250 · medium2 300 · medium3 350 · medium4 400 · long1 450 · long2 500`.

QML uses `easing.type: Easing.BezierSpline` with `easing.bezierCurve: [x1,y1,x2,y2,1,1]`.

## Which motion for which element
| Element | Motion |
|---|---|
| Popup open / close | spatial default (open), spatial fast / emphasizedAccelerate 150 ms (close) |
| Tile on/off | color: effects default; icon chip morph: spatial fast |
| Tile reorder | spatial default on x/y |
| Page push/pop in `PageStack` | **shared axis X** (see Transition patterns) |
| Slider handle release | spatial fast |
| OSD in | spatial fast slide up from the bottom, `short2` fade |
| Pill hover/press | state layer fade short2; pressed shape squash optional (radius `full`→`large`) |
| Notification popup in | spatial default from top, out: fade + slide short4 |
| Media card expand from pill | **container transform** (see Transition patterns) |
| Hide/show of status pill | width spring + fade |
| Swapping one popup for another | **fade through** |
| Tooltip, OSD out, scrim | **fade** |
| Lock clock | fade medium4 |

## Transition patterns (M3)
M3 names four patterns for moving between screens/states. Use these names in plan steps and code comments; do not invent new ones.
| Pattern | Use when | Where we use it | How in QML |
|---|---|---|---|
| **Shared axis** | pages in a sequence/hierarchy (forward/back) | `PageStack` push/pop | outgoing: x 0 → −30 dp + fade out (first 35 %); incoming: x +30 dp → 0 + fade in (last 65 %); back = reversed; `medium2`, emphasized; one `Item` per page, `clip` on the stack |
| **Container transform** | an element becomes its detail surface | media pill → `MediaCard`; collapsed → expanded notification card | animate the surface's geometry from the source's geometry (spatial default); source content fades out in the first 30 %, destination content fades in after 30 %; one surface, not two |
| **Fade through** | unrelated content swaps | popup A → popup B; power menu content change | outgoing fades out (~90 ms), incoming fades in + scale .92 → 1 (~210 ms), no overlap |
| **Fade** | element appears/disappears in place | tooltip, OSD out, scrim | opacity only, `short3`/`short4`, standard curves |

Notes
- Pure position/size changes with no content change are **springs**, not these patterns.
- Container transform is approximated; do not build a general framework. One reusable `Behavior` set on the popup's `x/y/width/height/opacity` is enough.
- Keep every pattern's durations/curves in `Motion.qml`; patterns themselves are just documented combinations.

## Wavy bars (the signature Expressive element)
Used for: media seek bar active part (screenshot 11), any determinate/indeterminate progress (e.g. recording/loading, later).
Not used for: the control-center brightness/volume sliders (screenshot 01 shows thick flat sliders with a vertical handle).

### Visual spec (`project`, tune against screenshot 11)
- Active segment: sine wave, round caps, stroke 4 dp, color `primary`.
- Inactive remainder: **flat** line, stroke 4 dp, color `surfaceContainerHighest`, with a 4 dp gap before the handle.
- Handle: vertical bar 4 × 16 dp, `primary`, round.
- Wave: amplitude 3 dp, wavelength 24 dp (`tune`), phase speed one wavelength per ~1.2 s.
- Amplitude ramps 0 → full over the first 12 dp at the start so the wave grows out of the left edge.
- **Paused / not playing:** amplitude animates to 0 (flat line) using effects default spring; resumes on play.
- Dragging: amplitude stays, phase keeps moving.

### Implementation (`components/WavyBar.qml` + `components/WavyBar.model.js`)
- Geometry is a pure function in the model: `wavePoints(width, amplitude, wavelength, phase, step, rampLength) -> [{x, y}, ...]`. Unit-tested (start y = 0, length, periodicity, amplitude bound, ramp).
- Render with `QtQuick.Shapes`: `Shape { ShapePath { PathPolyline { path: points } } }`, `capStyle: ShapePath.RoundCap`, `fillColor: "transparent"`, `strokeColor: Theme.primary`.
- Drive `phase` with a `FrameAnimation` (not a `Timer`), only while `visible && playing`; ~2 dp point step; cap at 60 fps.
- If perf is a problem on the target GPU, replace the polyline with a `ShaderEffect` later. Do not pre-optimise.
- Public API: `value` (0..1), `playing` (bool), `seekable` (bool), signal `seeked(real value)`.

### Other expressive touches (only these, add nothing else without a spec change)
- Pill/tile **shape morph** on press (full → large) — spatial fast.
- One scalloped/cookie shape for the lock-screen or calendar "today" accent (optional, [plan step 11](../plan/11-polish.md)).
