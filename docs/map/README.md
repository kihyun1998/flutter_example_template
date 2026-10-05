# The map

A dependency graph over what this package *does*, for the two questions no other artifact
here answers:

1. **If I touch this, what else moves?** → open the territory note, read `## Blast radius`.
   It is a checklist. Opening a listed territory and finding nothing to do there is a correct
   outcome; not opening one is the failure this layer exists to prevent.
2. **What is this code derived from?** → read `## Governing decisions` for the record above it
   and `## Reference behaviour` for the external fact behind that. **A blank one is the
   answer, not an omission.**

The records in [`docs/adr/`](../adr/) are indexed by the day a decision was made, and
[`docs/agents/lessons.md`](../agents/lessons.md) by the day something was got wrong. Neither
is indexed by territory, and neither survives its event. This is that missing index.

## Read before the work, write after it

**Before designing a change**, open the territory you are about to touch and read
`## Blast radius` and `## Cross-cutting invariants`. Both are checklists, and the second is
the one that is invisible from the code.

**At the first fix, not the third**, ask the promotion question: *is the fact this fix
revealed also true outside this territory?* If yes, an invariant note is owed before the
change lands. This is the obligation that makes the map preventive rather than archival —
the first site to hit a fact is where it is discovered, and at that moment no node for it
exists. Every invariant here was written after the second or fourth occurrence, not the
first.

**Honest note on the binding.** The strongest binding would be deleting a copy — replacing
some existing hand-kept "check these too" list with a link to a node. **There is no such list
in this repository**, so this binding is a rule, and a rule competes with habit rather than
replacing a copy. It is the weaker kind and should be treated as provisional.

`lessons.md` is unchanged and stays the prose. What it never had is the edges: it says a guard
must read the destination and not which territories that holds in. The invariant notes add
exactly that and link back to it.

## What the measurements found

These exist in no node file, and they are the headline.

