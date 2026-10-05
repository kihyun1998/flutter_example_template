## 0.3.0

**Added**

* A stage mode, **Room**, between the phone viewport and the Device Wall: the
  stage region at its own size, at 1:1, in place of a named viewport. Every mode
  before it scaled, so a reader could look at a subject but never use it at real
  size — at 1440 × 900 the desktop viewport draws at 0.589×. The room never
  scales, hands the subject the region less its caption, and tells it through
  `MediaQuery` that this box is the whole screen. Without that, a stage drawn
  straight into the region is told 1440 × 900 while it is laid out at 888 × 774,
  and a consumer's branch on the screen size takes the wrong arm. It adds no
  overlay of its own, has no Fit control, and is offered for every destination.
  The shell still opens on the desktop viewport. ADR-0014 records why. (#18)
* `PreviewRoom`, the widget behind the mode, exported like `PreviewFrame` and
  `DeviceWall` and usable without the shell.
* `ViewportBar.roomId`, `ViewportBar.roomLabel` and `ViewportBar.showsRoom`.
  The room is offered only where a host asks for it, as the wall is: a
  `ViewportBar` used on its own keeps the three named viewports, so a host that
  passes the selection to `ViewportSpec.byId` is never handed an id it throws
  on. `ShellPage` asks.
* `PreviewFrame.labelHeight` and `PreviewFrame.labelFor`, the caption both of
  them share.

**Fixed**

* A destination's `stage` builder is now told the viewport it is drawn in,
  in the framed modes as well as the wall. Its own body ran with the shell's
  context, so `MediaQuery.sizeOf(context)` read there answered with the window
  — 1440 × 900 in the mobile viewport, while the widgets it returned were told
  390 × 844. A builder that branches on the screen size in its body now takes
  the arm the viewport calls for.
* The stage's toolbar scrolls sideways instead of overflowing when the window
  is too narrow for it. Measured in 0.2.0 at 800 px tall, with the Code control
  showing: every width from 400 to 690 px overflowed. The Room segment would
  have widened that to 750 px, and started it at 400–450 px for a destination
  with no Code control.

**Also in this release**

* `PreviewStage`, `PreviewFrame`, `ViewportSpec` and `DeviceWall` have suites
  here. They had none: the ones that held them were left behind in the
  repository the shell was extracted from, and the "interaction survives the
  scale" test their doc-comments cite was among them. The properties are
  carried over without the table they were written against, and each test was
  seen failing against a mutation of the code it guards.

## 0.2.0

**Changed**

* `ShellMenu` no longer draws a header, or a *nothing here yet* line, for a
  category the roster left empty. A category cannot be claimed — `ShellCategory`
  is a fixed enum and the roster is the only input — so an empty one is a
  capability nothing supplied, and ADR-0005 already said those draw nothing. A
  menu now grows a section when the first destination of that kind arrives,
  which is the cost. Reported against 0.1.0 by a consumer with eleven recipes
  and no scenarios, whose menu got emptier-looking as its example got better.
  (#11)
* A roster holding nothing at all says so once, in the menu, rather than three
  times by category. With the fix below that state is the whole screen, and it
  is the one a reader cannot tell from a build that failed.

**Fixed**

* `ShellPage` no longer throws `Bad state: No element` when the roster it is
  handed holds no `StageDestination`. A roster of `RouteDestination`s alone is
  a legal one — that is what `RouteDestination` already promised — and the
  shell now draws the menu alone for one, with no stage, no knob region and no
  tab bar over them. ADR-0005 records why those are absent rather than empty.
  Reported against 0.1.0 by a consumer adopting the shell before its first
  recipe existed, which is the one shape that could not start. (#10)

**Also in this release**

Neither of these changes what a consumer gets; both are the repository holding
itself to what it already claims.

* `tool/screenshots.sh` waits for two identical consecutive frames before it
  captures, rather than for the semantics tree to report the state. It used to
  photograph whatever animation phase the label check happened to land on, and
  the README images moved for that rather than for any UI change (#14).
* The capture platform is macOS, and it is now written down and announced
  instead of implied. The committed set had been captured on two machines, and
  Material centres an `AppBar` title on a Mac and left-aligns it everywhere
  else — 99.5% of the drift in `code-pane.png` was that one line (#14).

## 0.1.0

First release. The shell was built inside the example app of a Flutter table
package over roughly a dozen tickets, extracted once it had been proven
portable, and rebuilt here around three ports.

**What a consumer gets**

* `ShellPage` — a category menu, a preview stage and a knob region, holding one
  destination at a time.
* `PreviewStage`, `PreviewFrame` and `ViewportSpec` — a subtree rendered as if it
  were running at desktop, tablet or phone size: constrained, told that is the
  whole screen, and given its own `Overlay` so tooltips and drags stay inside the
  frame.
* `DeviceWall` — all three viewports at once, live, over one shared state. The
  single-viewport modes answer what something looks like at a width; the wall
  answers what changed between them.
* `CodePane` — a recipe's own source, read out of the asset bundle so what is on
  screen and what executes cannot disagree. `flutter_syntax_highlight` tokenizes
  it into a partition, so concatenating every token reproduces the file byte for
  byte, and this package decides only what a kind looks like.
* `PresetBar`, `FeatureListPane`, `FeatureDetailPane` — a settings panel drawn
  from a description of groups, features, options and the interactions between
  them, with search over control labels.
* `MetricsPanel` and `MetricsChip` — named readings the consumer formats and
  assigns a severity, since the thresholds belong to whoever knows what is being
  measured.
* `exampleTheme` — chrome that carries no hue, so the only colour on screen is
  the one your package is wearing. The font family is a parameter; this package
  ships no typeface and names none. The palette is not a parameter, and
  ADR-0013 says what that buys.

**The three ports**

`ShellDestinations` carries what the menu points at *and its lifetime*.
`SettingsHost` is five members, each read off a real call site. `PresetSummary`
carries a preset's name and what to watch for, and deliberately not what it turns
on. Writes across the seam are commands — `setSwitch(id, on)`, `applyPreset(id)`
— never a settings object, because constructing one means knowing its type.

**The property, and what enforces it**

Nothing in `lib/` names what it demonstrates. Three rules hold what the
compiler will not, all of them legal Dart when violated: nothing under `lib/`
imports outside `dart:`, `package:flutter/` and `flutter_syntax_highlight`;
nothing outside `lib/src/` reaches into it; and the barrel and the tree name the
same files, both ways. A fourth lives in `example/` — a file the Code pane shows
imports no shell.

**Also in this release**

* `example/` demonstrates an adaptive action bar, deliberately not a table.
* `docs/adr/` records thirteen decisions, including the ones most likely to be
  re-proposed: no demo framework, the font as a parameter but not the palette,
  no line numbers in the Code pane, why this package is depended on rather than
  copied, why the SDK floor is 3.27.0 and not the 3.22 the code alone would
  reach, and why the import allow-list grew to three.
* The Dart tokenizer is `flutter_syntax_highlight` rather than 485 lines under
  `src/`. Measured before it was decided: the two disagree on 1,821 characters of
  38,492, every one of them the package being finer — string interpolation most
  of all, which the copy painted as one flat literal.
* `.github/workflows/ci.yml` runs both suites on four legs — the declared floor
  and the current stable, on Linux and on Windows. The platform axis is there
  because a property in `portable_seam_test.dart` had been red on Windows since
  the day it was written, and nothing was looking.
* `.github/workflows/screenshots.yml` runs `tool/screenshots.sh` when `lib/`,
  `example/` or `tool/` moves, and weekly besides. It gates on the script's own
  exit code — a shot it could not reach — and uploads what it captured rather
  than committing it, because a bot that commits screenshots is a bot that can
  quietly replace the front page.
* `tool/screenshots.sh` regenerates the README images by driving the example in
  headless Chrome, pressing controls by their semantics label and checking the
  state it reached before capturing. The Code pane's shot also checks the
  picture, because its content is painted to a canvas that no label can see.

Runs on Flutter 3.27.0 and up, and that floor was measured rather than
inherited from whatever built it: both suites — 23 tests here, 11 in the
example — pass and analyse clean on 3.27.0 and on 3.41.9, and 3.24.5 fails
with exactly one error, `CardThemeData` in `example_theme.dart`. `pubspec.yaml`
names that line, and says why it is not swapped for the older spelling that
would reach lower still. The upper end is held by CI rather than by memory: the
`latest stable` legs resolve 3.47.2 and run the same suites on every push.
