# No line numbers in the Code pane

Refused on the pane's own ground: it is the affordance of a pasteable claim, not a source viewer.
Numbers down the left are what a viewer has.

**The natural implementation is also the broken one.** An inline gutter of placeholder spans writes
`\u{FFFC}` into every copied line, because `SelectableText` leaves `includePlaceholders` at its
default and only *documents* that children must be `TextSpan`s. So the feature that makes the pane
look more like a source viewer is the feature that breaks the one thing it is for.

## Consequences

The same standard applies to anything else that stands between the bundle's bytes and the clipboard.
The highlighter is held to it structurally: `tokenizeDart` returns a partition, so concatenating
every token reproduces the input byte for byte.
