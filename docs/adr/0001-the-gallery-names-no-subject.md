# The gallery names no subject, in prose and in public API as well as in imports

This package is chrome that demonstrates another package without knowing which one, and
`portable_seam_test.dart` enforces that — over imports only. Everything else was true because
nobody had happened to violate it: twenty-two places in `lib/` and `test/` named a subject in
prose, and `PerformanceMetrics` named one in its fields. We decided the rule covers all three
surfaces, and reshaped the public API to match.

## Considered options

**The gallery formats its own numbers.** This is what the code did, and it is simpler: hand
`PerformanceMetrics` a `rowCount` and a `lastSortTimeMs` and let the panel abbreviate the count,
choose milliseconds over seconds, and divide one by the other for a rate. Rejected because each of
those three is a decision that can only be made by someone who knows one field is a tally and the
other a stopwatch. A gallery that makes them knows its subject is a table.

**Enforce the rule with a test, as the import rule is enforced.** A banned-word list over `lib/`
would catch "the table" and `TablePlusTheme`. Not taken yet: the same list would redden two
quotations we deliberately keep — a test name and a dated measurement — and a rule whose first act
is to acquire exemptions is weaker than the sweep it replaces. The property is currently held by
review, which is the honest description of it.

## Consequences

`Reading.value` is a `String`, not a number, and this is the shape a reader is most likely to
mistake for an oversight. The three formatters that used to live in the panel are gone with it.

Severity arrives with a reading rather than being computed from it, because the thresholds that
decide it are the subject's.

Nothing stops the next doc-comment from naming a subject again. Two quotations already do, on
purpose.
