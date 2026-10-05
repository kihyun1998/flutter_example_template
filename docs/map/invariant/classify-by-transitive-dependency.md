# Classify by transitive dependency, never by direct import

## The fact
Whether a file is portable is not a question about its import list. A file that names no
package can still be unmovable, because it is *typed* on something that does.

**The import graph is the cheap question. The one that matters is what a type is made of.**

## Why it is cross-cutting
The shared assumption is that a module's dependencies are visible at its top. They are not —
a public field's type carries the whole graph behind it, silently, and that is true in any
territory that defines types crossing the seam.

The sites do not call each other: a portability test and a metrics widget share no code. They
share the property that **both were judged by reading imports**.

## Territories it holds in
→ [the seam](../territory/the-seam.md) — the rule was found while the shell was being
  extracted, and `portable_seam_test.dart` is what enforces it now
→ [the settings panel](../territory/settings-panel.md) — the three panes were typed on the
  subject's own settings class while importing nothing that named it
→ [the metrics panel](../territory/metrics-panel.md) — `PerformanceMetrics` is the instance
  that shipped

## What a violation looks like
A type that imports only `material.dart` and whose *fields* are the subject's.

The shipped case is exact. `PerformanceMetrics` imported nothing but `material.dart`, so
`portable_seam_test.dart` passed it — and its fields were `rowCount`, `lastSortTimeMs` and
`dataGenerationTimeMs`, with severity thresholds of 1 000 / 10 000 / 50 000 written into the
widget that drew them.

**Two conditions made it invisible, and both are the recurrence condition.** It arrived in
the same commit as the note recording the lesson. And nothing in the package referenced it,
so neither seam suite ever ran it — an unreferenced type is outside every check that works by
reachability.

## Discovery history
→ [`lessons.md` — classify by transitive dependency, never by direct import](../../agents/lessons.md#classify-by-transitive-dependency-never-by-direct-import)

**Got wrong three times in a row** while the shell was being extracted. The figure claimed for
"already portable" was 1,689 lines; the measured figure was 644.

**Then a fourth time, and that one shipped.** That is the count this note exists for: three
rediscoveries in one session did not prevent the fourth, because what was written down was the
conclusion rather than the test.

## Where it will recur
Any time a type is added that crosses the seam, and any time portability is *claimed* rather
than measured.

The test a future author can run: for each public field and each type parameter, ask what the
type is made of — not what the file imports. If a field's name would only make sense to
someone who knows the subject, the file is not portable however clean its import list is.

The second half is the cheaper guard and is currently missing: **a type nothing references is
checked by nothing.** Before trusting a seam suite, confirm the type under discussion is
actually reachable from it.
