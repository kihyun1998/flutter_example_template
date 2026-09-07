import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_example_template/flutter_example_template.dart';
import 'package:flutter_test/flutter_test.dart';

// The chrome family is a parameter — ADR-0008 — and this file is what holds
// that to being true at every surface rather than at the one everybody checks.
//
// **It arrived here from a consumer, and the arrival is the point.** These three
// tests were written in the repository this package was extracted from, where
// the theme was a file under `lib/gallery/`. Two of them travelled: they read a
// built `ThemeData` and work from anywhere. The first one did not, and was
// deleted there rather than moved, because it reads the theme's *source* — and
// from a consumer that path is inside a resolved dependency, so the test would
// have been asserting where pub happened to put a file.
//
// What the deletion cost was the roster's own check, which is the only thing
// standing between the two tests below and a slow, silent decay: they walk a
// hand-written map, and a fifth styled surface added later is invisible to
// both. They would keep passing while the new leaf named a font nobody carries.
//
// So the guard belongs to whoever owns the source, and that is now this package.

void main() {
  group("the chrome font is the caller's", () {
    /// The leaf styles this theme writes itself, keyed by where it writes them.
    ///
    /// **Reading the typography alone is not enough.** A theme whose text theme
    /// defers to Flutter while a leaf still names a face reproduces exactly the
    /// failure this parameter exists to remove — a family with no files behind
    /// it, falling back without saying so. Same shape as the Code pane's
    /// monospace test, which passed while reading the wrapper `SelectableText`
    /// puts around a span tree and had to move down to a leaf.
    Map<String, String?> leafFamilies(ThemeData t) => {
          'appBarTheme.titleTextStyle':
              t.appBarTheme.titleTextStyle?.fontFamily,
          'listTileTheme.titleTextStyle':
              t.listTileTheme.titleTextStyle?.fontFamily,
          'listTileTheme.subtitleTextStyle':
              t.listTileTheme.subtitleTextStyle?.fontFamily,
          'segmentedButtonTheme.textStyle': t
              .segmentedButtonTheme.style?.textStyle
              ?.resolve(const <WidgetState>{})?.fontFamily,
        };

    /// Where `ThemeData(fontFamily:)` actually lands.
    ///
    /// Measured rather than assumed, and the measurement moved this test twice.
    /// `ThemeData` exposes no `fontFamily` getter at all — the argument is
    /// applied to `textTheme` and `primaryTextTheme` and is readable nowhere
    /// else. And with **no** family given, Flutter's own Material typography
    /// names `Roboto`, which it carries: the default is not null, and asserting
    /// null here would have been asserting a wrong model.
    String? typography(ThemeData t) => t.textTheme.bodyMedium?.fontFamily;

    /// What Flutter answers when nobody names a family. Derived rather than
    /// written down, so a framework that changes its default does not redden a
    /// test about this package.
    String? flutterDefault() =>
        ThemeData(useMaterial3: true).textTheme.bodyMedium?.fontFamily;

    test('every site the theme names a family at is watched', () {
      // The map above is a hand-written roster, and this is what keeps it from
      // going stale. Dart has no reflection, so the question is put to the
      // source — the same way `portable_seam_test.dart` puts its question about
      // imports.
      //
      // The `+ 1` is the top-level argument, which `leafFamilies` cannot see
      // because `ThemeData` does not expose it. Counting `fontFamily:` reaches
      // exactly the assignments: the doc-comment above the function discusses
      // the getter and writes no colon after it, so prose does not inflate the
      // count. A doc comment that starts to would fail this test, which is the
      // right way round — a roster check that silently absorbs new text is not
      // a roster check.
      final source = File(
        'lib/src/theme/example_theme.dart',
      ).readAsStringSync();
      final sites = RegExp(r'fontFamily:').allMatches(source).length;
      final watched = leafFamilies(exampleTheme(Brightness.light)).length;

      expect(
        sites,
        watched + 1,
        reason: 'example_theme.dart names a font family at $sites sites; this '
            'file watches $watched leaves plus the top level. A site that is '
            'not in the roster is a surface the two tests below cannot see.',
      );
    });

    test('names no family of its own by default', () {
      // This package carries no font, so by default it must add none. What is
      // left is Flutter's, which Flutter ships — correct with no assets, no
      // declaration and no network, in any consumer.
      for (final brightness in Brightness.values) {
        final named = leafFamilies(exampleTheme(brightness))
            .entries
            .where((e) => e.value != null)
            .map((e) => '${e.key} = ${e.value}');

        expect(
          named,
          isEmpty,
          reason: 'a leaf naming a family this package does not carry is the '
              'silent fallback the parameter removes; at $brightness: '
              '${named.join(', ')}',
        );

        expect(
          typography(exampleTheme(brightness)),
          flutterDefault(),
          reason: 'the typography must be left as Flutter set it',
        );
      }
    });

    test('names the family it is given, at every one of those sites', () {
      const face = 'Not A Real Face';

      for (final brightness in Brightness.values) {
        final theme = exampleTheme(brightness, chromeFont: face);
        final missed = leafFamilies(theme)
            .entries
            .where((e) => e.value != face)
            .map((e) => '${e.key} = ${e.value}');

        expect(
          missed,
          isEmpty,
          reason:
              "a caller's font must reach every styled surface, not only the "
              'typography; missed at $brightness: ${missed.join(', ')}',
        );
        expect(typography(theme), face);
      }
    });
  });
}
