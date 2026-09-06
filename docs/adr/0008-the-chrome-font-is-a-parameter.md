# The chrome font is a parameter: neither fetched nor bundled

`exampleTheme` takes a family name and nothing more. This package ships no typeface and names none.

## Fetching one over the network, refused

`google_fonts` or anything like it, on four grounds — the first of which is a measurement from
inside this code, since the Code pane had already refused the network for the same reason:

- **Offline.** Somebody evaluating a package from pub.dev runs its example wherever they are.
- **First paint is the shop window.** A fetched face draws a fallback and reflows.
- **A test suite gains nothing.** The widget-test font draws every glyph as a square of the font
  size, so the face is invisible to assertions either way.
- **A library making an outbound request at launch is a different objection from an application
  doing it**, and a consumer cannot opt out of it.

## Bundling one here, refused for the mirror reason

It decides what the consumer's application looks like and hands them files they did not choose and
cannot remove. Producing the face belongs to whoever chose it.

## Consequences

**A missing glyph does not throw.** Flutter draws it from another face, so a subset missing a
character renders as a typeface seam mid-sentence rather than as an error. This package once named
`Pretendard` here while the four weights behind that name lived in an example app's assets; the name
travelled into the portable zone and the files did not, and nothing reported it.

Assert a font's coverage by reading the shipped `cmap`, never by reading the script that produced it.
