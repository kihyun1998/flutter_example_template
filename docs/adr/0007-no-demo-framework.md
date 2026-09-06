# No demo framework

`widgetbook`, `device_preview` and `device_frame` were all available and all refused. **An example
that imports a demo framework demonstrates the framework.**

This is the reason the whole shell was hand-built rather than assembled, and the reason this package
should stay dependency-free for as long as it can — `portable_seam_test.dart` currently enforces
that with a two-entry allow-list, `dart:` and `package:flutter/`.

## Consequences

It is the objection [ADR-0002](./0002-depended-on-not-copied.md) had to answer for itself, since a
consumer's `example/` depending on this package is arguably the same shape with our own name on it.
The difference recorded there is that a demo framework puts its own chrome, vocabulary and branding
on screen, and this one names nothing and carries no hue.

The cost is that everything the frameworks would have supplied — the viewport frames, the wall, the
menu — is ours to build and ours to keep working.
