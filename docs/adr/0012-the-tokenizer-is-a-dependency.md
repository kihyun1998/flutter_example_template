# The tokenizer is a dependency, and the allow-list is three

`lib/src/shell/dart_highlighter.dart` is gone. `flutter_syntax_highlight` — the package it was
extracted into — is a dependency, and `portable_seam_test.dart` allows a third import prefix.

## What the copy was costing

The two were measured against each other before this was decided, over four real files and 38,492
characters. Both hold the partition property. They disagree on 1,821 characters, and every
disagreement is the package being the finer of the two:

- 1,779 characters the copy calls `plain` and the package calls `function`.
- 42 characters inside string interpolation. `'${width.toInt()} px'` is one `string` token to the
  copy; the package descends into `${…}` and tokenizes what is in there, which is what a reader
  expects and what the copy was getting wrong.

The package carries two kinds the copy never had — `escape` and `function` — in 638 lines
against 485. The drift this was filed to prevent had already happened. Keeping the copy would not have been
holding a position; it would have been maintaining a second roster by hand, which
[`docs/agents/lessons.md`](../agents/lessons.md) already says not to do.

## What taking it costs

The list in `portable_seam_test.dart` was two entries and the README said so as a headline. It is
three. That list was always described as growing "one dependency at a time, on purpose", and this is
what that sentence was written for — but a sentence being honoured does not make the cost nothing.

**[ADR-0007](0007-no-demo-framework.md) does not forbid it.** What that decision refuses is a demo
framework: something that puts its own chrome, vocabulary and branding on screen, so the reader ends
up learning it instead. A tokenizer draws nothing. It decides what a kind *is*, and what a kind
looks like stays in `code_pane.dart` — the same seam as before, spanning a package boundary now
instead of a file one.

**The transitive cost lands on an example app, not on anyone's users.** A consumer depends on this
package from their `example/pubspec.yaml`, and that does not flow to whoever depends on *their*
package. [ADR-0002](0002-depended-on-not-copied.md) makes that argument about depending on this
one, and it carries to what this one depends on.

## Consequences

**The barrel no longer exports `tokenizeDart`.** It is not this package's to export. Anyone wanting
the tokenizer takes `flutter_syntax_highlight` directly, where its own documentation and its own
decision records are. Settled while 0.1.0 was still unpublished, which was the only moment it cost
nothing.

**The Code pane declines two of the eight kinds**, and says so where it maps them. `escape` reads as
the string around it and `function` as plain, because this chrome has no hue to spend and the one
axis left to it is already carrying keywords. A tokenizer offering more than the chrome takes is the
seam working, not a gap in it.

**The floor did not move.** `flutter_syntax_highlight` declares `sdk: >=3.6.0` and
`flutter: >=3.27.0` — the same floor [ADR-0011](0011-the-sdk-floor-is-measured.md) measured
here. A dependency that raised it would have been a different decision, and is the first thing to
check on the next one.
