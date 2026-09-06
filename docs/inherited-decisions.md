# Inherited decisions

**This file is raw material, not a decision record.** It exists to be read once,
turned into `CONTEXT.md` and `docs/adr/` in this repository's own voice, and then
deleted. A document that survives that step becomes the second unread copy of
everything below, and drifts on its own.

`lib/` arrived here by transplant from the example app of a Flutter table
package, where it was built over roughly a dozen tickets. **17% of that code is
doc-comments** and all of it came along, so the *reasoning behind what is there*
is already in the files. What could not travel is the reasoning behind **what is
not there** — the alternatives that were tried, measured and refused. Those live
only in issues and commit messages of a repository this one has no link to, and
they are the ones that get re-proposed.

Every measurement below is dated. A number is the evidence; the path it was
measured at is not, and has been dropped.

---

## The shape

**Three ports carry everything a consumer supplies**, and every member on each
was read off a call site rather than designed. When a port grew a member that
nobody was calling, it was not added.

- `ShellDestinations` — what the menu points at, **and its lifetime**. A bare
  `List` was rejected: the shell's state owned four `ChangeNotifier`s *and*
  disposed them, so handing it a list would move the building out and leave the
  disposing behind. A leaked notifier throws nothing and fails no test.
- `SettingsHost` — a settings panel over a settings object this package must not
  name. Five members: walk the spec, read a switch, write a switch, build one
  control, contribute widgets a control cannot express.
- `PresetSummary` — id, title, and the line saying **what to watch** once the
  preset is applied. What a preset *turns on* is deliberately absent: the bar
  never reads it, and carrying it would put a consumer's vocabulary here for a
  field nothing here looks at.

**Writes are commands, never values.** `setSwitch(id, on)` and
`applyPreset(id)`, not "here is the new settings object". Constructing the value
is exactly the step that would require knowing the type.

**Everything optional is opt-in and silent when unclaimed.** Extras hooks and
`presets` default to empty; a `PresetBar` over an empty list draws *no widget*,
not an empty strip with a rule under it — chrome announcing a capability that is
not there. A host given no way to apply a preset should report none rather than
offering chips that do nothing.

## The barrel rule, and why it needs a test

Nothing outside `lib/src/` may import into it. **Both halves of this are legal
Dart**: a consumer's `package:…/src/x.dart` resolves, compiles and passes, right
up until somebody enforces the convention. There is no error in between, so a
rule is the only thing that can catch it.

