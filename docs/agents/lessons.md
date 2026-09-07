# Lessons

Working rules, not decisions — the decisions are in [`docs/adr/`](../adr/). Each of these was got
wrong, measured, and is cheap to get wrong again. `tool/screenshots.sh` and `tool/shots.mjs` cite
this file.

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
- `tool/shots.mjs` checked the Code pane by looking for the **path bar above it**, on the reasoning
  that nothing else on screen names the file. The path is drawn from `assetPath` before the bundle
  answers, so the check was satisfied by a pane that had drawn nothing yet, and the tool
  photographed the state before the file arrived. `docs/images/code-pane.png` was empty in the
  commit that added the tool and in every one after, on the pub.dev front page. `code_pane.dart`
  had already named the trap in a doc-comment — *"a pane that renders empty on error is
  indistinguishable from a pane that loaded an empty file"* — and the tool walked into it from
  outside.

All three were green while the defect was on screen.

**The destination is sometimes a picture, and a picture is hard to read.** The Code pane's content
is painted to a canvas: it is not in the DOM and not in the accessibility tree, so no string check
can see it, and a `Semantics` label added to make one possible would be present whether or not the
paint succeeded — the same mistake with more steps. What is left is the capture, which is what
`isBlank` reads.

## A `sleep` is not a wait, in a headless browser

Diagnosing the above, four seconds of `setTimeout` before the capture produced the same empty
picture. That read as *the file never loads*, and it sent the search into the widget tree — a
scroll-nesting change was written, and reverted, because the pane had never been wrong.

Headless Chrome had simply not drawn another frame; nothing had asked it to.
`Page.captureScreenshot` asks, which is why polling the picture both waits and checks, and why the
sleep that looked like a
control was measuring nothing at all. A fixed delay in a browser driver is not a slower version of a
poll. It is a different thing that can hold still.

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
  the property is that a comment is consumed whole, not the order it is checked in. That code is
  `flutter_syntax_highlight` now (ADR-0012); the lesson stayed because it is about tests rather
  than about tokenizing.
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

## A subject may be named as evidence, never as vocabulary

`lib/` may not name what it demonstrates — [ADR-0001](../adr/0001-the-gallery-names-no-subject.md)
— and the counts and feature names went in 8b99cac. What survived that sweep was measurement
prose, and the line through it was drawn by hand twice before anybody wrote it down.

**Where the subject is the evidence, it is named.** A dated measurement cites what it measured on,
and a citation made vaguer is a citation made worthless: `preview_frame.dart` records a probe that
"dragged rows 0..2 and selected exactly rows 0..2", and the withdrawn `Transform` claim that four
files cite has to stay legible as the claim it actually was. `metrics_panel.dart` goes further and
names the table on purpose — that its three old thresholds "are a fact about one kind of table and
about nothing else" *is* the argument for the seam, and the same sentence with the noun taken out
argues nothing.

**Where the subject has become the vocabulary, it goes.** That is prose in the shell's own voice
reaching for the subject's noun as the default one: a consequence reading "the frame's rows really
are ~11px" where it means the frame's content, or a live rule on `StageDestination.allowsWall`
explained as being about "three tables". Those are not citations. They are the shell forgetting it
does not know.

The test is which way the sentence points. A measurement points outward, at something that
happened, and the noun is part of what happened. A description points inward, at this package, and
there the noun is a claim about what the package knows.
