# The room is a mode, and it is not the default

The stage offers another mode, **Room**: the stage region at its own size, at 1:1, in place of a
named viewport. It sits beside the three named viewports and the wall, never scales, and tells the
subject the truth about the box it was given. The shell still opens on `desktop`.

Every other mode scales. A named viewport is shrunk to fit the region, and the wall puts three of
those side by side, so no mode let a reader *use* the subject at real pixels — drag-select, resize a
column, double-click a cell — against hit targets and text the size they will be in the reader's own
app. Measured 2026-09-20 in this repository, with a bare `Text` as the only destination: a 1440 × 900
window draws the `Desktop · 1440 × 900` viewport at 0.589×. A consumer could not add the mode
itself: the mode is private state, `ViewportSpec.byId` throws on an unknown id, and ADR-0006 rules
out assembling a second shell from the exported parts (#18).

## What was decided, and which kind of call each one is

**Judgements**, made by the maintainer on 2026-09-20 with the alternatives beside them. A better
argument does not reopen these; the maintainer does.

- **The mode is added inside this package**, not by opening the shell's mode state to consumers.
- **It is called Room**, and the widget `PreviewRoom`. Rejected: *Native*, which in a Flutter
  package means platform code; *Unframed*, which is defined by what it lacks, where no other term in
  `CONTEXT.md` is.
- **The room is the stage region as it already is.** The menu and the knob region stay. Collapsing
  them to reach the window's full width was rejected: the reader turns knobs *while* using the
  subject, and at 1440 × 900 the screen area barely moves anyway — 848 px framed against 888 px in
  the room. What the mode offers is honesty about size, not more area.
- **The default stays `desktop`.** Changing it would change every existing consumer's first frame
  with no deprecation path, and it would contradict the premise in `ViewportSpec`'s library
  doc-comment: what a desktop-sized demo can never show on its own is what happens when there is not
  room.
- **No destination can refuse the room.** `allowsWall` exists because three copies of an expensive
  subject turn a frame rate into a measurement of the wall. The room draws one copy, unscaled, and
  costs less than any mode that already exists.
- **The caption stays** and reads the live size at `1:1`, because a room has no fixed size to put in
  its segment label. The Fit control is hidden, because a room is never scaled.
- **The segments run desktop · tablet · mobile · room · wall**, with the wall last because it is the
  segment that can disappear.

**Derivations**, which fall to a better derivation.

- **The room overrides `MediaQuery` to the size it hands the subject**, and zeroes `padding`,
  `viewInsets` and `viewPadding` as `PreviewStage` does. Measured 2026-09-23 in the shell, in a
  1440 × 900 window: a stage drawn straight into the region is told `1440 × 900` while it is laid
  out at `888 × 774`. That is the lie `PreviewStage`'s override exists to prevent, the other way
  round, and a consumer's branch on `MediaQuery.of(context).size` would take the desktop arm without
  anything looking wrong.
- **The destination's stage is built below that override**, through a `Builder`, as the wall already
  builds it. Handed an already-built `open.stage(context)`, the builder's own body runs with the
  shell's context and is told the window while everything it returns is told the room.
- **The room adds no overlay of its own.** `PreviewStage` contains one because the subject was drawn
  at 0.46× while drag feedback went to the root overlay at 1:1, measured 2026-08-26 at 91.7 px
  against 200 px. At a scale of 1.0 that mismatch cannot happen, and the root overlay being the
  nearest one is what a real app has. Feedback can be drawn over the menu and the knob region as a
  result.

## Consequences

`PreviewRoom` is public, and the seam test requires it to be: every file under `lib/src/` is
exported. The caption is shared by making `PreviewFrame.labelHeight` and `PreviewFrame.labelFor`
public rather than copying them. The caption's text style is still written out in both widgets.

`ViewportBar` offers the room only when its host passes `showsRoom`, which defaults to false for the
reason `showsWall` does: a host that draws one frame has no room to offer, and would hand the id to
`ViewportSpec.byId`, which throws on it. `ShellPage` passes true. This is a derivation, added before
0.3.0 was published.

**This record does not cover** what the room looks like below `ShellPage.narrowBreakpoint`, where
the stage region is a full-width tab. The tests cover only the wide layout. The pub.dev screenshots
are not covered either, and no capture of the room exists. A consumer constrained to `^0.1.0` or
`^0.2.0` cannot get the mode until a release carries it and the consumer widens its constraint.
