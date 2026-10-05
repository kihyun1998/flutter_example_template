# The shell page composition

## What it is
The page the rest of the example is built in, and — more importantly — the place that holds
the state nobody else can reach. A menu, and while a destination is open, a preview stage and
a knob region. This territory owns the *assembly*: which regions exist, who decides the
current mode, and what the shell keeps private.

It is a separate territory from the regions it composes because its defects are not their
defects. That no consumer could add a stage mode (#18) was a fact about where state lives,
not about how a viewport draws.

## Governing decisions
→ [ADR-0014 — the room is a mode, and it is not the default](../../adr/0014-the-room-is-a-mode-and-not-the-default.md)

It governs which modes the shell offers, the order they are offered in, and which one it
opens on. Adjacent: ADR-0005 decides that a roster supplying no stage destinations leaves the
menu alone on the page — it decides an absence in the menu, not the composition. Nothing
governs the region model or the breakpoint.

## Design model
**Nothing here names a destination.** The set arrives through `ShellDestinations`, and the
bar's title with it, because both are the one thing a shell around a different package could
not reuse. The list used to be a field of this state, which is what made a page that knows
nothing about recipes import every one of them.

**A full page is pointed at, not absorbed.** `RouteDestination` opens on its own route rather
than being taken apart to fit the stage.

**The shell holds the selected id, not the selected object**, so `ShellMenu` and the stage
both walk `all` on the same frame rather than holding references that could diverge.

**The shell creates the port with its state and disposes it with its state.** What it no
longer does is know what is in it.

**The toolbar scrolls sideways rather than overflow.** It is one row: the Code control, a
spacer, the Fit control and the viewport bar. Below the width that row needs, it scrolls.
Measured 2026-09-23 before the change, at 800 px tall: with the Code control showing, every
width from 400 to 690 px overflowed, and adding the Room segment moved that to 750 px.
`test/shell_page_test.dart` walks 400 to 890 px in 10 px steps, with and without the Code
control.

**Two constants set the layout**: a knob region width and a narrow breakpoint. Both are
static on the widget, which makes them readable by a consumer and settable by nobody.

**Mode is private state, so the modes are this package's to offer.** `_viewportId`,
`_lastViewportId` and the derived `_showingWall` and `_showingRoom` live on `_ShellPageState`.
ADR-0014 keeps it that way: the room was added here rather than by opening the state to
consumers. The room counts as a single-viewport mode, so a forced exit from the wall returns
to it, and the Fit control is hidden in it as in the wall.

## Code
`lib/src/shell/shell_page.dart` — `ShellPage`
`test/shell_page_test.dart` — the region layout across the narrow breakpoint

## Reference behaviour
**None.**

Never compared to a reference. The Flutter SDK is spec-binding for `Navigator` and
`State` lifecycle behaviour and is reachable raw — see
[`docs/agents/thegraph.md`](../../agents/thegraph.md).

## Cross-cutting invariants
→ [a subject is evidence, never vocabulary](../invariant/subject-is-evidence-never-vocabulary.md)

## Blast radius
→ [the preview stage](preview-stage.md) — the mode is chosen here from private state; a new
  mode cannot be added anywhere else
→ [the menu and roster](menu-and-roster.md) — the selected id is held here, so roster identity
  changes surface as selection bugs in this file
→ [the seam](the-seam.md) — the port's lifetime is this state's lifetime
→ [the settings panel](settings-panel.md) — the knob region's width is set here, and the panel
  must lay out inside it

## Known holes / open
- **A host still cannot add a stage mode**, and that is now a decision rather than a hole
  (ADR-0014): the state is private and unseedable, and `ViewportSpec.byId` throws on an
  unknown id. A consumer asking for another mode is asking this package.
- Nothing records why the breakpoint is 900 or the knob region 320. Both are static
  constants with doc-comments describing what they do and not what set them.
