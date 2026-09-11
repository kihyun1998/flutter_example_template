# thegraph

What a person already knows and no file in this repo answers. It is appended to when a
run needs something that is not here; it is never recompiled, because nothing here was
compiled from anything.

## What this project is

A reusable example-app shell for Flutter packages, which names no subject — the consumer
supplies one through three ports.

## References

| Source | Informs | Reached by | Binding |
|---|---|---|---|
| Flutter SDK | how it works | its source tree at `D:\flutter\packages\` — raw | spec |
| `flutter_syntax_highlight` | how it works | the sibling checkout at `D:\github\flutter_syntax_highlight` — raw | spec |
| pub.dev package layout and publishing rules | where files go | dart.dev docs — **summarized** | spec |
| The maintainer's other `flutter_*` packages | where files go | their real trees under `D:\github\` — raw | example |

**Informs** routes it: *how it works* is read while building and reviewing, *where files
go* while deciding a file's home.

**Binding** decides what a disagreement means. Diverging from an `example` is a choice
worth recording; diverging from a `spec` is a bug.

**Summarized** sources never settle a question outright — what rests on one carries
forward as *needs confirming against the real thing*.
