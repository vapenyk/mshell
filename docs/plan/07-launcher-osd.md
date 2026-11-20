# 07 — Launcher and OSD

Before starting launcher work (7.1 or 7.2), contact the user to discuss how it should work. Wait for that discussion before implementing it. The launcher should follow the agreed design and behavior.

## 7.1 Apps + fuzzy
- Create: `services/Apps.qml`, `utils/Fuzzy.js`, `tests/utils/Fuzzy.test.js`
- [ ] `Apps`: `DesktopEntries` → list `{id, name, icon, comment, exec}`; `launch(id)`
- [ ] `Fuzzy.js`: `rank(query, items, keyFn)` → sorted matches; prefix > word-start > substring > subsequence; stable
- [ ] Tests: empty query (all, alphabetical), exact, prefix beats substring, no match, case-insensitive
- Done when: tests pass; service lists apps

## 7.2 Launcher
- Read: `../design/RESPONSIVE.md` (Launcher column) and confirm which layout and sizing rules apply after discussing the design with the user.
- Create: `components/SearchBar.qml`, `modules/launcher/Launcher.qml`, `modules/launcher/AppItem.qml`
- [ ] Centered popup on the focused screen; search pill on top (focus on open); grid of results (columns by size class); arrows/Enter/Escape work; opening is instant (data prefetched)
- [ ] IPC `launcher`: `toggle`
- Done when: `qs ipc call launcher toggle` → type → Enter launches

## 7.3 OSD

The IPC follow-up below defines the current OSD behavior.
[Step 10](10-slider.md) defines the shared slider geometry, stops, and icon placement for the OSD.

### Initial implementation (complete)