`test/portable_seam_test.dart` holds three properties the compiler will not:
nothing in `lib/` names a package outside Flutter, nothing outside `src/` reaches
into it (the suite stands in as this package's first consumer), and the barrel
and the tree name the same set of files, in both directions.

## Refused, with the reason — these will be proposed again

**A demo framework** (`widgetbook`, `device_preview`, `device_frame`). An
example that imports a demo framework demonstrates the framework. This is the
reason the whole shell was hand-built rather than assembled, and it is the
reason this package should stay dependency-free for as long as it can.

**Fetching the chrome font over the network** (`google_fonts` or similar). Four
grounds, and the first is a measurement from inside this code: the source pane
already refused it for the same reason — a pane whose job is to show bytes on
disk should not need the network to draw them.
- Offline. Somebody evaluating a package from pub.dev runs its example wherever
  they are.
- First paint is the shop window. A fetched face draws a fallback and reflows.
- A test suite gains nothing: the widget-test font draws every glyph as a square
  of the font size, so the face is invisible to assertions either way.
- A **library** making an outbound request at launch is a different objection
  from an application doing it, and a consumer cannot opt out of it.

**Bundling a font inside this package**, for the mirror reason: it decides what
the consumer's application looks like, and hands them files they did not choose
and cannot remove. The family is a parameter; producing the face belongs to
whoever chose it.

**Line numbers in the source pane.** Refused on the pane's own ground — it is the
affordance of a pasteable claim, not a source viewer. The natural implementation
is also the broken one: an inline gutter of placeholder spans writes `\u{FFFC}`
into every copied line, because `SelectableText` leaves `includePlaceholders` at
its default and only *documents* that children must be `TextSpan`s.

**Two gates that were considered and declined.** A repeatable extraction probe —
it duplicates what `portable_seam_test` and `settings_host_test` already assert,
and it cannot see runtime portability anyway (it was green while a font was
missing). And a README link checker — a rare papercut whose automation should
wait for a second occurrence rather than a first scare.

## Measurements worth keeping

- **2026-08-26.** The preview frame must contain its own `Overlay`. Everything
  opening *above* a page — a `Draggable`'s feedback, a tooltip, a menu — resolves
  to the *nearest* overlay, and with none inside the frame that is the app root,
  which sits above the fit transform. Measured: the table drew at 0.46× and the
  thing dragged out of it at 1:1 over the whole window — 91.7px against 200px.
- **2026-09-01.** The device wall is live, and the two reasons for making it
  inert both failed. The three frames do not share a scale: each is fit into an
  equal column and never scales up, so at 1800px the desktop frame is 0.28× (an
  11px row), tablet 0.48×, and **mobile 1.0×, at its full 40px** — the narrowest
  viewport is both the one most worth poking and the one drawn at real size. An
  `IgnorePointer` would also have been half a decision: it vetoes hit testing
  only, and focus traversal plus `Actions` bypass it — 20 of 40 Tab presses
  landed inside a wall table regardless.
- **2026-09-01.** `SegmentedButton` asserts that its segments are non-empty and
  that the selection is non-empty, and **nothing** that the selection is one of
  the segments; the highlight is decided per segment by `contains`. So a
  selection matching no segment draws as no highlight at all, silently. Hiding a
  segment is therefore only half of excluding a mode — leaving the mode is the
  other half, and nothing reports the omission.
- **2026-09-02.** A Dart scanner must consume a comment *whole*. Grepped over an
  eleven-file corpus: 54 comment lines contain a lone apostrophe. A scanner
  examining characters one at a time opens a string on every one of them. It is
  **not** the order of the branches — that was asserted, tested by reversing
  them, and withdrawn.
- **2026-09-06.** `ThemeData` exposes **no `fontFamily` getter**; the constructor
  argument is applied to `textTheme` and `primaryTextTheme` and is readable
  nowhere else. And with no family given, Flutter's own Material typography names
  `Roboto`, which Flutter ships — **the default is not null**. Both of these
  moved a test that had been written from a wrong model.

## Mistakes worth inheriting

**Classify by transitive dependency, never by direct import.** This was got wrong
three times in a row. Files that named no package were still unmovable because
they were *typed* on a class that did. The figure claimed for "already portable"
was 1,689 lines; the measured figure was 644.

**A guard must read the destination, never the source.** A check that reads where
a value came from passes anything that acquired it another way. Measured three
times here: a theme audit that read a palette object instead of what was painted,
and a monospace assertion that read the wrapper `SelectableText` puts around a
span tree instead of the leaf that names the family. Both were green while the
defect was on screen.

**A green from a test nobody watched fail is not evidence — and neither is a
red.** Every rule in `test/portable_seam_test.dart` and `test/settings_host_test.dart`
was mutated and watched failing before it was believed, in this repository, after
the copy. One of them found a real gap: the ordinary fake overrode `presets`, so
the port's empty default was asserted **nowhere**, and a port that started handing
out presets nobody declared would have shipped. A second fake now overrides only
what the port leaves abstract. Separately, the seam test's own first red was a
false one — a resolver bug made every same-directory import read as leaving the
package.

**Never hand-maintain a roster.** The seam test once named three areas while the
tree held five, and it was already wrong in the commit that wrote it. Both rosters
now read the tree.

## Not transplanted, on purpose

The recipes, the scenarios, the demo data, the 58 settings and the registry rows
that build their controls — all of it was content, belonging to the package being
demonstrated. This package holds the mechanism and none of the subject.

## Open, for this repository to decide

1. **Depended on, or copied?** The name says template; the shape — a barrel,
   `src/`, three ports — is a library. Both work; they are not the same package.
2. **The palette.** The chrome font became a parameter; the colours are still
   fixed. If a second consumer wants its own identity, this is the next port.
3. **What `example/` demonstrates.** A package whose subject is "how to build a
   good example" is refuted by a bad one. It should probably demonstrate
   *something other than* the table package this came from, so that the tree
   itself shows nothing is table-specific.
4. **The bundled Dart tokenizer** (`lib/src/shell/dart_highlighter.dart`, 424
   lines, zero imports). It is being extracted into a package of its own
   elsewhere. When that lands, depending on it costs this package its
   Flutter-only dependency list — which is a claim `portable_seam_test` currently
   enforces with a two-entry allow-list.
