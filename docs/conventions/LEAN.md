# LEAN — how this stays a small shell

The failure mode is a pile of code nobody uses. These rules exist to prevent it. They override convenience.

1. **Plan first.** Create only files listed in the current plan step. If you need one that isn't listed, add it to the plan (with its consumer) before creating it.
2. **Every file has a consumer.** By the end of a step, `sh tools/unused.sh` must print nothing. Only exception: a file the plan explicitly says is consumed by the *next* step; the next step must consume it or you delete it.
3. **Rule of two for components.** A component starts inside the module that needs it. Move it to `components/` only when a second module needs it. Exception: the base set named in plan step 02.
4. **No config nobody asked for.** The only settings are `accent` and tile `order`. A new key requires a SPEC change first.
5. **No abstraction with one implementation.** No interface layers, factories, or "manager" classes. `Compositor` is Hyprland-only (user runs Hyprland); add another only if the user switches.
6. **No speculative states.** Don't build an "error variant", "loading variant", "compact variant" until a screen needs it.
7. **Replace = delete.** When something is superseded, delete the old file in the same change. No `Old.qml`, no `_backup`, no commented-out code.
8. **Tokens only.** A literal number or color in a component is a bug.
9. **One fact, one owner.** If a service has it, UI doesn't recompute or re-fetch it.
10. **Size budgets.** QML ≤ 200 lines, model ≤ 150, function ≤ 30. Over budget = split, or the design is wrong.
11. **Small commits.** One plan step (or sub-step) per commit: `04.3: ValueSlider`. Never mix two steps.
12. **Stop at "Done when".** Finishing a step means stopping. General polish is covered by [step 11](../plan/11-polish.md).

## End-of-step checklist
- [ ] Only planned files created/changed
- [ ] `sh tools/unused.sh` clean
- [ ] Tests pass
- [ ] No literals, no commented code, no console.log, no TODO comments
- [ ] Step file ticked, `00-OVERVIEW.md` table updated
