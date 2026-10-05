# The metrics panel

## What it is
Named measurements about the subject, drawn without knowing what they measure. A reading is
one already-formatted measurement; severity is how much attention it is asking for. This is
the smallest territory and the clearest statement of the package's central move, because it
is the one that was got wrong first and then corrected in public.

## Governing decisions
**None.**

Five public types and no governing record. ADR-0001 sits adjacent — it decides that the
gallery names no subject, which is the *principle* this territory's design applies — but it
decides prose and imports, not the formatting seam. The strongest statement of that seam is
a doc-comment, not a record.

## Design model
**`Reading.value` is a `String`, and that is the seam.** `128.4K`, `1.28s` and `40K rows/sec`
are three different formatting decisions, and every one belongs to whoever knows what is
being counted. This file used to carry all three — a thousands abbreviator, a
milliseconds-or-seconds switch, and a rate dividing a count by a duration — which is the
shape of a gallery that knows one field is a tally and another is a stopwatch.

**Severity arrives with the reading rather than being computed here.** The panel used to
decide it from a row count against 1 000 / 10 000 / 50 000 — three numbers that are a fact
about one kind of table and about nothing else. A gallery holding them is a gallery that
knows its subject is a table. **That sentence names the subject on purpose**, because it is
the argument for the seam and the same sentence with the noun removed argues nothing; see
[a subject is evidence, never vocabulary](../invariant/subject-is-evidence-never-vocabulary.md).

**Status colour is ink, never ground.** It survives on an icon and on text; a severity
expressed as a background would be a second hue on a chrome that carries none.

## Code
`lib/src/metrics/metrics_panel.dart` — `ReadingSeverity`, `Reading`, `Metrics`, `MetricsPanel`, `MetricsChip`
`test/metrics_panel_test.dart` — five rules, each written against a mutation that reddens it

## Reference behaviour
**None.**

Never compared to a reference, and there is no obvious one — the formatting seam is this
package's own move rather than an adaptation.

## Cross-cutting invariants
→ [a subject is evidence, never vocabulary](../invariant/subject-is-evidence-never-vocabulary.md)
→ [classify by transitive dependency](../invariant/classify-by-transitive-dependency.md)
→ [a green nobody watched fail is not evidence](../invariant/watched-it-fail.md)

## Blast radius
→ [the theme and chrome](theme-and-chrome.md) — severity is drawn as ink, so it depends on
  the achromatic-chrome rule holding; a chrome that gained a hue would collide with it
→ [the seam](the-seam.md) — readings arrive from the consumer, and the formatting contract is
  a seam rule even though no port carries it

## Known holes / open
- **`Metrics` is not delivered by any port.** The other two panes receive their data through
  `ShellDestinations` and `SettingsHost`; readings arrive as a widget argument. Nothing
  records whether that is deliberate or simply not yet needed, so the three-ports claim in
  ADR-0003 and this territory do not obviously agree.
- `PerformanceMetrics` was the type that made [classify by transitive
  dependency](../invariant/classify-by-transitive-dependency.md) ship: it imported nothing
  but `material.dart`, so the seam test passed it, while its fields and thresholds were the
  subject's. Nothing currently gates a repeat of exactly that shape.