- Read: on-device references [41](../design/reference/41-device-osd-volume.png), [42](../design/reference/42-device-osd-brightness.png), [43](../design/reference/43-device-osd-volume-muted.png) for normal volume, brightness, and muted volume.
- Read: Material 3 slider [specs](https://m3.material.io/components/sliders/specs) and [guidelines](https://m3.material.io/components/sliders/guidelines).
- Read: `../design/BEHAVIOR.md` sections 1, 2, 4, 5 and the OSD row in section 6, `../design/MOTION.md`, `../design/COMPONENTS.md`, and `../conventions/TESTING.md`.
- Create: `modules/osd/Osd.qml`, `modules/osd/Osd.model.js`, and `tests/modules/osd/Osd.model.test.js`.
- Move `ValueSlider.qml` and its model to `components/sliders/` and move the model test to `tests/components/sliders/`. Update its Control Center consumers and catalogue links.
- Update: `shell.qml`, `services/Brightness.qml` and its model and tests, `services/Audio.qml`, `modules/controlcenter/TopControls.qml`, `config/Sizing.qml`, `config/Motion.qml`, and the design docs.
- [x] Observe output volume/mute, display brightness, and keyboard backlight changes after the initial device readings. Show one click-through pill under the bar on the focused screen, with a horizontal track, handle, and current state icon. Restart the 1.5 s timeout on each change.
- [x] Render keyboard backlight with stop indicators from its reported integer range, including off. The shared slider supports both continuous and stepped tracks. Keep the existing interactive Control Center sliders working.
- [x] Use the Control Center sliders themselves as feedback for adjustments made there. Keep the OSD available for external changes while Control Center is open.
- Done when: volume, mute, display brightness, and stepped keyboard backlight update in the nested session. Verify repeated input, hidden startup, timeout, and layer placement.
- Verified in nested Hyprland with two outputs, a test PipeWire sink, and simulated brightness devices. Checked output changes and removal, click-through, slider writes without OSD, and external changes with Control Center open.

### 7.3 follow-up — show OSD from key actions

Read the `AGENTS.md` runtime sandbox procedure, `../design/BEHAVIOR.md` sections 1, 2, 4 and the OSD row in section 6, the Multi-monitor section of `../design/RESPONSIVE.md`, and `../conventions/TESTING.md`. Read `services/{Audio,Brightness,Compositor,UiState}.qml`, their relevant existing models and tests, and `modules/osd/`. Check the volume and brightness bindings in `~/.config/hypr/hyprland.lua`.

Update `services/{Audio,Brightness}.qml`, `services/{Audio,Brightness}.model.js`, `modules/osd/Osd.qml`, `modules/osd/Osd.model.js`, their existing model tests, and the OSD rules in `../design/{BEHAVIOR,RESPONSIVE}.md` and `../conventions/NAMING.md`. Keep the existing file layout. `Audio` owns PipeWire, `Brightness` owns both brightness devices through `brightnessctl`, and `Osd.qml` owns the IPC handler, window, and timer. Control Center calls the system services directly.

1. [x] Add and test the service operations. Volume keys change the level by 2 percentage points within 0–100%. `volumeUp` clears mute and raises volume in the same action. `volumeDown` preserves mute. `toggleMute` changes only mute.
2. [x] Queue relative screen brightness commands `5%+` and `5%-` in order, including under repeat. Each command uses the current device level. Use a minimum of 1% of the hardware maximum, rounded up to a raw integer, for both the key actions and the Control Center slider. The slider currently uses a 5% minimum. Keyboard backlight uses relative one-level steps from zero to the hardware maximum. Apply `-n` only to screen brightness. [brightnessctl usage](https://github.com/Hummer12007/brightnessctl#usage)
3. [x] Open or extend the OSD through the `osd` IPC actions and the ASUS exception described below. Bind the displayed value to the relevant service. The click-through window switches content in place on the same monitor. Every accepted action, including a repeat at a range limit, restarts the single 1.5 s timer when the OSD is eligible to show. Slider writes and external device changes can update visible content. Remove the change-origin tracking and all show or timeout triggers tied to value changes.
4. [x] Select `Compositor.focusedScreen` for each IPC action that opens or extends the OSD. After a focus change, the next action moves the OSD to the focused output. On output removal, close the OSD and resolve the focused output on the next action.
5. [x] Use `UiState` to close the OSD immediately when Control Center opens or the session locks. IPC actions still change levels while Control Center is open or the session is locked. The OSD stays hidden in both cases. A new action after closing the panel or unlocking can show it again.
6. [x] Test the IPC and Lua bindings in the nested sandbox before replacing the direct host binds for the listed keys. Each command uses `qs -c mshell ipc call osd <method>`. Use `hl.bind` with `hl.dsp.exec_cmd`, keep `locked = true` on the existing volume and screen brightness keys, and set `repeating = true` for up/down. Mute uses a single action. Bind keyboard backlight only after verifying which events the laptop emits and whether firmware already handles them.

   | Key | IPC method |
   |---|---|
   | `XF86AudioRaiseVolume` | `volumeUp` |
   | `XF86AudioLowerVolume` | `volumeDown` |
   | `XF86AudioMute` | `toggleMute` |
   | `XF86MonBrightnessUp` | `brightnessUp` |
   | `XF86MonBrightnessDown` | `brightnessDown` |
   | `XF86KbdBrightnessUp` | `keyboardBrightnessUp` |
   | `XF86KbdBrightnessDown` | `keyboardBrightnessDown` |

7. [x] Verify in nested Hyprland with two outputs. Check hidden startup, a slider change to 40% followed by closing Control Center and raising volume to 42%, mute/unmute, brightness limits and ordered repeats. Check Wayland logs for zero OSD surface creations during slider drags and external writes. Hold a key while opening and closing Control Center and while changing monitor focus. Switch from volume to brightness on the same monitor and verify that one surface updates, one timeout restarts, and repeat stays responsive. Check output removal, click-through, and level changes during session lock.
8. [x] Update the behavior and IPC documentation to match the result. Run model tests and `sh tools/unused.sh`, tick the completed checks, update `00-OVERVIEW.md`, and commit the follow-up.

Verified in nested Hyprland with two outputs, an isolated PipeWire sink, simulated brightness devices, and virtual media keys. The five existing host audio and screen brightness bindings use the tested IPC targets. The ASUS WMI device reports hardware-driven keyboard backlight changes and exposes no keyboard backlight key events. Its Fn behavior stays with the driver. `keyboardBrightnessUp` and `keyboardBrightnessDown` are available through IPC.

### 7.3 follow-up — ASUS keyboard backlight key

Read `services/Brightness.qml`, `modules/osd/Osd.qml`, and the OSD rules in `../design/{BEHAVIOR,RESPONSIVE}.md`. Create `services/AsusKeyboardBacklight.qml`. Update those files and the OSD entry in `../conventions/NAMING.md`. Remove the temporary keyboard backlight probe from `~/.config/hypr/hyprland.lua` after verification.

- [x] Use a single optional ASUS service to watch the driver's `brightness_hw_changed` notification. Refresh the shared `Brightness` reading and present it through one connection in `Osd.qml`. The driver owns the write. Removing the service and its OSD connection removes the exception.
- [x] Check in nested Hyprland that only the ASUS hardware event and the explicit IPC actions open the keyboard OSD. Check startup, ordinary backlight writes, event repeats, Control Center suppression, and hosts without the ASUS device. Confirm the native Fn key with a hardware event when available.

Verified the real ASUS Fn key on the laptop and confirmed the indicator with the user. The nested run also covered a simulated non-ASUS device.

### 7.3 follow-up — bottom-center placement

The user chose to center the OSD horizontally near the bottom edge of the focused monitor to keep it clear of notifications and windows at the top.

Read and update `modules/osd/Osd.qml`, `config/Sizing.qml`, and the OSD rules in `../design/{BEHAVIOR,MOTION,RESPONSIVE,TOKENS}.md`.

- [x] Anchor the pill to the bottom center with a 16 dp bottom margin. Bring it in from the bottom and keep the current click-through behavior, focus selection, and timeout.
- [x] Verify the position on two outputs in nested Hyprland and show a notification toast at the same time to confirm their bounds do not overlap.
