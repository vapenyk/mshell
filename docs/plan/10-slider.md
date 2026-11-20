# 10 — Slider (ValueSlider)

Use one `ValueSlider` for Control Center and OSD. Follow the container rules in [step 09](09-m3-finalize.md) and the sequence in the [overview](00-OVERVIEW.md#how-to-work-a-step). Control Center places the slider inside its Panel (`surfaceContainer`, `Shape.extraLarge`). OSD places it inside its pill-shaped Surface (`surfaceContainer`, `Shape.full`).

Read `components/sliders/{ValueSlider.qml,ValueSlider.model.js}`, `tests/components/sliders/ValueSlider.model.test.js`, `components/IconButton.qml`, `config/{Sizing,Shape}.qml`, `modules/controlcenter/TopControls.qml`, and `modules/osd/Osd.qml`. Read the slider entries in [TOKENS.md](../design/TOKENS.md) and [COMPONENTS.md](../design/COMPONENTS.md), the model rules in [CODE-STYLE.md](../conventions/CODE-STYLE.md) and [TESTING.md](../conventions/TESTING.md), and the Material 3 [specs](https://m3.material.io/components/sliders/specs) and [guidelines](https://m3.material.io/components/sliders/guidelines).

The shared slider currently gets its default 40 dp height from `Sizing.sliderHeight`. `showStops` reduces the track to 16 dp and hides the inset icon, so the keyboard-backlight OSD draws a separate icon. The slider currently prefers the active segment for its right-aligned icon, so the icon only moves to the inactive segment near the low end. This step introduces explicit size presets and moves the icon as soon as the inactive segment can fit it.

## 10.1 Independent settings

| Property | Responsibility |
|---|---|
| `size` | Selects the shared `s` or `m` geometry. Defaults to `m`. |
| `interactive` | Enables pointer, wheel, keyboard, and accessibility actions. Interactive controls expose the Slider role and emit `moved` on user changes. Read-only instances expose the ProgressBar role and display the supplied `value`. |
| `showStops` | Displays stop markers. Their positions come from the range and `stepSize`. |

Keep `stepSize` as the source of value increments and snapping. A slider can write volume in 1% increments with hidden stops. Turning on `showStops` keeps the geometry and value mapping of the same slider. Preserve the smooth drag and release behavior for Control Center. `enabled` continues to control disabled colors and input. A read-only OSD uses the normal enabled colors.

| Input and accessibility | `interactive: true` | `interactive: false` |
|---|---|---|
| Pointer click, drag, and wheel | Changes the value when enabled | Displays the supplied value |
| Tab and arrow keys | Participates in focus and keyboard adjustment when enabled | Skips the Tab order |
| Accessibility role | `Slider` with increment and decrement actions when enabled | `ProgressBar` |
| `moved` | Emitted for a user value change | Never emitted |
| Geometry, inset icon, and stops | Determined by the size, value, and visual settings | Same rules |

| Consumer | Size | Interactive | Show stops |
|---|---|---|---|
| Control Center volume and screen brightness | `m` | Yes | No |
| OSD volume, mute, and screen brightness | `m` | No | No |
| OSD keyboard backlight | `m` | No | Yes |

The caller selects `size` and supplies the available width. Any future screen-size policy belongs in the calling container. The current consumers use M. S is the explicitly requested iconless preset, exercised in the sandbox. This is a scoped exception to the compact-variant rule in [LEAN.md](../conventions/LEAN.md).

## 10.2 Geometry and icon placement

| Metric | S | M |
|---|---:|---:|
| Track height | 24 dp | 40 dp |
| Handle height | 44 dp | 52 dp |
| Outer track radius | `Shape.small` (8 dp) | `Shape.medium` (12 dp) |
| Inset icon | None | 24 dp |

**S renders without an icon, including when the caller supplies `icon`.**

Example sizing tokens in `Sizing.qml`:

```qml
readonly property var sliderSizes: ({
    s: {
        trackHeight: 24,
        handleHeight: 44,
        trackRadius: Shape.small,
        insetIcon: null
    },
    m: {
        trackHeight: 40,
        handleHeight: 52,
        trackRadius: Shape.medium,
        insetIcon: { size: 24, padding: 8 }
    }
})

readonly property int sliderHandleWidth: 4
readonly property int sliderPressedHandleWidth: 2
readonly property int sliderHandleGap: 4
readonly property int sliderStopSize: 4
readonly property int sliderStopSpacing: 12
```

Example property bindings in `ValueSlider.qml`:

```qml
property string size: "m" // s or m
property bool interactive: true
property bool showStops: false

readonly property var _metrics: Sizing.sliderSizes[size] ?? Sizing.sliderSizes.m

implicitHeight: Math.max(_metrics.trackHeight, _metrics.handleHeight)
```

| Component part | Source |
|---|---|
| Filled and unfilled segment heights | `_metrics.trackHeight` |
| Outer segment corners | `_metrics.trackRadius` |
| Handle height | `_metrics.handleHeight` |
| Handle widths and gaps | Shared handle tokens in `Sizing.qml` |
| Inset icon size and padding | `_metrics.insetIcon` when present |
| Stop marker size and minimum spacing | `Sizing.sliderStopSize` and `Sizing.sliderStopSpacing` |

- [ ] Define the S and M measurements in `Sizing.sliderSizes`. Use `Shape` for radii. Keep the shared handle width (4 dp), pressed width (2 dp), handle gap (4 dp), and stop size and spacing in `Sizing.qml`. Remove the stop-specific track height.
- [ ] Center the track segments and handle vertically. The handle draws between the segments over the containing surface, with a gap on each side. The M handle extends 6 dp above and below the track. Use the same geometry with stops visible or hidden.
- [ ] Place the M inset icon at the right end of its segment with the slider inset token. Prefer the inactive segment as soon as it can fit the icon with its required padding. Otherwise place the icon at the right end of the active segment, next to the handle. Hide it when both segments are too narrow.
- [ ] Use `Theme.primary` and `Theme.surfaceContainerHighest` for the active and inactive tracks. On those tracks, the icon uses `Theme.onPrimary` and `Theme.onSurfaceVariant`, respectively. Preserve the disabled treatment.
- [ ] Render the M icon with `showStops` enabled. Hide any markers that overlap the icon while preserving the position of the other markers and the full step range.
- [ ] Compute the icon's segment, position, and stop-marker overlap in `ValueSlider.model.js`. Pass the segment geometry and preset metrics from QML and bind the result. Test the inactive-segment fit threshold, the fallback to the active segment, the case where neither segment fits, and markers inside and outside the icon bounds.

For M, a segment can fit the icon when `segment.width >= iconSize + 2 * iconPadding`. Once the segment is selected, the icon's left edge is `segment.x + segment.width - iconPadding - iconSize`. Both calculations use the segment's visible width, which already accounts for the gap beside the handle.

## 10.3 Consumers and documentation

- [ ] Use M in `TopControls.qml`. Center the night-light and mixer buttons beside the taller handle. Keep their existing 40 dp size through an icon button token when replacing the shared `Sizing.sliderHeight` references.
- [ ] Use M for all presentations in `Osd.qml`. Keep the outer pill 56 dp high, with 8 dp above and below the 40 dp track. The 52 dp handle occupies 6 dp of that padding on each side, leaving 2 dp above and below at the center of the pill. Check clearance at its rounded ends. Use the same inset icon rule for all presentations and remove the separate keyboard icon. Bind keyboard stops to the reported integer range including zero, with `stepSize: 1`.
- [ ] Keep system reads and writes in the existing services. Control Center writes via the existing `moved` handlers. OSD displays the supplied values and retains the [step 07](07-launcher-osd.md#73-osd) rules for show, suppression, timeout, and placement.
- [ ] Update the slider entry in `COMPONENTS.md` to list `size`, `interactive`, and `showStops`. In `TOKENS.md`, replace the shared 40 dp slider/button height with the S and M geometry and the separate 40 dp button size. Replace the 16 dp stepped-track entry with the shared stop size and spacing. Record the icon rules and the unchanged 56 dp OSD height. The Control Center and OSD plan entries link here for the current slider rules.

Example interactive Control Center volume slider:

```qml
Sliders.ValueSlider {
    size: "m"
    interactive: true
    showStops: false
    accessibleName: qsTr("Volume")
    icon: Audio.muted ? "volume_off" : "music_note"
    value: Audio.volume
    onMoved: value => Audio.setVolume(value)
}
```

Example read-only OSD slider with the existing presentation model:

```qml
Sliders.ValueSlider {
    size: "m"
    interactive: false
    showStops: root._presentation?.discrete ?? false
    accessibleName: root._kind === "keyboard" ? qsTr("Keyboard backlight")
                  : root._kind === "display" ? qsTr("Display brightness") : qsTr("Volume")
    minimumValue: 0
    maximumValue: root._presentation?.maximum ?? 1
    stepSize: root._presentation?.discrete ? 1 : 0
    value: root._presentation?.value ?? 0
    icon: root._presentation?.icon ?? ""
}
```

## 10.4 Verification

- [ ] In nested Hyprland, check the M Control Center sliders with mouse, wheel, Tab, and arrow keys. Verify 1% writes, value updates, the enabled and disabled states, and alignment with the round buttons.
- [ ] Check right-aligned inset icon placement on both segments, the switch as the inactive segment gains space, and the narrow case where neither segment fits. Switch between S and M in a sandbox instance and confirm track and handle heights with stops both on and off. Pass the same nonempty `icon` to both sizes and verify that only M can display it.
- [ ] Check bottom-center OSD for volume, mute, display brightness, and keyboard backlight. Switch presentations while the OSD is visible and check that the pill stays 56 dp high. Check handle clearance at both ends of the track, click-through, and that the keyboard markers remain readable across the range.
- [ ] Extend the existing model tests for the icon placement and stop overlap. Run the model suite and `sh tools/unused.sh`, check the file size limits in `LEAN.md`, mark the completed checks, and update `00-OVERVIEW.md`.

Use the existing `ValueSlider` files. Centered and range sliders, adaptive screen policies, and changes to OSD window behavior are outside this step.
