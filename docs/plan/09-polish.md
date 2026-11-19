# 09 — Polish and cleanup
Only after 01–08 are ✅. Each item is optional if it already looks right.

- [ ] Motion pass: tune `Motion.qml` spring presets against the feel of reference videos; check every element in `MOTION.md` table
- [ ] Fix the remaining control-center stutter when navigating between the main page and Modes and when leaving tile edit mode. Reproduce with real input and inspect frame timing, panel resizing, and tile reflow. The page height animation alone did not resolve the stutter.
- [ ] Responsive pass: full matrix in `RESPONSIVE.md`, plus unplug/plug a monitor with each popup open
- [ ] Verify marks: `grep -rn "verify" docs/` → check against the M3 pages, update numbers, remove marks
- [ ] Keyboard navigation: Tab order and focus ring in popups, Escape everywhere, arrows in lists/grids
- [ ] Accents: switch through all nine; check contrast of `onPrimary` on `primary` tiles and the pill active state
- [ ] Optional: one scalloped/cookie shape (lock-screen clock accent or calendar "today") — only if it looks right in context
- [ ] Idle cost: with nothing open, CPU ≈ 0 (no running animations, no polling faster than needed); check `FrameAnimation`s are stopped when hidden
- [ ] Final cleanup: `sh tools/unused.sh` empty; size budgets (`LEAN.md` #10) — split any file over budget; delete dead tokens
- [ ] Update `NAMING.md` feature map to match reality
