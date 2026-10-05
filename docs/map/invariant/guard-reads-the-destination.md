# A guard must read the destination, never the source

## The fact
A check that reads where a value *came from* passes anything that acquired it another way.
The assertion has to read the thing that actually reaches the screen — the painted pixel, the
leaf that names the font family, the capture — not the object that was supposed to produce it.

## Why it is cross-cutting
The shared assumption is that a value's provenance predicts its destination, and that
assumption fails identically in three unrelated layers: a theme object versus a painted
colour, a span tree's wrapper versus its leaf, a path bar versus a rendered pane. None of
these sites calls another. They share a *shape of mistake*, not a call graph, which is why
this cannot be an edge between territories.

**All three were green while the defect was on screen.** That is the property that makes it
worth a node: the failure mode is a passing test, so nothing reports it.

## Territories it holds in
→ [the code pane](../territory/code-pane.md) — a monospace assertion read the wrapper
  `SelectableText` puts around a span tree instead of the leaf naming the family; the pane
  rendered in the proportional chrome font for six releases underneath it
→ [the theme and chrome](../territory/theme-and-chrome.md) — a theme audit read a palette
  object instead of what was actually painted
→ [the published artifact](../territory/published-artifact.md) — `tool/shots.mjs` checked the
  Code pane by looking for the path bar above it, which is drawn from `assetPath` before the
  bundle answers

## What a violation looks like
A green assertion naming an intermediate: a controller, a spec object, a wrapper widget, a
label drawn from an argument rather than from a result. The symptom is not a red test — it is
a defect visible on screen with nothing failing.

**The condition it hides under**: the intermediate is correct. Every one of these three read a
value that was genuinely right; the break was between that value and the paint.

The published case is the sharpest. `docs/images/code-pane.png` was empty in the commit that
added the tool and in every one after, **on the pub.dev front page** — and `code_pane.dart`
had already named the trap in a doc-comment: *a pane that renders empty on error is
indistinguishable from a pane that loaded an empty file.* The tool walked into it from
outside, which is the recurrence condition worth remembering: the warning was written in the
territory, and the violation arrived from a different one.

## Discovery history
→ [`lessons.md` — a guard must read the destination, never the source](../../agents/lessons.md#a-guard-must-read-the-destination-never-the-source)
→ [`lessons.md` — a `sleep` is not a wait, in a headless browser](../../agents/lessons.md#a-sleep-is-not-a-wait-in-a-headless-browser)

Measured **three times**, in three territories, none of which learned it from another.

The third cost more than the defect. Diagnosing the blank screenshot, four seconds of
`setTimeout` before the capture produced the same empty picture — which read as *the file
never loads*, and sent the search into the widget tree. A scroll-nesting change was written
and reverted, because the pane had never been wrong.

## Where it will recur
Wherever the destination is hard to read, because that is precisely where an intermediate is
tempting. **The Code pane's content is painted to a canvas**: not in the DOM, not in the
accessibility tree, so no string check can see it — and a `Semantics` label added to make one
possible would be present whether or not the paint succeeded, which is the same mistake with
more steps.

The test a future author can run: name the thing the user sees, then ask whether the assertion
could still pass if everything between the value and that thing were removed. If it could, the
guard is reading the source.

Corollary for any browser driver: a fixed delay is not a slower poll. `Page.captureScreenshot`
asks for a frame; `setTimeout` asks for nothing, so it can hold still forever.
