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
  screen and what executes cannot disagree. `tokenizeDart` highlights it and
  returns a partition, so concatenating every token reproduces the file byte for
  byte.
* `PresetBar`, `FeatureListPane`, `FeatureDetailPane` — a settings panel drawn
  from a description of groups, features, options and the interactions between
  them, with search over control labels.
* `MetricsPanel` and `MetricsChip` — named readings the consumer formats and
  assigns a severity, since the thresholds belong to whoever knows what is being
  measured.
* `exampleTheme` — chrome that carries no hue, so the only colour on screen is
  the one your package is wearing. The font family is a parameter;
  this package ships no typeface and names none.

**The three ports**

`ShellDestinations` carries what the menu points at *and its lifetime*.
`SettingsHost` is five members, each read off a real call site. `PresetSummary`
carries a preset's name and what to watch for, and deliberately not what it turns
on. Writes across the seam are commands — `setSwitch(id, on)`, `applyPreset(id)`
— never a settings object, because constructing one means knowing its type.

**The property, and what enforces it**

Nothing in `lib/` names what it demonstrates. Three rules hold what the
compiler will not, all of them legal Dart when violated: nothing under `lib/`
imports outside `dart:` and `package:flutter/`; nothing outside `lib/src/`
reaches into it; and the barrel and the tree name the same files, both ways. A
fourth lives in `example/` — a file the Code pane shows imports no shell.

**Also in this release**

* `example/` demonstrates an adaptive action bar, deliberately not a table.
* `docs/adr/` records eleven decisions, including the ones most likely to be
  re-proposed: no demo framework, the font as a parameter, no line numbers in the
  Code pane, why this package is depended on rather than copied, and why the SDK
  floor is 3.27.0 and not the 3.22 the code alone would reach.
* `.github/workflows/ci.yml` runs both suites on four legs — the declared floor
  and the current stable, on Linux and on Windows. The platform axis is there
  because a property in `portable_seam_test.dart` had been red on Windows since
  the day it was written, and nothing was looking.
* `tool/screenshots.sh` regenerates the README images by driving the example in
  headless Chrome, pressing controls by their semantics label and checking the
  state it reached before capturing.

Runs on Flutter 3.27.0 and up, and that floor was measured rather than
inherited from whatever built it: both suites — 21 tests here, 10 in the
example — pass and analyse clean on 3.27.0 and on 3.41.9, and 3.24.5 fails
with exactly one error, `CardThemeData` in `example_theme.dart`. `pubspec.yaml`
names that line, and says why it is not swapped for the older spelling that
would reach lower still. The upper end is unchanged: 3.47.1 is where
this was built, and `feature_list_pane.dart` records the assertion that
version tightened.
