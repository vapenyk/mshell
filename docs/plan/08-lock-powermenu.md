# 08 — Lock screen and power menu

## 8.1 Button + Dialog
- Create: `components/Button.qml`, `components/Dialog.qml`
- [ ] `Button`: filled / tonal / outlined / text; StateLayer; pill shape; press shape morph
- [ ] `Dialog`: scrim + centered `surfaceContainerHigh` surface, `extraLarge` radius, actions row; Esc closes
- Done when: used by 8.2

## 8.2 PowerMenu
- Create: `modules/powermenu/PowerMenu.qml`
- [ ] Dialog with four actions: lock, log out, reboot, shut down (tonal buttons, destructive ones `errorContainer`); confirm for reboot/shut down
- [ ] Commands via `Quickshell.execDetached` (array)
- [ ] Opened from the control-center power dropdown (shot 01) and IPC `powermenu`: `toggle`
- Done when: each action works (test with a harmless one first)

## 8.3 Lock
- Read: shot 18; Quickshell `WlSessionLock` docs; check for a PAM service type in your version
- Create: `modules/lock/Lock.qml`, `modules/lock/LockSurface.qml`
- [ ] `WlSessionLock` covering all screens; surface: HH over MM huge clock (`clockHuge`), date, lock icon + hint
- [ ] Authentication via PAM (**verify** the module name in your version); wrong password feedback (shake via spring); never leave the session unlocked on error
- [ ] IPC `lock`: `lock`
- Done when: lock/unlock works on 2 monitors; killing the shell while locked behaves per compositor (test in a VM/second TTY first)
