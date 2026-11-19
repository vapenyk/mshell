# 08 — Lock screen and power menu

## 8.1 Button + Dialog
- Create: `components/Button.qml`, `components/Dialog.qml`
- [x] `Button`: filled, tonal, outlined, text, and destructive variants with StateLayer, pill shape, and press shape morph.
- [x] `Dialog`: scrim + centered `surfaceContainerHigh` surface, `extraLarge` radius, actions row; Esc closes
- Done when: used by 8.2. Add dialog width and scrim opacity tokens.

## 8.2 PowerMenu
- On-device reference: [40](../design/reference/40-device-power-dropdown.png) for the dropdown anchor and action grouping.
- Create: `modules/powermenu/PowerMenu.qml`, `services/Power.qml`, `services/Power.model.js`, and `tests/services/Power.model.test.js`.
- Update: `shell.qml`, `ControlCenter.qml`, `MainPage.qml`, `UiState.qml`, `IconButton.qml`, `Sizing.qml`, the component catalogue, and popup behavior.
- [x] Anchored menu with Lock, Sign out, Restart, and Power off as in shot 40. Centered confirmation for Restart and Power off with tonal Cancel and a destructive confirm button.
- [x] Commands via `Quickshell.execDetached` using argument arrays. Prefer `hyprshutdown` for sign-out when available. Keep Lock disabled until the shell's own lock action is connected in 8.3.
- [x] The Control Center power button and IPC `powermenu toggle` open the same dropdown on the relevant display.
- Done when: input, confirmation, cancel, and command dispatch work in the nested sandbox with substitute executables.
- Verified mouse, Escape, outside-click dismissal, IPC from a Control Center subpage, and one command per confirmed action in nested Hyprland.
- `shell.qml` passes `PowerMenu.actions` to Control Center. The header toggles `UiState.powerMenuOpen` and hosts the dropdown. The loader gives focus to the content, and PowerMenu assigns the initial row. Verified arrow navigation and Enter from Sign out to Restart.

## 8.3 Lock
- Read: shot 18; Quickshell `WlSessionLock` docs; check for a PAM service type in your version
- Create: `modules/lock/Lock.qml`, `modules/lock/LockSurface.qml`
- [ ] `WlSessionLock` covering all screens; surface: HH over MM huge clock (`clockHuge`), date, lock icon + hint
- [ ] Authentication via PAM (**verify** the module name in your version); wrong password feedback (shake via spring); never leave the session unlocked on error
- [ ] IPC `lock`: `lock`
- [ ] Connect the PowerMenu Lock row to the built-in lock action. Use the same action for the future idle lock trigger.
- Done when: lock/unlock works on 2 monitors; killing the shell while locked behaves per compositor (test in a VM/second TTY first)
