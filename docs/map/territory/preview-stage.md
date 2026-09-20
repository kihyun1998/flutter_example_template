# The preview stage

## What it is
Making a subtree believe it is running somewhere it is not. A stage constrains a subtree to
a named viewport and tells it that is the whole screen; a frame is that stage scaled to fit
the room available; the wall is every viewport at once over one set of knobs. This territory
owns *what a viewport is and how it is drawn* — which modes the shell offers, and who may
switch between them, is [the shell page composition](shell-page-composition.md).

## Governing decisions
**None.**

Five public types, and not one governing record. Adjacent: ADR-0005 decides that unclaimed
capabilities are silent, which is why `allowsWall` can be false without leaving a gap — it
decides drawing, not the viewport model. `device wall` and `screenshot` appear in no record
in this repository, by title or body.

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

**`ViewportSpec.values` is the only roster of viewports there is**, which is why the wall is
selected by an id rather than by a fourth `ViewportSpec` that would have to invent a size
and a chrome policy.

## Code
`lib/src/preview/viewport_spec.dart` — `ViewportSpec`
`lib/src/preview/preview_stage.dart` — `PreviewStage`, `ViewportBar`
`lib/src/preview/preview_frame.dart` — `PreviewFrame`
`lib/src/preview/device_wall.dart` — `DeviceWall`

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
  private state, and that is where issue #18 lands
→ [the menu and roster](menu-and-roster.md) — `StageDestination.allowsWall` gates the wall
  per destination
→ [the theme and chrome](theme-and-chrome.md) — `showsChrome` decides whether the shell keeps
  its furniture at a given width, so a viewport change moves chrome
→ [the published artifact](published-artifact.md) — the screenshots on pub.dev are captures of
  these modes

## Known holes / open
- **Every mode scales, so no mode shows the subject at the size of the window it is actually
  running in.** `_stageRegion` has two branches and both scale; `fit: false` renders 1:1 and
  clips, which the field's own doc-comment says answers a different question. A host cannot
  add the missing mode: the state is private, `ViewportSpec.byId` throws on an unknown id,
  `StageDestination` carries nothing meaning *draw me unframed*, and the barrel forbids
  assembling a second shell out of the exported parts. Measured on `flutter_table_plus` at
  1440x900: the desktop viewport draws at 0.589x. Tracked: #18.
- No record decides the viewport set itself — why three, and what would justify a fourth.
