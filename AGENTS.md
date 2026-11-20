# AGENTS.md

Quickshell shell, Material 3 Expressive, dark only, one user-picked accent.
Read this file, then ONLY the files your current task points to. Do not read all of `docs/`.

## Start here
1. `docs/plan/00-OVERVIEW.md` — use the step the user selects. Otherwise, find the first unchecked step.
2. Open that step file. Do that step only. Its "Read" list is your whole reading list.
3. When done: tick the TODOs, update the table in `00-OVERVIEW.md`, stop.

## Where things are
| Need | File |
|---|---|
| What we are building, what we are NOT | `docs/design/SPEC.md` |
| Colors, type, shape, motion, state numbers | `docs/design/TOKENS.md` |
| Springs, wavy bars, animation rules | `docs/design/MOTION.md` |
| Window sizes, scaling, popup placement | `docs/design/RESPONSIVE.md` |
| Layers, focus, open/close, keyboard, navigation, notification semantics | `docs/design/BEHAVIOR.md` |
| Component → M3 link → our file | `docs/design/COMPONENTS.md` |
| M3 links | `docs/design/REFERENCES.md` |
| Visual reference (screenshots) | `docs/design/reference/INDEX.md` |
| Folder layout, dependency rules | `docs/conventions/STRUCTURE.md` |
| Names, feature relations | `docs/conventions/NAMING.md` |
| QML style | `docs/conventions/CODE-STYLE.md` |
| Testing (`*.model.js`) | `docs/conventions/TESTING.md` |
| Anti-bloat rules | `docs/conventions/LEAN.md` |

## Hard rules
- Before adding a UI component, check [the component catalogue](docs/design/COMPONENTS.md) for a reusable match. Update the catalogue when a component is added, moved, or removed.
- Create only files listed in the current plan step. Need another file? Add it to the plan first.
- Every file must have a consumer by the end of its step. No speculative code.
- Logic that is not UI goes in `Name.model.js` with a test. QML only binds.
- Never hardcode color / radius / duration / font size. Use `Theme`, `Shape`, `Motion`, `Typography`.
- `components/` never imports `services/`. Modules never import other modules.
- Never touch matugen, light theme, or theming of other apps. Out of scope.

## Runtime sandbox
- Run Hyprland as a nested compositor in a dedicated development sandbox. Launch Quickshell inside the same sandbox and connect it to the nested Hyprland display.
- Open the nested compositor on host workspace 10 without switching workspaces or taking keyboard focus. Apply the host window rule before launching it.
- Give the sandbox its own writable configuration and runtime directories. Run `hyprctl` and Quickshell IPC commands from the sandbox so they target its instances.

## Commands
- From the repository root in a host Hyprland terminal, install the temporary window rule and enter the development shell.

  ```bash
  hyprctl eval 'mshell_dev_rule = hl.window_rule({
      name = "mshell-dev-workspace",
      match = {initial_class = "aquamarine", initial_title = "aquamarine - WAYLAND-[0-9]+"},
      workspace = "10 silent",
      no_initial_focus = true,
  })'
  (
      MSHELL_DEV=$(mktemp -d /tmp/ms.XXXXXX)
      export MSHELL_DEV
      case "${WAYLAND_DISPLAY:?}" in
          /*) ;;
          *) export WAYLAND_DISPLAY="${XDG_RUNTIME_DIR:?}/$WAYLAND_DISPLAY" ;;
      esac
      unset DISPLAY WAYLAND_SOCKET HYPRLAND_INSTANCE_SIGNATURE QT_QPA_PLATFORMTHEME
      export QT_QPA_PLATFORM=wayland QT_NO_XDG_DESKTOP_PORTAL=1
      export XDG_CONFIG_HOME="$MSHELL_DEV/config" XDG_RUNTIME_DIR="$MSHELL_DEV/r"
      export XDG_CACHE_HOME="$MSHELL_DEV/cache" XDG_STATE_HOME="$MSHELL_DEV/state" XDG_DATA_HOME="$MSHELL_DEV/data"
      MSHELL_CONFIG="$XDG_CONFIG_HOME/quickshell/mshell"
      mkdir -p "$MSHELL_CONFIG" "$XDG_RUNTIME_DIR" "$XDG_CACHE_HOME" "$XDG_STATE_HOME" "$XDG_DATA_HOME"
      chmod 700 "$XDG_RUNTIME_DIR"
      tar --exclude='./.git' -cf - . | tar -xf - -C "$MSHELL_CONFIG"
      dbus-run-session -- bash --noprofile --norc
  )
  hyprctl eval 'if mshell_dev_rule then mshell_dev_rule:set_enabled(false) end'
  ```

- Inside the development shell, start Hyprland and select its Wayland display and IPC instance. The short runtime path keeps Hyprland's sockets within the Unix socket path limit.

  ```bash
  cat > "$XDG_CONFIG_HOME/hyprland.lua" <<'LUA'
  hl.monitor({ output = "", mode = "preferred", position = "auto", scale = 1 })
  hl.config({ xwayland = { enabled = false } })
  LUA
  Hyprland --config "$XDG_CONFIG_HOME/hyprland.lua" > "$MSHELL_DEV/hyprland.log" 2>&1 &
  MSHELL_HYPR_PID=$!
  for attempt in {1..100}; do
      MSHELL_LOCK=$(find "$XDG_RUNTIME_DIR/hypr" -name hyprland.lock -print -quit 2>/dev/null)
      [ -f "$MSHELL_LOCK" ] && break
      kill -0 "$MSHELL_HYPR_PID" || break
      sleep 0.1
  done
  if [ -f "$MSHELL_LOCK" ]; then
      export HYPRLAND_INSTANCE_SIGNATURE="$(basename "$(dirname "$MSHELL_LOCK")")"
      export WAYLAND_DISPLAY="$(sed -n '2p' "$MSHELL_LOCK")"
      hyprctl monitors
  else
      cat "$MSHELL_DEV/hyprland.log"
  fi
  ```

- Run in the sandbox: `qs -c mshell` (logs in the terminal; QML errors go to stderr)
- To stop, interrupt Quickshell with Ctrl+C, run `hyprctl dispatch 'hl.dsp.exit()'` and `wait "$MSHELL_HYPR_PID"` in the development shell, then run `exit` to disable the temporary host rule.
- Tests: `node --test "tests/**/*.test.js"` (Node 22+)
- Unused-file check: `sh tools/unused.sh`
- IPC in the sandbox: `qs -c mshell ipc call <target> <fn>`
