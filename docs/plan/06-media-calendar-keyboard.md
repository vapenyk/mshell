# 06 — Media, calendar, keyboard layout
Goal: shots 10, 11, 12, 09.

## 6.1 Media service
- Create: `services/Media.qml`
- [ ] Mpris: choose the active player (playing first, else most recent), `title`, `artist`, `art`, `playing`, `position`, `length`, `play/pause`, `next`, `previous`, `seek`
- Done when: values follow a real player

## 6.2 MediaPill
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
- Read: shot 12
- Create: `modules/calendar/CalendarPopup.qml`, `modules/calendar/Calendar.model.js`, test
- [ ] Model: `month(year, month, weekStart)` → weeks of day cells with `inMonth`, `isToday(now)`; navigation helpers; `now` passed in
- [ ] Popup: title + prev/next, weekday header, grid; today = filled circle `primary`
- [ ] Opens from `ClockPill` (`UiState` popup `calendar`)
- Done when: matches shot 12; tests for leap year, month starting on Mon/Sun, 6-week months

## 6.6 Keyboard layout
- Read: shot 09; Hyprland: layout comes from the keyboard device (`hyprctl devices -j`) and the `activelayout` raw event; switch with `hyprctl switchxkblayout <device> next|<id>`
- Create: `services/Keyboard.qml`, `modules/bar/pills/KeyboardPill.qml`, `components/ListItem.qml`
- [ ] Service: `layouts`, `current`, `switchTo(i)` (Hyprland only); parsing of `hyprctl` JSON goes in a tested model
- [ ] Pill shows 2-letter code; popup lists layouts (selected = `secondaryContainer`)
- [ ] Hidden when only one layout exists
- Done when: switching layouts works from the popup
