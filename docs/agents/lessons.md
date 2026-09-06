# Lessons

Working rules, not decisions — the decisions are in [`docs/adr/`](../adr/). Each of these was got
wrong, measured, and is cheap to get wrong again. `lib/src/shell/dart_highlighter.dart` cites this
file.

## Classify by transitive dependency, never by direct import

This was got wrong three times in a row while the shell was being extracted. Files that named no
package were still unmovable, because they were *typed* on a class that did. The figure claimed for
"already portable" was 1,689 lines; the measured figure was 644.

**It happened a fourth time, and this time it shipped.** `PerformanceMetrics` imported nothing but
`material.dart`, so `portable_seam_test.dart` passed it — and its fields were `rowCount`,
`lastSortTimeMs` and `dataGenerationTimeMs`, with severity thresholds of 1 000 / 10 000 / 50 000
written into the widget that drew them. It arrived in the same commit as the note recording the
lesson. Nothing in the package referenced it, so neither seam suite ever ran it.

The import graph is the cheap question. The one that matters is what a type is *made of*.

## A guard must read the destination, never the source

A check that reads where a value came from passes anything that acquired it another way. Measured
three times here:

- A theme audit that read a palette object instead of what was actually painted.
- A monospace assertion that read the wrapper `SelectableText` puts around a span tree, instead of
  the leaf that names the family. The pane rendered in the proportional chrome font for six releases
  underneath it.

Both were green while the defect was on screen.

## A green from a test nobody watched fail is not evidence — and neither is a red

Every rule in `test/portable_seam_test.dart` and `test/settings_host_test.dart` was mutated and
watched failing before it was believed, **in this repository, after the copy**. A copied test that
passes on its first run has never been seen failing in the tree it now guards.

Three things that discipline found:

- The ordinary fake overrode `presets`, so the port's empty default was asserted **nowhere**. A port
  that started handing out presets nobody declared would have shipped. A second fake now overrides
  only what the port leaves abstract.
- In the highlighter, an explanation was asserted, tested and **withdrawn**: the claim was that
  branch *order* kept a comment from opening a string, and reversing the branches changed nothing.
  The mutation had to cripple `_lineCommentEnd` before the guarding test would redden. What protects
  the property is that a comment is consumed whole, not the order it is checked in.
- The seam test's own first red was a **false** one. A resolver bug made every same-directory import
  read as leaving the package, so the test was red for a reason unrelated to the property it
  asserts.

The same discipline is owed by anything added later. `test/metrics_panel_test.dart` was written this
way: five rules, five mutations, each caught by exactly one test.

## Never hand-maintain a roster

The seam test once named three areas while the tree held five — and it was already wrong in the
commit that wrote it. Both of its rosters now read the tree instead.

The same shape shows up wherever a second list of something is kept in step by hand:
`ViewportSpec.values` stays the only roster of viewports there is, which is why the wall is selected
by an id rather than by a fourth `ViewportSpec` that would have to invent a size and a chrome policy.