| | |
|---|---|
| Public types | **32**, across 21 files, behind one barrel |
| Decision records | **14** |
| Territories with **no governing record** | **2 of 9** — settings panel, metrics panel |
| Territories with **no reference comparison** | **9 of 9** |
| Worst-covered concept | `theme` — in **5** records, the subject of **none**. It greps as covered, and it has no entry in `CONTEXT.md`'s glossary either |
| Concepts in **no** record at all | `device wall` — zero hits, title or body. `screenshot` appears once, in ADR-0014, as something that record does not cover |
| Open issues | **1** (#18); 13 closed |
| Largest file | 477 lines, **14%** of its layer — no god-file is hiding several territories |

**The vertical chain is cut at the top, repository-wide.** The chain is
`prior art → decision → design → code`. No decision record here carries a named-prior-art
section, and **no decision record links to another** — so every `## Reference behaviour` is
blank, and a reader landing on ADR-0007 gets a two-entry allow-list with nothing pointing at
ADR-0012, which raised it to three. That is not a gap in the map; it is what the map found.

The largest public surface in the package — the settings panel, ten types — is governed by
nothing at all.

## The failure that justifies this layer

Two facts in this repository were rediscovered rather than consulted, and both were written
down *before* their last occurrence:

- **Classify by transitive dependency** — got wrong **three times in a row** while the shell
  was extracted, then **a fourth time, which shipped**. `PerformanceMetrics` arrived in the
  same commit as the note recording the lesson. The conclusion had been written; the test
  had not, and nothing connected the note to the territory where it would recur.
- **A guard must read the destination** — measured **three times**, in three unrelated
  territories. The third put a blank `code-pane.png` on the pub.dev front page for every
  release in which the tool existed, while `code_pane.dart` had already named the trap in a
  doc-comment. The warning was in one territory and the violation arrived from another.

Both are now invariant nodes, reachable from every territory they hold in.

## What this map cannot answer

- **Issues are not nodes.** Only `.md` files in this repo are. #18 appears only as a citation
  inside [the shell page composition](territory/shell-page-composition.md) and ADR-0014, and
  it will not appear in a graph view. Issues are cited as **evidence** — an observation that stays true after
  the issue closes — with the number demoted to a tracking pointer. A line that would become
  false on close is written the other way round.
- **Source files are not nodes.** `## Code` lists symbols as text.
- **The graph has no edge labels in Obsidian.** That is why a shared assumption between two
  territories that never call each other becomes an *invariant node* rather than an edge —
  the reason is readable as a node.
- **It does not say whether a decision was right**, only which one governs.

## Coverage, and what an absent note means

Complete over `lib/` — all 31 public types land in a territory. `test/` and `tool/` appear as
text inside the notes that own their behaviour. `example/` is **not** mapped: it is a
consumer of this package rather than part of it, and its roster is its own.

**An absent note is correct when** the area is a consumer's, or is only a plan.

**A note becomes owed when** a new public type is exported from the barrel, or when a second
site is found to share a fact an existing note already states. The second trigger is the
promotion obligation above, and it is the one that will actually fire.

An absent note is therefore **not** a backlog item by default. If you are touching something
and find no note, check those two conditions before assuming a gap.

## Conventions

- **Empty sections stay.** `**None.**` is a finding. Three different ones: *nobody decided*
  (no governing record), *nobody checked* (no reference comparison), *nobody built it* (no
  code). Query them scoped to their heading — the same sentinel marks all three.
- **Territories overlap.** Many-to-many is the default. `SettingsHost` is in two notes.
- **Symbols, never line numbers.** A line number is an ungated copy of something the compiler
  owns and is stale on the next edit.
- **Plain relative markdown links**, not wikilinks — Obsidian resolves both, GitHub only the
  former.
- **Blast radius names the reason per link.** A bare list degrades into "check everything".

## The nodes

Territories: [the seam](territory/the-seam.md) ·
[the menu and roster](territory/menu-and-roster.md) ·
[the preview stage](territory/preview-stage.md) ·
[the code pane](territory/code-pane.md) ·
[the settings panel](territory/settings-panel.md) ·
[the metrics panel](territory/metrics-panel.md) ·
[the theme and chrome](territory/theme-and-chrome.md) ·
[the shell page composition](territory/shell-page-composition.md) ·
[the published artifact](territory/published-artifact.md)

Invariants: [a subject is evidence, never vocabulary](invariant/subject-is-evidence-never-vocabulary.md) ·
[a guard reads the destination](invariant/guard-reads-the-destination.md) ·
[never hand-maintain a roster](invariant/never-hand-maintain-a-roster.md) ·
[classify by transitive dependency](invariant/classify-by-transitive-dependency.md) ·
[a green nobody watched fail is not evidence](invariant/watched-it-fail.md)

**There is no table here of what governs each**, deliberately — that is a roster, it restates
what the notes say, and nothing would keep it in step. The folder is the roster. Ask instead:

```sh
ls docs/map/territory/ docs/map/invariant/          # what exists

# Scope every sentinel query to its heading — the same sentinel marks three
# different holes, and an unscoped query reports the best-governed territory
# in the repo as ungoverned. Verified: scoped returns 2, unscoped returns 9.
rg -lU '## Governing decisions\r?\n\r?\n?\*\*None\.\*\*' docs/map/territory/
rg -lU '## Reference behaviour\r?\n\r?\n?\*\*None\.\*\*'  docs/map/territory/
rg -lU '## Code\r?\n\r?\n?\*\*None\.\*\*'                 docs/map/territory/

node docs/map/mapcheck.mjs                          # links, anchors, symbols, reciprocity
```

## The gate

[`mapcheck.mjs`](mapcheck.mjs) checks one note or all of them: the section set is exact, every
link and `#anchor` resolves, every symbol under `## Code` is in the tracked tree, no line
numbers, and **reciprocity** — every territory an invariant claims must claim it back, because
a one-way edge is invisible from the entry point where the reader actually stands.

Its scope is written next to it and re-derived from the tree, not hand-listed.

It found two defects in itself while being written, both of the predicted kind: it scanned a
hardcoded directory and exited 0 having inspected nothing, and it blanked inline code spans
before reading headings, which made the anchor for a heading containing `` `sleep` ``
unresolvable and would have condemned a correct link. **Do not act on a first run** — verify
the passing direction in the same session, and prefer fixing the document only after the
checker has been shown to be right.

<!-- grill-map build stamp: SKILL.md sha256:b647f0ba1b0d (no revision available) -->
<!-- ~/.claude/skills is not a git checkout on this machine, so `git log <stamp>..HEAD`
     cannot be run and no commit SHA can be recorded. The content hash above is a
     substitute that answers "has the skill changed" and not "what changed". A reader
     with a real checkout should replace it with the commit SHA. -->
