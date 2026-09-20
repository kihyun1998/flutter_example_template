# The menu and roster

## What it is
What the shell can point at, and how it is grouped when drawn. A roster is every
destination one shell draws, in menu order; a destination is one entry in it, of which
there are exactly two kinds. This territory owns the roster's *shape and grouping* — the
stage a destination renders into belongs to [the preview stage](preview-stage.md), and who
holds the selected id belongs to [the shell page composition](shell-page-composition.md).

## Governing decisions
→ [ADR-0005 — an unclaimed capability draws nothing at all](../../adr/0005-optional-capabilities-are-silent.md)

That record governs the *category* rule specifically: a category no destination claims is
not drawn, because an empty category is not a slot standing open. Nothing governs the
two-kind split, the sealed hierarchy, or menu ordering. ADR-0003 sits adjacent and decides
that the roster arrives through a port — it decides delivery, not the roster's own model.

## Design model
**Two kinds, and the difference is structural rather than cosmetic.** `StageDestination`
renders into the shell's stage and knob region; `RouteDestination` opens on its own route
and the shell hands over. This is why `ShellDestination` is sealed rather than a class with
a nullable builder: a full page has its own `Scaffold`, and putting one inside the stage
would mean taking it apart. Sealing makes that a fact about the destination rather than a
branch someone can forget to write.

**Three categories, two naming content and one naming a hosting kind.** `recipes` and
`scenarios` name what a thing is; `pages` names a shape — each member is a full page the
shell points at instead of drawing. The asymmetry is deliberate and recorded in the enum's
own doc-comment: inventing a content theme to cover the remainder would name a set after
something it does not have.

**One of these was once named after its only member**, which is a set named after an
element. The second member is what made it visible — a one-element set is indistinguishable
from the element.

**A destination is one object with two views of it.** The stage and the knob region both
read the same `ChangeNotifier`, which is why the port carries the lifetime; see
[the seam](the-seam.md).

## Code
`lib/src/shell/shell_destination.dart` — `ShellCategory`, `ShellDestination`, `StageDestination`, `RouteDestination`
`lib/src/shell/shell_destinations.dart` — `ShellDestinations`
`lib/src/shell/shell_menu.dart` — `ShellMenu`
`test/shell_menu_test.dart` — the category-drawing rule, including the empty-category case

## Reference behaviour
**None.**

Never compared to a reference. The nearest comparable rosters are in the maintainer's other
`flutter_*` packages, named in [`docs/agents/thegraph.md`](../../agents/thegraph.md) as
examples rather than specs — so a difference there is a choice to record, not a bug.

## Cross-cutting invariants
→ [never hand-maintain a roster](../invariant/never-hand-maintain-a-roster.md)
→ [a subject is evidence, never vocabulary](../invariant/subject-is-evidence-never-vocabulary.md)

## Blast radius
→ [the seam](the-seam.md) — the roster arrives through `ShellDestinations`; adding a field to
  a destination is a public API change on a port
→ [the shell page composition](shell-page-composition.md) — the shell holds the selected id
  rather than the selected object, so a roster that changes identity mid-session lands there
→ [the preview stage](preview-stage.md) — `StageDestination.allowsWall` decides whether a
  destination may be drawn on the wall at all
→ [the code pane](code-pane.md) — `StageDestination.source` is the asset path the pane reads;
  a destination with no source draws no pane

## Known holes / open
- `shell_destinations.dart` warns that changing the roster's *shape* later is what is not
  free — the shell reads it once. No record states what that costs a consumer, and there is
  no deprecation path written down for a destination field.
- Nothing decides whether a fourth category could exist, or on what grounds. The enum's
  doc-comment argues against inventing one but states no rule.
