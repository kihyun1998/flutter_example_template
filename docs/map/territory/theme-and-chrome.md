# The theme and chrome

## What it is
The gallery's own interface around the subject — the app bar, the menu, the panes a reader
operates — and the rule that it carries no colour of its own. It themes the *application*;
the subject's own theme is the consumer's, built from its settings.

**This territory has no entry in [`CONTEXT.md`](../../../CONTEXT.md)'s glossary.** Five areas
are defined there and this is not one of them, which is consistent with what the records
show: it is the least-named area in a repository whose central discipline is naming.

## Governing decisions
→ [ADR-0008 — the chrome font is a parameter: neither fetched nor bundled](../../adr/0008-the-chrome-font-is-a-parameter.md)
→ [ADR-0013 — the palette is not a port, until a second consumer asks](../../adr/0013-the-palette-is-not-a-port-yet.md)

**Both records decide what this territory does *not* own.** One pushes the font out to a
parameter, the other declines to push the palette out to a port. Neither decides the
achromatic rule itself, which is the territory's actual spine and lives in a doc-comment.
`theme` is mentioned in five records and is the subject of none — so it greps as covered.

## Design model
**The chrome carries no hue at all.** This is made for the demo's purpose rather than for
taste: with an achromatic chrome, the only colour anywhere on screen is the one the subject
is wearing, so *"this colour is something you set"* needs no caption. A chrome with an accent
of its own would put two colours on screen and lose that.

**The cost is that state has nowhere to go but value.** A switch, a selected menu row and a
slider all express themselves through lightness alone — which is why `accent` is near-black
on light and near-white on dark, the strongest contrast available without a hue.

**Semantic colour is exempt.** `error` stays red, because a failure that reads as a shade of
grey is not a failure anyone notices.

**`exampleTheme` is a pure function of its arguments**, which is what lets a test assert on
it without pumping a widget.

**This package carries no font.** The chrome family arrives as an argument; fetching one over
the network and bundling one here were both refused (ADR-0008).

## Code
`lib/src/theme/example_theme.dart` — `ExampleThemeController`, `ExampleThemeScope`
`lib/src/theme/theme_mode_button.dart` — `ThemeModeButton`
`test/example_theme_test.dart` — the styled surfaces, against a hand-written map

## Reference behaviour
**None.**

Never compared to a reference. The Flutter SDK is spec-binding for `ThemeData` and
`ColorScheme` semantics and is reachable raw — see
[`docs/agents/thegraph.md`](../../agents/thegraph.md).

## Cross-cutting invariants
→ [a guard reads the destination](../invariant/guard-reads-the-destination.md)
→ [never hand-maintain a roster](../invariant/never-hand-maintain-a-roster.md)

## Blast radius
→ [the metrics panel](metrics-panel.md) — severity is drawn as ink because the chrome has no
  hue; giving the chrome an accent collides with it directly
→ [the settings panel](settings-panel.md) — every control expresses its state through
  lightness, so a palette change is a legibility change across the whole panel
→ [the code pane](code-pane.md) — the pane's monospace family is chrome, and it rendered in
  the proportional chrome font for six releases
→ [the preview stage](preview-stage.md) — `ViewportSpec.showsChrome` decides whether the
  furniture survives at a given width
→ [the published artifact](published-artifact.md) — a consumer shipping its own face needs
  the font contract, which is README material

## Known holes / open
- **The achromatic rule — the thing that actually governs this territory — is recorded only
  in a doc-comment.** Both ADRs here decide adjacent questions. A change that gave the chrome
  an accent would contradict no record.
- `test/example_theme_test.dart` says a fifth styled surface added later is invisible to its
  hand-written map. That is a hand-maintained roster with the warning already written on it,
  and it is exempted deliberately rather than derived; see
  [never hand-maintain a roster](../invariant/never-hand-maintain-a-roster.md).
- ADR-0013 defers the palette port *"until a second consumer asks"*. There is now a second
  consumer — `flutter_dropdown_button`, named in the README — and nothing records whether it
  asked. The deferral's own trigger condition may have fired unnoticed.
