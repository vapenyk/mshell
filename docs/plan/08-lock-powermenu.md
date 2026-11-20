# 08 — Lock screen and power menu

## 8.1 Button + Dialog
- Create: `components/Button.qml`, `components/Dialog.qml`
- [x] `Button`: filled, tonal, outlined, text, and destructive variants with StateLayer, pill shape, and press shape morph.
- [x] `Dialog`: scrim + centered `surfaceContainerHigh` surface, `extraLarge` radius, actions row; Esc closes
- Done when: used by 8.2. Add dialog width and scrim opacity tokens.

## 8.2 PowerMenu
- On-device reference: [40](../design/reference/40-device-power-dropdown.png) for the dropdown anchor and action grouping.
- Create: `modules/controlcenter/PowerMenu.qml`, `services/Power.qml`, `services/Power.model.js`, and `tests/services/Power.model.test.js`.
- Update: `shell.qml`, `ControlCenter.qml`, `MainPage.qml`, `UiState.qml`, `IconButton.qml`, `Sizing.qml`, the component catalogue, and popup behavior.
- [x] Anchored menu with Lock, Sign out, Restart, and Power off as in shot 40. Centered confirmation for Restart and Power off with tonal Cancel and a destructive confirm button.
- [x] Commands via `Quickshell.execDetached` using argument arrays. Prefer `hyprshutdown` for sign-out when available. The Lock row invokes the shell's own lock action from 8.3.
- [x] The main page Power button opens Control Center's own dropdown on its display.
- Done when: input, confirmation, cancel, and command dispatch work in the nested sandbox with substitute executables.
- Control Center owns the power menu. The header hosts its button and dropdown, and the Control Center scope keeps a confirmation alive while the panel closes. The existing `controlcenter` and `lock` IPC targets remain available.
- Verified the Power button toggle, outside-click dismissal, Escape, arrow navigation, and Restart and Power off confirmations in nested Hyprland with substitute executables. The IPC listing includes `controlcenter` and `lock`.

## 8.3 Lock
- Read: on-device photo [57](../design/reference/57-device-lock-screen.jpg), shot 18, [WlSessionLock](https://quickshell.org/docs/v0.3.2/types/Quickshell.Wayland/WlSessionLock/), and [PamContext](https://quickshell.org/docs/v0.3.2/types/Quickshell.Services.Pam/PamContext/).
- Create: `modules/lock/Lock.qml`, `modules/lock/LockSurface.qml`, `modules/bar/BarContent.qml`, and `components/TextField.qml` extracted from `NotifReply.qml` for use by both reply and password entry. Add photo 57 to the reference index.
- Update: `shell.qml`, `Bar.qml`, `UiState.qml`, `PowerMenu.qml`, `NotifReply.qml`, lock sizing and motion tokens, and the behavior and component documentation.
- [x] Use a Wayland session-lock surface on every output. Keep the normal bar visuals and live indicators at the top, with every click in that bar returning focus to the password field.
- [x] Place the stacked clock and date above center. Put a masked password field near the bottom in place of the lock icon and hint. Reuse the shared field styling and show rejection next to the field with a brief shake.
- [x] Blur the wallpaper supplied through `Lock.backgroundSource` over an opaque base. Use a dark themed fallback until the future Background service can provide the image. Lock owns the blur and dimming.
- [x] Authenticate the current user through Quickshell's PAM context using the system authentication profile. Unlock only after successful authentication. Keep the lock active on a rejected password or a PAM error.
- [x] Preserve the lock request across a Quickshell configuration reload using in-memory `PersistentProperties`.
- [x] Route IPC `lock lock` and the Power menu action through the shared lock request in `UiState`. Use the same request for the future idle trigger.
- Done when: verify two outputs, hot-plug, bar focus, wrong and successful credentials with isolated PAM, and compositor behavior after killing the locker in nested Hyprland.
- Verified two headless outputs, hot-plug, click-to-focus from the bar, isolated PAM failure and success, IPC and Power menu entry, reload, and the compositor's locked fallback after killing Quickshell. Verified the wallpaper blur and the image-free fallback.
- Quickshell 0.3.2 may log that the old lock object was destroyed during a reload. The nested Wayland trace showed the lock surviving the handover and releasing only after successful PAM authentication. [Source for the reload and unlock paths](https://github.com/quickshell-mirror/quickshell/blob/v0.3.2/src/wayland/session_lock.cpp).
