# The SDK floor is measured, and one line sets it

`environment` names `sdk: ^3.6.0` and `flutter: ">=3.27.0"`. Both ends were run before either was
written: the package and the example resolve, analyse clean and pass — 23 tests and 11, as the
suites stood on 2026-09-06 — on 3.27.0 and on 3.41.9, and 3.24.5 fails with exactly one error.

Those two numbers are dated on purpose. They are evidence that real suites were run rather than
nothing, which is a fact about the measurement and stays true; they are not a description of the
suites today, and reading them as one is how a record turns into a wrong answer. The manifest used
to carry the same pair as a live claim and has stopped.

The numbers this replaced were `^3.13.1`, which `flutter create` left in the initial commit, and
`">=3.47.0"`, raised at release prep to whatever the package happened to be built on. Neither had
been run against anything. A floor that nobody measured is not a compatibility claim; it is the
build machine's version wearing one.

## What sets it

`CardThemeData`, in `example_theme.dart`. Flutter added it in 3.27.0, and by 3.41.9 it is the only
type `ThemeData.cardTheme` accepts.

## Why it is not lower

Swapping that one line for the pre-3.27 `CardTheme` turns 3.24.5 fully green, so the code itself
would run further down — `WidgetStateProperty` and `surfaceContainerLow`, both 3.22.0, are the next
wall. It is not swapped, because **no Flutter accepts both spellings**. Reaching down gains three
stable releases and loses every release above 3.27, which is not widening the range but moving it.

This is recorded because "why not lower still" is the kind of question that gets asked again, and
the tree shows the line without showing what it costs.

## Consequences

**No SDK but one agrees with how this tree is formatted.** Measured over the 36 Dart files under
`lib/`, `test/` and `example/`: Dart 3.11.5 would rewrite 9 of them, and Dart 3.6.0 — the floor —
would rewrite 17, 73 lines of that inside `lib/` alone. The drift grows with the distance from
whatever formatted the tree, and lowering the floor widened the span rather than creating it. So
`dart format --set-exit-if-changed` is not a gate this repository can run: it would be red on every
leg of CI but one. It is recorded here because it is the check most likely to be proposed by
somebody reading a workflow file that does not contain it.

**A dev dependency can make the claim uncheckable.** `flutter_lints 6` needs Dart 3.8, above the
floor. A consumer never sees it, since dev dependencies are not inherited — the person it strands is
whoever clones the repo at the floor to verify the claim. It is a range, `>=5.0.0 <7.0.0`, and pub
picks 6 above and 5 at the floor.

**Raising the floor is a measurement, not an edit.** Whatever moves it gets named the way
`CardThemeData` is named here, and both ends get run again.
