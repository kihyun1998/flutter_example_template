# The barrel is the only public surface, and a test is what holds it

Nothing outside `lib/src/` may import into it. A symbol is exported by the barrel or it is not
public.

**Both halves of this are legal Dart.** A consumer's `package:…/src/x.dart` resolves, compiles and
passes, right up until somebody enforces the convention — a lint, a consumer's own rule, or anyone
who reads the convention and believes it. There is no error in between, so a test is the only thing
that can catch it.

## Consequences

`test/portable_seam_test.dart` holds three properties the compiler will not: nothing in `lib/` names
a package outside Flutter, nothing outside `src/` reaches into it, and the barrel and the tree name
the same set of files in both directions.

There is no application in this repository to hold to the second one, so **the test suite stands in
as this package's first consumer**. A test that reaches past the barrel is the first thing to prove
the barrel is optional.

The rules resolve every import to a path under `lib/` rather than matching spellings. Three ways of
writing the same import are one question — does this leave the zone — and a list of allowed
spellings is a roster that goes stale.
