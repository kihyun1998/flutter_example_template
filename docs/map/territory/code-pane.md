# The code pane

## What it is
A recipe's own source, read out of the asset bundle so that what runs and what is shown
cannot disagree. It is not a general source viewer — it is the affordance of the pasteable
claim: a recipe says "copy this", and the pane is how a reader checks that the thing they
are looking at is the thing that ran.

## Governing decisions
→ [ADR-0009 — no line numbers in the Code pane](../../adr/0009-no-line-numbers-in-the-code-pane.md)
→ [ADR-0012 — the tokenizer is a dependency, and the allow-list is three](../../adr/0012-the-tokenizer-is-a-dependency.md)
→ [ADR-0015 — the floor is 3.32, and the allow-list is four](../../adr/0015-the-floor-is-3-32-and-the-allow-list-is-four.md)

Well governed for a single-type territory, and all three records are narrow: one decides an
absence, one decides ownership of highlighting, and one decides the wheel motion and the floor
it brought. None decides the loading model or the failure model, which is where this
territory's holes are.

## Design model
**The source is read from the bundle, not from disk.** `StageDestination.source` names an
asset path; the pane resolves it through the bundle, so a release that ships without the
asset shows an empty pane rather than a stale one.

**The `FutureBuilder` wraps the whole pane rather than the body.** Replacing the future
drives `didUpdateWidget`, and `FutureBuilder` reports `ConnectionState.none` for at least
one frame when that happens — so a narrower wrap would flash the previous file's content
against the new file's path bar.

**Highlighting is a dependency, not code here.** `flutter_syntax_highlight` owns tokenizing;
this package owns the pane. ADR-0012 took the import allow-list to three entries, and
ADR-0015 to four.

**A wheel glides on both axes, and nothing else does.** Both of the pane's scroll views take
a `SmoothScrollController`, so a wheel notch animates down the file and along a long line.
Drag, scrollbar, keyboard and trackpad input are the plain controller's — the package
animates only a `PointerScrollEvent` of kind `mouse`. It stops at the pane: the stage is
where the subject's own scroll views live, and chrome that scrolled differently from the
subject inside it would have the reader judging one against the other. Both axes was the
maintainer's call on #24, over vertical-only; ADR-0015 holds the rest.

**The vertical controller is explicit, and one reason once given for that was false.** The
reason that holds is measured: a `primary: true` view takes the route's plain `ScrollController`, so
the wheel stops gliding — switched over, the glide-down and the scrollbar-track tests fail,
and those two tests are what keeps the controller explicit. The `Scrollbar` is also handed the
controller it tracks rather than finding one; that is legibility, not necessity, because a
`Scrollbar` with no controller finds the primary and worked in every probe below.

The withdrawn reason: the controller's comment said that with `primary` set, the inner
`Scrollable` that `SelectableText` brings and the pane's view "claim the same
`PrimaryScrollController` and the framework asserts". They do not. `SelectableText` gives its
`EditableText` no controller, so that `Scrollable` scrolls on one of its own and never reads
the primary. And a `SingleChildScrollView` that takes the primary wraps its subtree in
`PrimaryScrollController.none`, so nothing under it can share it anyway. Measured on #27 with
the vertical view switched to `primary: true` and the `Scrollbar` given no controller:

| Flutter | platform | enclosing `PrimaryScrollController` | exception | `positions` |
|---|---|---|---|---|
| 3.32.0 | Android | no / yes | none | 1 |
| 3.32.0 | Windows | no / yes | none | 1 |
| 3.41.9 | Android | no / yes | none | 1 |
| 3.41.9 | Windows | no / yes | none | 1 |
| 3.47.7 | Android | no / yes | none | 1 |
| 3.47.7 | Windows | no / yes | none | 1 |

3.41.9 ran on the maintainer's Windows machine; 3.32.0 and 3.47.7 ran on CI's Ubuntu and
Windows hosts, from a probe branch that was never merged, and agreed on both. The same runs
are where the glide tests failed under `primary: true`.

The probe can see the assert: handing the horizontal view the same primary controller
directly gives `positions` 2 on all four 3.41.9 rows, and on Windows *"The PrimaryScrollController is
attached to more than one ScrollPosition"*. The pane's structure cannot produce that.

The claim crossed repositories before it was withdrawn here. `flutter_syntax_highlight`
carried it as what "the reference implementation", this pane, gives as a reason, measured it
false on 2026-09-06, and retracted it in `SyntaxText`'s docs, keeping the `Scrollbar` reason.

**Switching recipe starts the new one at its top, and that is structural.** While the
replacement future is unsettled the pane draws `SizedBox.shrink`, which unmounts `_Code` and
with it both controllers — a glide in flight is disposed with them. A change that kept the
code mounted across the load (drawing the previous data while waiting) would carry the old
offset into the new file; a test holds this.

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
`test/code_pane_test.dart` — the bundle-loading behaviour, against a fake asset bundle, and
  the wheel on both axes. A fixture over 50 KB never loads there: `CachingAssetBundle`
  decodes a string that large on an isolate, which a widget test's fake clock never waits
  for, so the pane stays on its empty loading frame and the test finds no `Scrollable`.
  A wheel event in a test needs `kind: PointerDeviceKind.mouse` — the default pointer is
  touch, and touch is never animated.
  The wheel over the scrollbar track is a separate path, and only a desktop one: the view
  registers for the wheel before the scrollbar does, so the track takes it only once a
  hover has revealed it and the view has left the hit path — the test checks that first, or
  it re-measures the plain wheel. On a desktop platform the default scroll behaviour also
  adds scrollbars to the pane's other scroll views, so `find.byType(Scrollbar)` finds three
  and the pane's own is the first.

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
