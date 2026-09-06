# This package is depended on, not copied

The name says template; the shape — a barrel, `src/`, three ports — is a library. We publish, and a
consumer's `example/` takes a dependency rather than copying `lib/` into itself. `pubspec.yaml`
keeps no `publish_to: none`.

## The objection this had to answer

`docs/inherited-decisions.md` records the rejection of demo frameworks — `widgetbook`,
`device_preview`, `device_frame` — on the ground that *an example that imports a demo framework
demonstrates the framework*. A consumer's `example/` depending on this package is arguably that
same shape with our own name on it, and that is the reason this was left open rather than assumed.

It is not the same shape, and the difference is nameable. What a demo framework puts on screen is
its own chrome, its own vocabulary and its own branding; the reader ends up learning it. This
package's chrome carries no hue for exactly that reason — see `exampleTheme`, where the only colour
anywhere on screen is the one the subject is wearing — and it names nothing. A shell with no name on
screen cannot be the thing demonstrated.

The dependency also costs a consumer's own users nothing. `example/` is a separate package; its
pubspec does not flow to anyone who depends on the package being demonstrated. The
dependency-freedom this project holds itself to is a rule about *this* package — a two-entry
allow-list in `portable_seam_test.dart` — not a rule imposed on consumers.

## The boundary that makes it safe

The sharpest form of the objection survives all of that: a consumer's `example/main.dart` will read
`import 'package:flutter_example_template/…'`, and the Code pane's whole thesis is that what is on
screen is what you can paste.

It survives because **the pasteable unit never imports the shell**. A recipe is handed to a
destination as a builder — `StageDestination(stage: (c) => MyRecipe())` — and knows nothing about
what is hosting it. One file in a consumer's example knows this package exists, and it is not one of
the files the Code pane shows.

## Consequences

That boundary is a property, not a habit, and it is legal Dart when violated — the same class as the
three rules the seam suite already holds. It should be a fourth: *a file a destination's `source`
points at names no shell.*

**It cannot be written here yet.** This repository has no destinations, so the rule would walk
nothing and pass, which is the shape `portable_seam_test.dart` already guards against with its
"lib is not empty" case. It lands with `example/`, against real recipes, and is watched failing
before it is believed.

Until then the boundary is held by review, which is the honest description of it.
