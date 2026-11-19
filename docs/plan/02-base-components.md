# 02 — Base components
Goal: the five primitives every later element is built from. Built here only because the bar needs them immediately.

Common read: `../design/COMPONENTS.md` (Base table), `../design/TOKENS.md`, `../conventions/CODE-STYLE.md` (Visuals).
Common rule: no `services` imports. All values from tokens.

## 2.1 StateLayer
- Read: `../design/TOKENS.md` (State layers), `../design/MOTION.md` (Pill hover/press)
- Create: `components/StateLayer.qml`
- Update: `modules/bar/Bar.qml` to use the layer on the temporary clock and `config/Sizing.qml` to expose the pill height.
- [x] Props: `contentColor`, `hovered`, `pressed`, `focused`, `radius`
- [x] Overlay opacity from `Theme.state*`, fade `Motion.short2`
- Done when: temporary use inside `Bar.qml` shows hover/press fade

## 2.2 Icon
- Create: `components/Icon.qml`
- [ ] Props: `name`, `size` (default 20/24), `color`, `filled` (animates FILL)
- [ ] Uses Material Symbols Rounded (variable font axes)
- Done when: `wifi`, `bluetooth_connected`, `do_not_disturb_on` render, filled toggle animates

## 2.3 Text
- Create: `components/Text.qml`
- [ ] `role: string` selects from `Typography` (default `bodyMedium`); `color` default `Theme.onSurface`; elide right by default
- Done when: all roles render with correct size/weight

## 2.4 Surface
- Create: `components/Surface.qml`
- [ ] Props: `container` (color role), `radius`, `shadow` (bool)
- [ ] Color change animated with effects spring/short easing
- Done when: used as background of the pill

## 2.5 Pill
- Read: `../design/reference/INDEX.md` → shots 07, 10, 12 (open those PNGs)
- Create: `components/Pill.qml`
- [ ] Slots: `icon`, `text`, optional trailing; `active` (popup open) → `secondaryContainer`
- [ ] Signals: `clicked`, `rightClicked`; contains `StateLayer`; hover via `HoverHandler`
- [ ] Height 32; min width 32; icon-only collapses to a circle
- [ ] `Bar.qml`: replace the temporary time text with a `Pill` showing the clock
- Done when: clock pill matches screenshot 12 (left pill) in structure; hover/press/active states work; unused check clean (all 02 files consumed by Pill/Bar)
