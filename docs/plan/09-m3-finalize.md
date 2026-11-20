# 09 — M3 finalization (containers and surface behavior)

The [overview](00-OVERVIEW.md#how-to-work-a-step) defines the order. This step uses the existing panels, notification flow, and OSD. Make it easy to tell which component owns a surface, where its tokens are defined, and how the window behaves. The shared `ValueSlider` is covered in [step 10](10-slider.md) and general polish in [step 11](11-polish.md).

## 9.1 Container roles and ownership

Read [TOKENS.md](../design/TOKENS.md), [COMPONENTS.md](../design/COMPONENTS.md), [STRUCTURE.md](../conventions/STRUCTURE.md), and [LEAN.md](../conventions/LEAN.md). Review `components/{Surface,PopupWindow,AnchoredPopup,Dialog,Pill,Tile}.qml`, `modules/controlcenter/PowerMenu.qml`, `modules/notifications/{NotifCard,NotifGroup,NotifToast}.qml`, and `modules/osd/Osd.qml`.

- [x] Extend the existing **Which role for what** table in `TOKENS.md`. It defines the background and shape of each role. `COMPONENTS.md` maps roles to files, and [BEHAVIOR.md](../design/BEHAVIOR.md) defines layers, focus, and dismissal.
- [x] Add two rows that share `Shape.full`. Bar pills use a transparent background at rest and `secondaryContainer` when active. The OSD uses `surfaceContainer`.
- [x] Document `Card` with `surfaceContainerHigh` and `Shape.large`. Preserve the smaller inner corners in notification groups. `NotifToast` uses the same card.
- [x] Check `Tile` against its current tokens. It uses `surfaceContainerHigh` when inactive, `primary` when active, and `Shape.extraLarge` for its corners. Confirmation dialogs use `surfaceContainerHigh`, `Shape.extraLarge`, and a scrim through `Dialog.qml`.
- [x] Keep `Surface.qml` as the shared primitive for background, shape, and optional shadow. It accepts a `container` color and a radius and owns `RectangularShadow`. Use the shared `Theme.popupShadow` for popup shadows. Cards, tiles, and bar pills use their tonal fills to establish hierarchy.
- [x] Check `Tile.qml`, `Pill.qml`, `PopupWindow.qml`, and `NotifCard.qml` against the agreed roles. Use named tokens for the colors and radii. Use Panel, Card, Tile, Pill, OSD, and Dialog consistently in documentation and implementation comments.

### File hierarchy

This is the current tree for the surfaces reviewed in this step. The audit below checks how those surfaces are assembled and styled.

```text
components/                     Reusable UI building blocks
  Surface.qml                   Shared background, shape, and shadow primitive
  Pill.qml, Tile.qml, Button.qml Reusable controls and their state treatments
  PopupWindow.qml               Layer-shell window, positioning, focus, and Surface
  AnchoredPopup.qml             Lifecycle and transitions for anchored popups
  Dialog.qml                    Centered modal confirmation with a scrim

modules/                        Feature content and feature-specific behavior
  controlcenter/                Panel content, pages, and inline power dropdown
  notifications/                Notification Center, cards, and toast windows
  osd/, calendar/, keyboard/    Feature-specific windows and content
  bar/pills/                    Feature-specific wrappers around Pill

config/                         Shared design tokens
  Theme.qml                     Color roles and popup shadow parameters
  Shape.qml                     Corner radii
  Sizing.qml                    Sizes and spacing
  Motion.qml                    Animations and timing
```

Use [STRUCTURE.md](../conventions/STRUCTURE.md) for the folder boundaries. A feature selects a documented role and composes the shared building blocks with tokens from `config/`. Reuse `Surface` with its existing properties for visual variants. This keeps the shared window and container implementation in one place and makes feature files responsible for their own content.

### Audit existing surface construction

The source audit covered all 56 QML files in `components/` and `modules/`. It traced the windows assembled by `shell.qml`, checked the design tokens in `config/`, and compared each in-scope base background and its owner against the agreed roles. Visual and input checks are listed in 9.2 and 9.3.

| Surface | Implementation before 9.1 | Work in step 09 |
|---|---|---|
| Shared primitive | `Surface.qml` is the sole owner of `RectangularShadow` and uses `Theme.popupShadow`. | Reuse the existing shadow and component properties. |
| Anchored panels | Control Center, Notification Center, Calendar, and the keyboard layout picker already follow `AnchoredPopup → PopupWindow → Surface → content`. `PopupWindow` already uses `surfaceContainer` and `Shape.extraLarge`. | Enable the shared shadow and check its window bounds in 9.2. |
| Tile | `Tile.qml` paints its base background in a `Rectangle`. Its fill and corner radius already use the right tokens. | Reuse `Surface` for the base background while preserving the state layer and icon-chip treatment. |
| Power dropdown | The existing inline menu uses `Surface` with `surfaceContainerHigh` and `Shape.large`. | Apply the agreed compact `Panel` tokens in 9.2. |
| Bar pill and OSD | Both use `Surface` and `Shape.full` with their own current colors. | Record separate token rows and verify the existing appearance. |
| Notification card and toast | `NotifCard` uses `Surface` and `surfaceContainerHigh`. The toast reuses that card, and grouped cards use smaller inner corners. | Document and verify the existing card treatment. |
| Confirmation dialog | `Dialog.qml` uses a centered `Surface` with the agreed tokens and a separate scrim. | Verify the existing dialog treatment. |

- [x] Check the audited backgrounds for literal colors and corner sizes. The audit found none in the reviewed roles. `sh tools/unused.sh` also passed on the audited source.
- [x] Replace the tile's base background with `Surface` and verify active, inactive, hover, pressed, and focus appearance. Keep inner indicators, icon chips, borders, and scrims as elements within their respective controls and surfaces.

Verified the five Tile states in Control Center on a headless output within nested Hyprland. Also checked the bar Pill at rest and with Control Center open, the notification toast Card, and the OSD using simulated display brightness. All 89 model tests and the unused-file check passed.

The transparent bar window and native lock surface have their own window roles. The audit also checked the notification history cards, tooltip, selectable rows, and calendar cells. `Button`, `IconButton`, `TextField`, and `NotifActionButton` draw their own token-based stateful control backgrounds. Their control treatments are outside the base container fixes in this step.

## 9.2 Panels and the power menu

Read `components/{AnchoredPopup,PopupWindow,Surface}.qml`, `components/PopupWindow.model.js`, `tests/components/PopupWindow.model.test.js`, `modules/controlcenter/PowerMenu.qml`, `config/{Theme,Shape,Sizing}.qml`, and sections 1, 2, and 6 of [BEHAVIOR.md](../design/BEHAVIOR.md).

### Shared panel setup

```text
AnchoredPopup   Lifecycle, anchor, and preferredWidth
└─ PopupWindow  Layer-shell window, placement, and focus grab
   └─ Surface   surfaceContainer, Shape.extraLarge, shadow enabled
      └─ Content supplied by the module, such as PageStack or Column
```

Control Center, Notification Center, Calendar, and the keyboard layout picker use this structure. Set a panel's desired width with `preferredWidth`. The module owns its pages and contents. `PopupWindow` owns positioning, focus, input bounds, and the panel background.

### Surfaces with their own window behavior

- The **power dropdown** is a compact `Panel` variant inside the Control Center window. Its actions that require confirmation open `Dialog.qml`.
- The **OSD** uses its own `PanelWindow` with a click-through input region, no keyboard focus, and a full-radius `Surface` at the bottom center of the focused monitor.
- The **confirmation dialog** has a centered `Surface` and its own scrim. `Dialog.qml` owns its modal behavior.
- A **notification toast** displays a `NotifCard` in the notification stack. The toast window owns its input region, and each toast owns its timeout.

### Panel code and verification checklist

- [ ] Keep the shared `AnchoredPopup → PopupWindow → Surface` structure for Control Center, Notification Center, Calendar, and the keyboard layout picker. Use `surfaceContainer`, `Shape.extraLarge`, and the soft shadow from `Theme.popupShadow` for large panels.
- [ ] Check that the shadow is visible along the window edges. Add transparent space for the blur in `PopupWindow` if needed. `preferredWidth` defines the visible panel width, and the input region matches the panel itself. Verify placement near screen edges and dismissal when clicking outside. Update the existing placement model and tests if the geometry calculation changes.
- [ ] Style the power dropdown as a compact `Panel` variant. Use `surfaceContainer` and `Shape.extraLarge` in the existing menu inside Control Center. Verify that the menu boundary is visible against the panel. Continue to use `Dialog.qml` for confirmations.
- [ ] Review the existing surfaces in nested Hyprland. Check the four large panels, power dropdown, notification card, toast, bottom-center OSD, and dialog. Check the shadow against light and dark backgrounds.

### Behavior to verify

[BEHAVIOR.md](../design/BEHAVIOR.md) owns the full rules for layers, focus, and dismissal. Check the following interactions when verifying the container changes.

- The bar stays on the `Top` layer and leaves keyboard focus with the active application.
- Anchored panels use `Overlay` and `OnDemand` while open. Check dismissal via outside click, `Esc` at the root page, and a second click on the owning pill. Check that opening another panel swaps the current panel through the existing fade-through transition and that the owning pill displays `secondaryContainer` while its panel is open.
- The notification stack uses `Overlay`. Check toast expiry, explicit dismissal, and action handling. The source proposal also mentions swipe dismissal. Treat any new swipe handling as a separate interaction decision.
- The OSD uses `Overlay` and accepts neither pointer nor keyboard input. Verify its existing timeout and dismissal on Control Center open, session lock, or output removal.
- Confirmation dialogs use `Overlay`, `Exclusive` keyboard focus, and a scrim. Verify confirm, cancel, `Esc`, and scrim dismissal.

## 9.3 Reply focus in notification toasts

Read `modules/notifications/{NotifPopupWindow,NotifToast,NotifCard,NotifReply}.qml`, the [focus rules](../design/BEHAVIOR.md#1-surfaces-and-layers), and the [existing Reply checks](05-notifications.md#follow-up-notification-layout-and-reply-editor).

The source currently switches to `OnDemand` with `HyprlandFocusGrab` while replying. The paragraph below the layer table in `BEHAVIOR.md` still says `Exclusive` and needs to match the verified Reply behavior.

- [ ] Keep `WlrKeyboardFocus.None` for a regular toast and `OnDemand` while replying. Remove `HyprlandFocusGrab` from the toast reply flow. Use regular window activation and Wayland/Qt focus events. Scope this change to Reply in notification toasts.
- [ ] Verify that the field accepts text immediately after the first click on **Reply**. Losing focus closes the editor and preserves the draft. Reopen Reply and check that the text is restored. `Esc` discards the draft. `Enter` sends a nonempty reply.
- [ ] Test switching to another window, clicking to transfer focus to that window, and moving the pointer while focus stays in the editor. Verify that a regular notification leaves keyboard input with the active application. Check the editor in Notification Center if a shared component changes. Update `BEHAVIOR.md` to match the verified behavior.

## Completion checks

- [ ] Keep the implementation focused on container styling and the scoped toast Reply change. Reuse the existing popup lifecycle, feature content, and elevation tokens. General motion, typography, responsiveness, and cleanup are tracked in [step 11](11-polish.md).
- [ ] Record the agreed roles, variants, colors, radii, and shadow rules in `TOKENS.md`.
- [ ] Record file ownership and folder boundaries in `STRUCTURE.md`. Document the shared panel setup in `COMPONENTS.md`, including `AnchoredPopup → PopupWindow → Surface → content`, `preferredWidth`, and the separate OSD, toast, and dialog paths. Update `NAMING.md` if component relationships change.
- [ ] Record the verified layer, focus, and dismissal rules in `BEHAVIOR.md`, including the toast Reply behavior. Link the rules from the plan and component catalogue where relevant so the documentation has one owner for each rule.
- [ ] Check for hardcoded colors and radii in the affected components. Verify that shared primitives still have consumers and that each reviewed surface follows its documented role.
- [ ] Run the verification scenarios in nested Hyprland as described in `AGENTS.md`. Run the model tests and `sh tools/unused.sh`, check the file size limits in `LEAN.md`, mark the completed checks, and update the plan overview.

## Quick reference

- Look up the background, shape, and emphasis for Panel, Card, Tile, Pill, OSD, and Dialog in [TOKENS.md](../design/TOKENS.md#which-role-for-what-shell-mapping-project).
- Find the implementation and existing reusable components in [COMPONENTS.md](../design/COMPONENTS.md).
- Look up layer, focus, and dismissal behavior in [BEHAVIOR.md](../design/BEHAVIOR.md).

Use these M3 references to review the project's mappings. [Tone-based surfaces](https://m3.material.io/blog/tone-based-surface-color-m3) · [Color roles](https://m3.material.io/styles/color/the-color-system) · [Shape scale](https://m3.material.io/styles/shape/corner-radius-scale) · [Shadows and elevation](https://m3.material.io/styles/elevation/applying-elevation) · [Card guidelines](https://m3.material.io/components/cards/guidelines) · [Card specs](https://m3.material.io/components/cards/specs) · [Bottom sheets](https://m3.material.io/components/bottom-sheets/guidelines) · [Side sheets](https://m3.material.io/components/side-sheets/guidelines)
