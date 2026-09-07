# example

The example app for [`flutter_example_template`](../), and the demonstration of the claim the shell
makes: everything drawn *around* the widget is the package, and everything specific to the widget is
in this directory.

## What it demonstrates

An **adaptive action bar** — a row of actions that folds into an overflow menu as it runs out of
width. Deliberately not a table. The shell was extracted from a table package's example app, so a
gallery that could only be shown demonstrating a table would not have proven the extraction worked
([#2](../../../issues/2)).

## Running it

```
flutter run -d chrome
```

`web/` and `macos/` are the runners checked in, so `-d chrome` works anywhere and `-d macos` on a
Mac. Nothing in the shell is web-specific; those are just what this repository carries.

## The tree, and the rule each part obeys

| | |
| --- | --- |
| `subject/` | The package being demonstrated. **Imports no shell** — a consumer's package does not know it is being demonstrated. |
| `recipes/` | Self-contained files. Paste one into an app that has the package and it runs: Flutter and the subject, nothing else. Bundled as assets, so the Code pane reads the file that is executing rather than a copy of it. |
| `scenarios/` | The bar doing its job inside something — several things assembled, which is where the knobs meet a realistic composition. Passes no `source`, on purpose. |
| `pages/` | A full page with its own `Scaffold`, opened on its own route rather than taken apart to fit the stage. |
| `gallery/` | The one place that knows both sides: what the menu points at, who owns the state behind it, and this consumer's implementation of the settings port. |
| `main.dart` | The only file that *has* to know the shell exists. |

Read down that table and the seam is the row it stops at. Above it, nothing has heard of the shell;
below it, two files have.

## What holds it

`test/pasteable_seam_test.dart` is the fourth seam rule — the one
[ADR-0002](../docs/adr/0002-depended-on-not-copied.md) argued for and then declined to write, because
the package has no destinations of its own and the rule would have walked nothing and passed. It
lands here, against real recipes. Five assertions:

- every source a destination points at exists and is bundled;
- **no file the Code pane shows imports the shell** — the one that makes "pasteable" true;
- every bundled recipe is reachable from a destination;
- every import line is actually read, since the rules above are filters and a regex matching nothing
  would report no offences and pass;
- there is something to check at all, so a tree that emptied out fails here instead of going quiet.

`test/settings_panel_test.dart` holds the other five: that the settings description and the host
answer to each other, id for id.

## The same story from the other side

The root [`README.md`](../README.md) tells this from the shell's point of view — what a consumer
gets, and what the shell refuses to know. This directory is what a consumer actually writes.
