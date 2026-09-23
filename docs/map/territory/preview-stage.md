# The preview stage

## What it is
Making a subtree believe it is running somewhere it is not. A stage constrains a subtree to a
named viewport and tells it that is the whole screen; a frame is that stage scaled to fit the
room available; the room is the region at its own size, at 1:1, with no named viewport; the
wall is every viewport at once over one set of knobs. This territory owns *what a viewport is
and how it is drawn* — which modes the shell offers, and who may switch between them, is [the
shell page composition](shell-page-composition.md).

## Governing decisions
→ [ADR-0014 — the room is a mode, and it is not the default](../../adr/0014-the-room-is-a-mode-and-not-the-default.md)

It governs the room: that it exists, what it tells the subject, and what it leaves out. The
other five public types are still governed by no record. Adjacent: ADR-0005 decides that
unclaimed capabilities are silent, which is why `allowsWall` can be false without leaving a
gap — it decides drawing, not the viewport model. `screenshot` appears in one record,
ADR-0014, and only as something it does not cover.

## Design model
**A stage never scales; a frame does.** That separation is the model's spine.
`PreviewStage` lays the child out at the spec's size and overrides `MediaQuery`;
`PreviewFrame` wraps that in a `FittedBox` and captions it with its dimensions and factor.

**Two things happen in the stage and they are not the same thing.** The `SizedBox` makes the
subject narrow. The `MediaQuery` override is for everything *else* in the frame — a recipe
is consumer code, and consumer code is entitled to branch on `MediaQuery.of(context).size`;
a phone preview reporting the desktop width would take the wrong arm silently. **The earlier
claim that the override was needed to make the subject itself behave was measured and is
false**, and the doc-comment keeps the withdrawal rather than the claim.

**The stage owns an overlay, and that is a third thing.** `Draggable` puts feedback in the
*nearest* `Overlay`. With none inside the frame, that is the app's root overlay, which sits
above the `FittedBox` — so the subject draws at 0.46x and the thing dragged out of it at 1:1.
Measured 2026-08-26: 91.7px against 200px. A real viewport contains its own overlay.

**Every wall frame is live, and that was decided against the originating ticket's own
acceptance criteria.** Both reasons for the criterion were measured and did not survive.
`Transform` applies the inverse to hit testing, so a drag inside a half-size frame selects
exactly the rows it crosses. And the three frames do not share a scale — each viewport is
fit into an equal column, so measured 2026-09-01 at 1800px: desktop 0.28x, tablet 0.48x,
**mobile 1.0x**. The narrowest viewport is the one drawn at full size.

**The room is honest about size and makes no other claim.** `PreviewRoom` hands the subject
the region less the caption, and overrides `MediaQuery` to exactly that box, with the insets
zeroed as `PreviewStage` zeroes them. That override is the part of the room that carries the
load. Measured 2026-09-23 in the shell, in a 1440 × 900 window: a stage drawn straight into
the region is told `1440 × 900` and laid out at `888 × 774`. It adds
**no overlay**. The 0.46× mismatch that
made `PreviewStage` contain one cannot happen at 1.0, so drag feedback goes to the root
overlay and can pass over the menu and the knob region, as it would in a real app.

**Every mode builds the stage below its own override**, through a `Builder`, so a stage
builder's own body is told what the subtree it returns is told. Handed an already-built
`open.stage(context)`, the body runs with the shell's context instead. Measured 2026-09-23 in
the mobile viewport before the framed modes were changed: the body was told `1440 × 900` and
the subtree `390 × 844`. The wall always built it this way.

**What the room buys is honesty, not area.** At 1440 × 900 the framed desktop viewport covers
848 px of screen and the room covers 888 px, so the difference is almost none. What changes is
that the subject is no longer told it has 1440.

**`ViewportSpec.values` is the only roster of viewports there is**, which is why the room and
the wall are selected by an id rather than by a fourth `ViewportSpec` that would have to invent
a size and a chrome policy.

## Code
`lib/src/preview/viewport_spec.dart` — `ViewportSpec`
`lib/src/preview/preview_stage.dart` — `PreviewStage`, `ViewportBar`
`lib/src/preview/preview_frame.dart` — `PreviewFrame`
`lib/src/preview/preview_room.dart` — `PreviewRoom`
`lib/src/preview/device_wall.dart` — `DeviceWall`
`test/preview_stage_test.dart` — `ViewportSpec` and `PreviewStage`
`test/preview_frame_test.dart` — fitting, and interaction through the scale
`test/device_wall_test.dart` — every viewport at once, every frame live
`test/preview_room_test.dart` — `PreviewRoom`

## Reference behaviour
**None.**

Never compared to a reference. The Flutter SDK is the spec-binding source for `MediaQuery`,
`FittedBox` and `Overlay` behaviour and is reachable raw — see
[`docs/agents/thegraph.md`](../../agents/thegraph.md). The `Transform` hit-testing claim
above is a measured local probe, not a pin into that source, and the two are not
interchangeable.

## Cross-cutting invariants
→ [never hand-maintain a roster](../invariant/never-hand-maintain-a-roster.md)
→ [a subject is evidence, never vocabulary](../invariant/subject-is-evidence-never-vocabulary.md)

## Blast radius
→ [the shell page composition](shell-page-composition.md) — the mode is chosen there, from
  private state, so a new mode is added there or nowhere
→ [the menu and roster](menu-and-roster.md) — `StageDestination.allowsWall` gates the wall
  per destination
→ [the theme and chrome](theme-and-chrome.md) — `showsChrome` decides whether the shell keeps
  its furniture at a given width, so a viewport change moves chrome
→ [the published artifact](published-artifact.md) — the screenshots on pub.dev are captures of
  these modes

## Known holes / open
- No record decides the viewport set itself — why three, and what would justify a fourth.
- **The room is untested below the breakpoint**, where the stage region is a full-width tab.
- The caption's text style is written out in both `PreviewFrame` and `PreviewRoom`.
- **On a phone, the room tells the subject there are no insets.** A home indicator at the
  bottom of the window covers about 8 px of the subject's box, by arithmetic from a 34 px
  inset and the 26 px caption; it has not been measured on a device. On a desktop window the
  insets are zero and nothing differs. Left as it is, by the maintainer's call on 2026-09-23.
