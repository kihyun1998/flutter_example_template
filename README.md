# flutter_example_template

An example-app shell for Flutter packages.

Writing a good example for a package is most of a small app: a menu, somewhere to put the widget,
some controls, and a way to show the code. This is that app, with the part that knows *which*
package removed. You supply what to demonstrate; the shell draws everything around it.

![The shell at desktop width: a category menu, a preview stage and a knob region](https://raw.githubusercontent.com/kihyun1998/flutter_example_template/main/docs/images/shell.png)

## What a consumer gets

- **A category menu** over recipes, scenarios and full pages.
- **A preview stage** that renders your widget at desktop, tablet and phone widths — constrained
  *and* told that is the whole screen, with its own `Overlay` so tooltips and drags stay inside the
  frame.
- **A Device Wall**: all three viewports at once, live, over one shared state. The single-viewport
  modes answer *what does this look like at that width*; the wall answers *what changed between
  them*.
- **A Code pane** that reads the running file out of the asset bundle, so what is on screen and
  what executes cannot disagree. With Dart syntax highlighting that is a partition — concatenating
  every token reproduces the file byte for byte, so what you copy is what shipped.
- **A settings panel** driven from a description: groups, features, the options each feature owns,
  and the interactions between them. Search reads control labels, so a setting can be found without
  opening the feature that holds it.
- **A theme** for the chrome that carries no hue at all, so the only colour on screen is the one
  your package is wearing.

## What it looks like

**The Device Wall.** Three viewports at once, live, over one set of knobs. The example's subject is
an action bar that gives up labels and then whole actions as room runs out, so the desktop frame
holds all ten, the tablet frame eight, and the phone frame three and a menu — in one image, rather
than held against a memory of the previous mode.

![Desktop, tablet and phone frames side by side, each holding a different number of actions](https://raw.githubusercontent.com/kihyun1998/flutter_example_template/main/docs/images/device-wall.png)

**The Code pane.** The running file, read out of the asset bundle and tokenised into a partition, so
what is on screen is what you can paste.

![A recipe's source with its asset path above it and a copy button](https://raw.githubusercontent.com/kihyun1998/flutter_example_template/main/docs/images/code-pane.png)

**The settings panel.** A preset applied, with the line that earns it its name, the feature it opened,
and the interaction that feature declares — with a citation behind it.

<img src="https://raw.githubusercontent.com/kihyun1998/flutter_example_template/main/docs/images/settings-panel.png" width="320" alt="The preset bar, feature list and detail pane stacked in a 320-wide column">

These are captures of a build made by [`tool/screenshots.sh`](./tool/screenshots.sh), which drives
the example in headless Chrome the way a reader drives it — pressing controls by their semantics
label and checking what is on screen before it captures, so a moved menu row fails the run instead
of producing a confidently wrong picture. Rerun it after anything that changes the
UI: a screenshot of something that has since moved is a citation that no longer says anything.

## The claim it holds itself to

**Nothing in this package names what it demonstrates.** That is not a style preference; it is the
property that makes the shell reusable at all, and it is enforced rather than intended.

Two test suites hold three things the compiler will not — all of which are legal Dart when violated:

- nothing under `lib/` imports anything outside `dart:` and `package:flutter/`;
- nothing outside `lib/src/` reaches into it (the suite stands in as the package's first consumer);
- the barrel and the tree name the same set of files, in both directions.

A third rule lives in the example, where there are real recipes for it to walk: **a file the Code
pane shows imports no shell.** That is what keeps "pasteable" true.

## Installing

In your **`example/pubspec.yaml`** — not your package's:

```yaml
dependencies:
  flutter_example_template: ^0.1.0
```

Or, to track `main` ahead of a release:

```yaml
dependencies:
  flutter_example_template:
    git:
      url: https://github.com/kihyun1998/flutter_example_template.git
```

`example/` is a separate package, so its dependencies never flow to anyone who depends on yours.
This costs your consumers nothing, and that is the point: your example takes the dependency, your
library does not.

## Using it

Everything you write is three ports.

### 1. What the menu points at

```dart
class MyDestinations implements ShellDestinations {
  final _settings = MySettingsNotifier();

  // A field, not a fresh list: the menu and the stage both walk this on the
  // same frame.
  late final List<ShellDestination> _all = [
    StageDestination(
      id: 'basic',
      label: 'Basic',
      category: ShellCategory.recipes,
      // Declared in pubspec assets; the Code pane reads it from the bundle.
      source: 'lib/recipes/basic.dart',
      stage: (context) => const BasicRecipe(),
      knobs: (context) => const SizedBox.shrink(),
    ),
    RouteDestination(
      id: 'about',
      label: 'About',
      category: ShellCategory.pages,
      open: (context) => const AboutPage(),
    ),
  ];

  @override
  List<ShellDestination> get all => _all;

  // The port carries the lifetime, not just the set. Whatever your
  // destinations hold is disposed here.
  @override
  void dispose() => _settings.dispose();
}
```

`source` is optional and null is the ordinary answer. Pass it only where the destination *is* one
self-contained file — offering a Code pane over something assembled from several would have to pick
one of them and call it the source.

### 2. The app

```dart
void main() => runApp(
  MaterialApp(
    theme: exampleTheme(Brightness.light),
    darkTheme: exampleTheme(Brightness.dark),
    home: ShellPage(
      // Deliberately not defaulted: a shell with a fallback title is one that
      // ships somebody else's product name when a caller forgets.
      title: 'My Package',
      createDestinations: MyDestinations.new,
    ),
  ),
);
```

### 3. A settings panel, if you want one

Implement `SettingsHost` over your own settings object. Five members, each read off a real call
site rather than designed:

```dart
class MyHost extends SettingsHost {
  MyHost(this.notifier);
  final MySettingsNotifier notifier;

  @override
  List<SettingGroup> get spec => mySpec;

  @override
  bool isOn(String switchId) => /* read a bool */;

  // A command, not a value. Handing back a new settings object would mean
  // knowing the type you were building.
  @override
  void setSwitch(String switchId, bool on) => /* write it */;

  @override
  SettingsControl control(String settingId) => buildSwitchTile(/* … */);
}
```

`presets`, `activePresetId`, `applyPreset` and the two extras hooks are optional and default to
empty. A capability nobody claims draws **no widget** — not an empty strip announcing a feature that
is not there.

Then hand the host to `PresetBar`, `FeatureListPane` and `FeatureDetailPane` and arrange them
however your knob region wants.

## The pieces, used on their own

`PreviewStage`, `PreviewFrame`, `DeviceWall`, `ViewportSpec`, `CodePane`, `MetricsPanel` and
`tokenizeDart` are all exported and none of them requires the shell. The tokenizer imports nothing
at all — not Flutter, not `dart:` — so it is a pure function you can test without pumping a widget.

## The example

[`example/`](./example) demonstrates an adaptive action bar — one that gives up label text, and then
whole actions, as room runs out. Deliberately **not** a table: this shell was extracted from a table
package's example app, and a gallery that could only be shown demonstrating its own origin would not
have proven anything.

```
example/lib/subject/     the package being demonstrated; imports no shell
example/lib/recipes/     pasteable, self-contained, bundled as assets
example/lib/gallery/     destinations, spec, host, panel — knows both sides
example/lib/main.dart    the one file that has to know this shell exists
```

## Why things are the way they are

[`docs/adr/`](./docs/adr) records the decisions, including the ones most likely to be re-proposed:
why there is no demo framework dependency, why the chrome font is a parameter rather than fetched or
bundled, why the Code pane has no line numbers, why this package is depended on rather than copied,
and why the SDK floor is 3.27.0 rather than the 3.22 the code alone would reach.

[`CONTEXT.md`](./CONTEXT.md) is the vocabulary. [`docs/agents/lessons.md`](./docs/agents/lessons.md)
is the working rules — the mistakes this codebase made and would make again.

## Status

`0.1.0`, and honest about it: one example, and two open questions in the issue tracker — whether
colour becomes a fourth port, and what happens to the bundled Dart tokenizer when it is extracted
into a package of its own.

**Requires Flutter 3.27.** Measured, not inherited: both suites pass and analyse clean on 3.27.0 and
on 3.41.9, and 3.24.5 fails on exactly one line — `pubspec.yaml` names that line, and says what
going lower would cost.

The comments are load-bearing. Measured 2026-09-06: 1,233 of 3,757 lines under `lib/` are
comment lines, a third of the file. They record measurements with dates, and two explanations that were
asserted, tested and **withdrawn** — cited in four files, because the retraction travels with
everything that had leaned on the claim. If a comment looks redundant, assume it is the residue of
something expensive before assuming it is noise.
