# A green from a test nobody watched fail is not evidence

## The fact
A passing test proves nothing until the assertion has been seen going red for the right
reason. **And neither does a red**: a failure can be produced by something unrelated to the
property the test asserts.

So the unit of evidence is not the test. It is the pair — a mutation that should break it, and
the observed break.

## Why it is cross-cutting
The shared assumption is that a test's *existence* is the guarantee. That holds in every
territory that has tests, and the sites have no relationship beyond it.

It is especially sharp here because tests arrived by **copy**: a copied test that passes on
its first run has never been seen failing in the tree it now guards. Nothing about the copy is
visible in the diff.

## Territories it holds in
→ [the seam](../territory/the-seam.md) — every rule in `portable_seam_test.dart` and
  `settings_host_test.dart` was mutated and watched failing, in this repository, after the copy
→ [the settings panel](../territory/settings-panel.md) — the ordinary fake overrode `presets`,
  so the port's empty default was asserted nowhere
→ [the metrics panel](../territory/metrics-panel.md) — written this way from the start: five
  rules, five mutations, each caught by exactly one test
→ [the code pane](../territory/code-pane.md) — a highlighter explanation was asserted, tested
  and withdrawn

## What a violation looks like
A test that cannot fail, and three shapes of it are on record here:

- **A fake that over-overrides.** The settings fake supplied `presets`, so the port's empty
  default had no assertion anywhere. A port that started handing out presets nobody declared
  would have shipped. The fix was a second fake overriding only what the port leaves abstract.
- **A green that guards the wrong property.** In the highlighter, the claim was that branch
  *order* kept a comment from opening a string. Reversing the branches changed nothing — the
  mutation had to cripple `_lineCommentEnd` before the test would redden. What protects the
  property is that a comment is consumed whole. The explanation was withdrawn.
- **A red that means something else.** The seam test's own first red was **false**: a resolver
  bug made every same-directory import read as leaving the package, so it was red for a reason
  unrelated to what it asserts. A red accepted without reading it is the same error as a green
  accepted without watching it.

## Discovery history
→ [`lessons.md` — a green from a test nobody watched fail is not evidence](../../agents/lessons.md#a-green-from-a-test-nobody-watched-fail-is-not-evidence-and-neither-is-a-red)
→ [ADR-0010 — two gates considered and declined](../../adr/0010-two-gates-declined.md)

Three findings came out of applying it once, listed above. ADR-0010 is the same reasoning at
the level of gates: the declined extraction probe *"was green while a font was missing"*, which
is this note's failure mode in a check rather than a test.

## Where it will recur
On every test added, and hardest on every test **copied** — from another repository, from a
sibling package, or from a neighbouring file in this one.

The test a future author can run, and it is mechanical: **turn the behaviour off and watch the
specific assertion redden while the rest stays green.** If nothing reddens, the test is not
asserting what its name says. If everything reddens, it is asserting something broader and the
name is wrong.

The discipline is owed by anything added later, without exception — it is how
`metrics_panel_test.dart` was written, and that is the only suite here built this way from the
first line rather than retrofitted.
