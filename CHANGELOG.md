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
