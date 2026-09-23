# The code pane

## What it is
A recipe's own source, read out of the asset bundle so that what runs and what is shown
cannot disagree. It is not a general source viewer — it is the affordance of the pasteable
claim: a recipe says "copy this", and the pane is how a reader checks that the thing they
are looking at is the thing that ran.

## Governing decisions
→ [ADR-0009 — no line numbers in the Code pane](../../adr/0009-no-line-numbers-in-the-code-pane.md)
→ [ADR-0012 — the tokenizer is a dependency, and the allow-list is three](../../adr/0012-the-tokenizer-is-a-dependency.md)

Well governed for a single-type territory, and both records are narrow: one decides an
absence, the other decides ownership of highlighting. Neither decides the loading model or
the failure model, which is where this territory's holes are.

## Design model
**The source is read from the bundle, not from disk.** `StageDestination.source` names an
asset path; the pane resolves it through the bundle, so a release that ships without the
asset shows an empty pane rather than a stale one.

**The `FutureBuilder` wraps the whole pane rather than the body.** Replacing the future
drives `didUpdateWidget`, and `FutureBuilder` reports `ConnectionState.none` for at least
one frame when that happens — so a narrower wrap would flash the previous file's content
against the new file's path bar.

**Highlighting is a dependency, not code here.** `flutter_syntax_highlight` owns tokenizing;
this package owns the pane. ADR-0012 records that the import allow-list is three entries.

**The failure model is the trap, and the file names it.** *A pane that renders empty on error
is indistinguishable from a pane that loaded an empty file.* That sentence is the reason the
screenshot tooling shipped a blank picture to pub.dev for every release in which it existed —
see [a guard reads the destination](../invariant/guard-reads-the-destination.md).

**The pane's content is painted to a canvas.** It is not in the DOM and not in the
accessibility tree, so no string check can see it. A `Semantics` label added to make one
possible would be present whether or not the paint succeeded, which is the same mistake with
more steps. What is left is the capture.

## Code
`lib/src/shell/code_pane.dart` — `CodePane`
`test/code_pane_test.dart` — the bundle-loading behaviour, against a fake asset bundle

## Reference behaviour
**None.**

`flutter_syntax_highlight` is a spec-binding source for tokenizing and is reachable raw as a
sibling checkout — see [`docs/agents/thegraph.md`](../../agents/thegraph.md). Nothing in this
territory has been read against it; a difference in tokenizing behaviour would be a bug here
rather than a choice, and no note currently records a comparison.

## Cross-cutting invariants
→ [a guard reads the destination](../invariant/guard-reads-the-destination.md)
→ [a green nobody watched fail is not evidence](../invariant/watched-it-fail.md)

## Blast radius
→ [the menu and roster](menu-and-roster.md) — `StageDestination.source` is what the pane
  reads; a destination without one draws no pane
→ [the published artifact](published-artifact.md) — `docs/images/code-pane.png` is a capture
  of this pane, and the asset must actually ship for the pane to fill
→ [the theme and chrome](theme-and-chrome.md) — the pane's monospace family is chrome, and it
  rendered in the proportional chrome font for six releases underneath a passing assertion

## Known holes / open
- Nothing decides what the pane should draw when the asset is missing as opposed to empty.
  The two are currently indistinguishable on screen, and the file says so without resolving
  it — which is what let the blank screenshot survive.
- No record decides the loading model: bundle-only is a fact of the code, not a decision.
