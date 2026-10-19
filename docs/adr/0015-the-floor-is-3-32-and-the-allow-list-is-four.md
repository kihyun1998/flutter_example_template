# The floor is 3.32, and the allow-list is four

`environment` names `sdk: ^3.8.0` and `flutter: ">=3.32.0"`. `flutter_smooth_wheel_scroll` is a
dependency, and `portable_seam_test.dart` allows a fourth import prefix. The Code pane is the one
place that uses it: both of its scroll views take a `SmoothScrollController`, so a mouse wheel
notch animates down the file and along a long line instead of jumping.

## What sets the floor

Two manifests, neither of them this package's. `flutter_smooth_wheel_scroll` declares Flutter
3.32 / Dart 3.8, and `flutter_syntax_highlight` 0.3.0 declares the same because it took the first
as a dependency. Nothing in this package's own code is above 3.27.0 — the line
[ADR-0011](0011-the-sdk-floor-is-measured.md) named, `CardThemeData`, is still the highest thing
here and is now under the floor.

So this is the case ADR-0012 ended on: *"A dependency that raised it would have been a different
decision, and is the first thing to check on the next one."* It is that decision.

## The measurement

Both suites resolve, analyse clean and pass on Flutter 3.32.0 and on 3.47.7, on Ubuntu and on
Windows — CI run 39180519258 on 2026-10-19, the floor leg moved to 3.32.0 in the same commit as the
manifest. Below 3.32.0 nothing is run, because pub refuses to resolve; the code itself was not
measured further down, and there is no point measuring it while the dependencies hold the line.

## What it costs

**A consumer on Flutter 3.27–3.31 stays on 0.3.0.** That is the whole of the price, and it lands on
an example app's toolchain rather than on anyone's users — [ADR-0002](0002-depended-on-not-copied.md)'s
argument, as in ADR-0012.

**The allow-list was three and is four.** ADR-0012's title stays true of the day it was written;
this record supersedes only the count.

## Why it earns an entry

The Code pane is where a reader reads, top to bottom, and on Flutter desktop every wheel
notch jumps it. Flutter has no setting for that: `ScrollBehavior` and `ScrollPhysics` cover dragging
and flinging, not wheel input. Like the tokenizer, the package draws nothing — it is a
`ScrollController`, and the chrome around it stays this package's.

`flutter_syntax_highlight` 0.3.0 depending on a scroll package does not change what ADR-0012 took
from it. This package still uses `tokenizeDart` and nothing else, so *"a tokenizer draws nothing"*
still describes everything taken from there.

## Where it stops

**Both axes of the Code pane, and nothing else.** Vertical only was proposed. Both axes, matching
`SyntaxText` in 0.3.0, was the maintainer's call on #24, and it is theirs to reverse. The menu and
the settings lists are short enough that a jump costs nothing. The stage is ruled out, because a
subject's own scroll views live there, and chrome that scrolls differently from the subject inside
it would have the reader judging one against the other.

**No `SmoothWheelBinding`.** How far a notch travels is app-wide, and the app is the consumer's.
A library that installed a binding would be setting it for them. The example does not install one
either, so it shows the gallery the way a consumer gets it.

**The barrel exports nothing new**, for the reason ADR-0012 gave about `tokenizeDart`.

## Consequences

**`flutter_lints` is `^6.0.0`.** Its range, `>=5.0.0 <7.0.0`, existed because 6 needs Dart 3.8 and
the floor was below that. It no longer is.

**The language version is 3.8, and the formatter's style moved with it.** The tree was reformatted
once, as its own commit, by Dart 3.11.5. ADR-0011's point that no other SDK will agree with it byte
for byte still holds.
