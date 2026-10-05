# Never hand-maintain a roster

## The fact
Wherever a second list of something is kept in step by hand, it is already wrong or will be.
A roster is derived from what exists, or it is not kept at all.

**The strong form matters**: the failure is not that a hand list drifts eventually. The seam
test once named three areas while the tree held five, and **it was already wrong in the
commit that wrote it**. There was no window during which it was right.

## Why it is cross-cutting
The shared assumption is that some set is small and stable enough to write down — and the
sites that make it have nothing else in common. A test's list of directories, a widget's list
of viewport constants, a theme test's map of styled surfaces and an import allow-list are four
unrelated layers with no call between them.

What ties them is that in every case **the authoritative set already exists somewhere the
code can read**, and a second copy was made anyway.

## Territories it holds in
→ [the seam](../territory/the-seam.md) — `portable_seam_test.dart`'s two rosters now read the
  tree; they did not always, and that is where the rule was found
→ [the menu and roster](../territory/menu-and-roster.md) — the Roster concept carries the
  warning in its own glossary entry: the danger is being kept by hand rather than read
→ [the preview stage](../territory/preview-stage.md) — `ViewportSpec.values` stays the only
  roster of viewports there is, which is why the wall and the room are ids rather than more specs
→ [the theme and chrome](../territory/theme-and-chrome.md) — `example_theme_test.dart` keeps a
  hand-written map of styled surfaces, with the consequence written on it
→ [the published artifact](../territory/published-artifact.md) — the import allow-list is a
  hand-written list of three prefixes

## What a violation looks like
Two lists of the same thing where only one is derived — and the tell is that the hand-written
one is *shorter*, because it was written from memory of the tree rather than from the tree.

**The exempt case is real and must stay labelled.** `example_theme_test.dart` hand-maintains
its surface map deliberately, and says so: *a fifth styled surface added later is invisible to
it*. That is a known, accepted hole, not a defect to "fix" by deriving it — deriving would
mean asserting that every surface is styled, which is a different and weaker claim.

So the rule's shape is: **derive what a tool can see, hand-write only what it cannot, and
label which is which.** An unlabelled hand list is the violation; a labelled one is a decision.

## Discovery history
→ [`lessons.md` — never hand-maintain a roster](../../agents/lessons.md#never-hand-maintain-a-roster)
→ [`CONTEXT.md`](../../../CONTEXT.md) — the Roster entry carries the warning in the glossary

- The seam test named three areas against a tree of five, wrong on the day it was written.
- `ViewportSpec.values` is the positive case, and it is *why* the wall is selected by id: a
  fourth `ViewportSpec` would have had to invent a size and a chrome policy to exist as a
  roster entry.
- Found while writing this map, and not previously recorded: `portable_seam_test.dart` states
  that its rules are *"deliberately not hand-written lists of allowed spellings"* while
  `_allowedExternal` is a hand-written list of three. The two are reconcilable — the *rules*
  are derived, the *allow-list* is policy — but nothing says so, and ADR-0007 quotes the
  count as two while the list holds three.

## Where it will recur
Whenever something needs to enumerate the tree: directories, exported symbols, viewports,
styled surfaces, assets, allowed imports.

The test a future author can run, by grep rather than judgement: **find the literal list, then
ask what would have to change for it to be wrong, and whether anything would say so.** If the
answer is "someone adds a file" and "nothing", it must be derived or labelled.
