# A subject is evidence, never vocabulary

## The fact
`lib/` may not name what it demonstrates. But the rule is not "never write the noun" — it is
directional. **A measurement points outward, at something that happened, and the subject's
name is part of what happened; a description points inward, at this package, and there the
name is a claim about what the package knows.**

So a dated probe cites what it was measured on, and a live rule explaining itself in the
subject's terms is the shell forgetting it does not know.

## Why it is cross-cutting
It is not a property of any one area: it holds wherever this package writes prose about
itself, which is every area. The sites do not call each other at all — they are doc-comments
and record text in unrelated files — so no territory-to-territory edge could ever have
carried it. That is exactly the case the invariant node kind exists for.

The shared assumption is about *voice*, not about code: every file here has to describe
behaviour it deliberately cannot name the cause of.

## Territories it holds in
→ [the seam](../territory/the-seam.md) — `settings_host.dart` names prior art by type name
→ [the menu and roster](../territory/menu-and-roster.md) — `StageDestination.allowsWall` once
  explained itself as being about "three tables"
→ [the preview stage](../territory/preview-stage.md) — `preview_frame.dart` records a probe
  that "dragged rows 0..2 and selected exactly rows 0..2", which is a measurement and stays
→ [the settings panel](../territory/settings-panel.md) — the panes were typed on the subject's
  own settings class before the port existed
→ [the metrics panel](../territory/metrics-panel.md) — names the table on purpose, because
  "these thresholds are a fact about one kind of table" *is* the argument for the seam
→ [the shell page composition](../territory/shell-page-composition.md) — "nothing here names a
  destination"; the roster used to be a field of this state

## What a violation looks like
Prose in the shell's own voice reaching for the subject's noun as the default one. Two real
shapes: a consequence reading "the frame's rows really are ~11px" where it means the frame's
*content*, and a live rule on `allowsWall` explained in terms of tables.

The tell is the tense and the direction. A sentence about what happened on a date, to a named
thing, is a citation. A sentence about what this package does, using the same noun, is not.

**A citation made vaguer is a citation made worthless** — so the fix for a violation is never
to delete the noun from a measurement.

## Discovery history
→ [`lessons.md` — a subject may be named as evidence, never as vocabulary](../../agents/lessons.md#a-subject-may-be-named-as-evidence-never-as-vocabulary)
→ [ADR-0001 — the gallery names no subject](../../adr/0001-the-gallery-names-no-subject.md)

- The counts and feature names went in `8b99cac`. What survived that sweep was measurement
  prose.
- **The line between the two was drawn by hand twice before anyone wrote it down.** That is
  the argument for this note existing: the rule was rediscovered rather than consulted.
- A third instance is live now and was found while writing this map: `settings_host.dart`
  says *"Prior art in this repository: `RowLocator`"*. It is a citation, so the noun is
  allowed — but the address is wrong, and a citation nobody can follow has the same value as
  vocabulary.

## Where it will recur
Whenever a doc-comment explains *why* a rule exists rather than *what* it does — which is
most of this repository's comments, and is why the comment policy in `CLAUDE.md` routes that
material here rather than into the source.

The test a future author can run, by grep rather than by judgement: search `lib/` for the
subject's nouns, and for each hit ask **whether the sentence carries a date or a probe**.
If it does, it stays and the noun stays with it. If it does not, the sentence is describing
this package and the noun is a claim it cannot make.
