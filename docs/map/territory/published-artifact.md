# The published artifact

## What it is
Shipping is something the system does, so it is a territory. This one owns the package as a
thing a stranger installs: the manifest and its floor, the dependency posture, the README and
its screenshots, the changelog, and the tooling that produces the images on pub.dev.

Its failures are the kind nothing local catches — they appear to someone who was not here.

## Governing decisions
→ [ADR-0002 — this package is depended on, not copied](../../adr/0002-depended-on-not-copied.md)
→ [ADR-0007 — no demo framework](../../adr/0007-no-demo-framework.md)
→ [ADR-0010 — two gates considered and declined](../../adr/0010-two-gates-declined.md)
→ [ADR-0011 — the SDK floor is measured, and one line sets it](../../adr/0011-the-sdk-floor-is-measured.md)
→ [ADR-0012 — the tokenizer is a dependency, and the allow-list is three](../../adr/0012-the-tokenizer-is-a-dependency.md)

## Design model
**Depended on, not copied.** The name says template; the shape — a barrel, `src/`, three
ports — is a library. No `publish_to: none`.

**An example that imports a demo framework demonstrates the framework.** That is why the
shell is hand-built rather than assembled, and why the package stays as close to
dependency-free as it can. The rule is enforced by an import allow-list in the seam test
rather than by intention.

**The SDK floor is measured, and the numbers are dated on purpose.** Both ends were run
before either was written. The dates make them evidence that real suites ran — a fact about
the measurement, which stays true — rather than a description of the suites today. The
manifest used to carry the same pair as a live claim and has stopped.

**A declined gate is recorded as declined.** ADR-0010 keeps two of them, so that a gate
nobody built is distinguishable from a gate nobody thought of. It also sets a threshold for
one of them: automation waits for a second occurrence rather than a first scare.

**The screenshots are captures, not drawings**, produced by `tool/shots.mjs` against a real
headless browser — which is why the trap in
[a guard reads the destination](../invariant/guard-reads-the-destination.md) reached pub.dev.

## Code
`tool/shots.mjs` — the capture driver and its blank-image check
`tool/screenshots.sh` — the capture entry point
`test/portable_seam_test.dart` — the import allow-list that enforces the dependency posture

## Reference behaviour
**None.**

pub.dev's layout and publishing rules are recorded in
[`docs/agents/thegraph.md`](../../agents/thegraph.md) as **summarized** and spec-binding —
so anything resting on them here carries forward as *needs confirming against the real
thing*, and a summarized source cannot settle a question outright.

## Cross-cutting invariants
→ [a guard reads the destination](../invariant/guard-reads-the-destination.md)
→ [never hand-maintain a roster](../invariant/never-hand-maintain-a-roster.md)

## Blast radius
→ [the seam](the-seam.md) — every port member is public API, so a seam change is a breaking
  change and sets the version
→ [the code pane](code-pane.md) — a recipe's source must ship as an asset for the pane to fill
→ [the preview stage](preview-stage.md) — the pub.dev images are captures of these modes
→ [the theme and chrome](theme-and-chrome.md) — a consumer shipping its own face needs the
  font contract stated in the README

## Known holes / open
- **ADR-0007 states a two-entry allow-list; the code has three and ADR-0012 raised it.**
  Neither record links to the other — no decision record in this repository links to another
  — so a reader arriving at 0007 gets a stale number with nothing pointing onward. The
  decision is superseded; its text is not marked.
- **ADR-0002 cites `docs/inherited-decisions.md`, which does not exist.** The argument it
  attributes survives in ADR-0007, so the reasoning is recoverable, but the citation resolves
  to nothing. Not fixed here: this map does not edit decision records.
- ADR-0010 declined a README link checker pending a second occurrence. The two broken
  references above are in decision records rather than the README, so they do not strictly
  meet that trigger — but they are the same failure the gate was meant to catch, and nothing
  records whether that counts.
