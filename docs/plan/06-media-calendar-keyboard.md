# 06 — Media, calendar, keyboard layout
Goal: shots 10, 11, 12, 09.

Media steps 6.1–6.4 are deferred until MPRIS is wanted. The calendar and keyboard layout picker can proceed independently.

## 6.1 Media service
- Create: `services/Media.qml`
- [ ] Mpris: choose the active player (playing first, else most recent), `title`, `artist`, `art`, `playing`, `position`, `length`, `play/pause`, `next`, `previous`, `seek`
- Done when: values follow a real player

## 6.2 MediaPill
- Read: shot [21](../design/reference/21-desktop-bar-widgets-dock.webp) for the collapsed player and its placement in the bar.
- Read: shot 10
- Create: `modules/bar/pills/MediaPill.qml`
- [ ] Visible only when a player exists; pause/play button + title elided (max width by size class); click toggles `UiState` popup `media`
- Done when: appears/disappears with the player; matches shot 10

## 6.3 WavyBar
- Read: `../design/MOTION.md` (Wavy bars — full spec)
- Create: `components/WavyBar.qml`, `components/WavyBar.model.js`, `tests/components/WavyBar.model.test.js`
- [ ] Model per MOTION: `wavePoints(width, amplitude, wavelength, phase, step, rampLength)`; plus `splitAt(value, width, gap)` → active/inactive lengths
- [ ] QML per MOTION: Shapes polyline active part + flat inactive part + handle; `FrameAnimation` only while visible and playing; amplitude springs to 0 when paused
- [ ] API: `value`, `playing`, `seekable`, `seeked(value)`
- [ ] Tests: start at y=0, ramp, amplitude bound, flat at zero amplitude, split math
- Done when: looks like shot 11 seek bar; idle CPU ~0 when paused/hidden

## 6.4 MediaCard
- Read: shot 11
- Create: `modules/media/MediaCard.qml`, `modules/media/MediaCard.model.js` (+ test)
- [ ] Popup from the pill: blurred art background (or `surfaceContainerHigh` if no art), source icon, title/artist, large play/pause (rounded square), prev/next, `WavyBar`, time labels
- [ ] Model: `progress(position, length)`, `timeLabel(seconds)` (tested)
- Done when: matches shot 11; seek works

## 6.5 Calendar
- On-device reference: [29](../design/reference/29-device-clock-calendar-closed.png), [30](../design/reference/30-device-calendar-open.png) for closed and open states.
- Read: shot 12
- Create: `modules/calendar/CalendarPopup.qml`, `modules/calendar/Calendar.model.js`, `tests/modules/Calendar.model.test.js`, and `components/AnchoredPopup.qml` for the calendar and the layout picker in 6.6.
- Update: `shell.qml`, `ClockPill.qml`, `config/Sizing.qml`, and the component catalogue.
- [x] Model: `month(year, month, weekStart)` → six weeks of day cells with `inMonth`, local date comparison, and month navigation
- [x] Popup: localized month title, previous and next, localized week start, and a grid with today highlighted in `primary`.
- [x] Opens from `ClockPill` (`UiState` popup `calendar`)
- Done when: matches shot 12; tests for leap year, month starting on Mon/Sun, 6-week months
- Verified month navigation, arrow-key day focus, Escape, clicking the clock again, and outside-click dismissal in nested Hyprland.

### 6.5 follow-up — date selection and year picker

- Read the [on-device calendar captures](../design/reference/INDEX.md#on-device-calendar-captures-5256) and the [M3 calendar reference](../design/REFERENCES.md). Use mshell's color and typography tokens.
- [x] Start on the current month with today's date filled, as in [52](../design/reference/52-device-calendar-today.png). Selecting another day fills that date and leaves today outlined whenever both dates are visible, as in [53](../design/reference/53-device-calendar-day-selected.png).
- [x] Make the month and year label open a scrollable three-column year picker in the same panel. On entry, show the displayed year and highlight it. The chevron indicates the open state. Choosing a year returns to the month grid for that year, keeping the displayed month. See [54](../design/reference/54-device-calendar-year-picker.png).
- [x] Verify previous and next month navigation in a month without either date in view ([55](../design/reference/55-device-calendar-previous-month.png)) and across December and January ([56](../design/reference/56-device-calendar-next-year-month.png)). Keep the panel height stable and use blank cells outside the displayed month.
- Create `modules/calendar/CalendarMonthGrid.qml` and `modules/calendar/CalendarYearGrid.qml` for the two body views used by `CalendarPopup.qml`.
- Update `CalendarPopup.qml`, `Calendar.model.js`, its tests, and the component catalogue.
- Verified day and year selection by mouse and keyboard, wheel scrolling, the six-week January 2027 grid with a Sunday week start, stable panel height, Escape, and reset to today when reopened in nested Hyprland.

## 6.6 Keyboard layout
- On-device reference: [32](../design/reference/32-device-keyboard-layouts.png) for language codes, names, and selected row styling. Omit the title and settings button.
- Read: shot 09; Hyprland: layout comes from the keyboard device (`hyprctl devices -j`) and the `activelayout` raw event; switch with `hyprctl switchxkblayout <device> next|<id>`
- Create: `services/Keyboard.qml`, `services/Keyboard.model.js`, `tests/services/Keyboard.model.test.js`, `modules/bar/pills/KeyboardPill.qml`, and `modules/keyboard/KeyboardPopup.qml`. Keep the layout row in the picker.
- Update: `shell.qml`, `Bar.qml`, `config/Sizing.qml`, the component catalogue, the reference index, and the popup behavior and placement docs. Let `AnchoredPopup.qml` and `PopupWindow.qml` opt into centering under the pill, with placement and tests in the existing popup model. Clear the anchored popup in `UiState.qml` when its screen is removed and handle the disappearing screen in notification window sizing.
- [x] Service: `layouts`, `current`, `switchTo(i)` from Hyprland. Parse `hyprctl devices` and XKB layout names in the tested model. Refresh after `activelayout` and `configreloaded`.
- [x] The pill shows the current layout code. Click opens the list without changing layout. Select a row to switch and close the list. Use `secondaryContainer` for the active row.
- [x] Hidden when only one layout exists
- Done when: switching layouts works from the popup
- Verified with US, RU, and UA in nested Hyprland. Checked mouse and keyboard selection, external switches, Escape, swapping with the calendar, one-layout visibility, and output removal.
