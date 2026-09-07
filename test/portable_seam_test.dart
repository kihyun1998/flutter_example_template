import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

// This package is chrome that demonstrates *another* package without knowing
// which one: a menu, a destination model, a viewport frame, a device wall, a
// Code pane, a settings panel. Nothing in `lib/` may name a subject, and
// nothing outside `lib/src/` may be reached from outside this package at all.
//
// **Both rules are legal Dart.** A file here could import anything its pubspec
// allows and compile; a consumer could import `lib/src/...` directly and
// compile. The first would tie this package to one subject, the second would
// break the day `src/` is treated as private — and neither produces an error, a
// failing test or a warning in between. A property that is true because nobody
// happened to violate it is not a property.
//
// This was measured before it was written down. In the repository these files
// came from, one half of this code was already clean and the other imported
// eleven recipes, two scenarios and a playground page — and **neither fact was
// visible from anywhere**, because both halves compiled.
//
// The rules are deliberately **not** hand-written lists of allowed spellings.
// `'viewport_spec.dart'`, `'../preview/device_wall.dart'` and
// `'package:flutter_example_template/flutter_example_template.dart'` are three
// spellings of the same question — does this import leave the zone — and
// enumerating the forms is a roster that goes stale. Every import is resolved to
// a path under `lib/` and the answer follows from where it lands.
//
// Dart has no reflection, so questions about imports are put to the source.

/// The zone's public entry point, relative to `lib/`.
///
/// Everything else under `lib/` is private to this package by convention and by
/// this file, and by nothing else: `src/` is a naming agreement in Dart, not
/// something the compiler enforces.
const _barrel = 'flutter_example_template.dart';

/// Where the implementation lives.
const _zoneInternals = 'src/';

/// Import prefixes that leave this package and are therefore always fine.
///
/// Flutter is the floor this is written against; `dart:` is the language.
/// **Everything else is what this test exists to catch** — most of all the
/// subject, which is the one dependency that would make this gallery about one.
///
/// The third entry is the list growing the way it was always described as
/// growing: one dependency, genuinely needed, on purpose.
/// `flutter_syntax_highlight` is the tokenizer that used to sit under `src/` as
/// a copy, and ADR-0012 records what taking it cost against what the copy was
/// costing instead.
const _allowedExternal = [
  'dart:',
  'package:flutter/',
  'package:flutter_syntax_highlight/',
];

List<File> _dartFilesUnder(String dir) =>
    Directory('lib/$dir')
        .listSync(recursive: true)
        .whereType<File>()
        .where((f) => f.path.endsWith('.dart'))
        .toList();

List<File> _allDartFiles() =>
    Directory('lib')
        .listSync(recursive: true)
        .whereType<File>()
        .where((f) => f.path.endsWith('.dart'))
        .toList();

/// A file's path relative to `lib/`, spelled the way an import spells it.
///
/// `listSync` reports what the platform reports, and on Windows that is
/// `lib/src\shell\shell_page.dart` — the separator this file joined with and
/// the one the OS returned, in one string. Every string a path is compared
/// *against* here is Dart source: an `export 'src/…'` line, an import URI.
/// Those are `/` on every platform, because they are not filesystem entries.
///
/// Comparing the two directly made every file under `lib/src/` look missing
/// from the barrel — on Windows only, in the test whose whole job is to notice
/// a missing file. `File.uri` is the conversion the SDK already owns.
String _libRelative(File file) => file.uri.path.substring('lib/'.length);

List<String> _importsOf(File file) => RegExp(
  r"^import\s+'([^']+)'",
  multiLine: true,
).allMatches(file.readAsStringSync()).map((m) => m.group(1)!).toList();

/// Where an import lands, expressed as a path under `lib/`, or null when it
/// leaves the repository entirely.
///
/// The spellings collapse here: an absolute self-import and a relative one both
/// resolve to the same path under `lib/`, which is what makes these rules
/// questions about location rather than about how somebody chose to write the
/// import.
const _selfPrefix = 'package:flutter_example_template/';

String? _resolveWithinLib(String import, File from) {
  if (import.startsWith(_selfPrefix)) {
    return import.substring(_selfPrefix.length);
  }
  if (import.startsWith('package:') || import.startsWith('dart:')) return null;

  // Relative: resolve against the importing file's own directory, then express
  // the result relative to `lib/`.
  //
  // The file is made **absolute** first. A relative `from.path` resolves to a
  // relative target with no leading separator, and the `/lib/` needle below then
  // matches nothing — which reports every same-directory import as leaving the
  // package. That was the first result this test produced, and it was red for a
  // reason that had nothing to do with the property being asserted.
  final fromDir = from.absolute.uri.resolve('.');
  final target = fromDir.resolve(import).path;
  final libIndex = target.indexOf('/lib/');
  return libIndex < 0 ? null : target.substring(libIndex + '/lib/'.length);
}

void main() {
  group('this package names no subject', () {
    test('no file in lib imports anything outside this package', () {
      final offences = <String>[];

      for (final file in _allDartFiles()) {
        for (final import in _importsOf(file)) {
          if (_allowedExternal.any(import.startsWith)) continue;
          if (_resolveWithinLib(import, file) == null) {
            offences.add('${file.path}: $import');
          }
        }
      }

      expect(
        offences,
        isEmpty,
        reason:
            'A gallery that names a package is a gallery about that '
            'package.\nEach line below ties this one to a subject:\n'
            '  ${offences.join('\n  ')}',
      );
    });

    test('the tests go through the barrel, like any other consumer', () {
      // The half the compiler will never object to. `package:…/src/x.dart`
      // resolves perfectly well and is exactly what stops resolving the day
      // `src/` is treated as private — by a lint, by a consumer's own rule, or
      // by anyone who reads the convention and believes it.
      //
      // There is no application in this repository to hold to that, so the
      // suite stands in: **a test is this package's first consumer**, and one
      // that reaches past the barrel is the first one to prove the barrel is
      // optional.
      final offences = <String>[];

      for (final file
          in Directory('test')
              .listSync(recursive: true)
              .whereType<File>()
              .where((f) => f.path.endsWith('.dart'))) {
        for (final import in _importsOf(file)) {
          if (!import.startsWith(_selfPrefix)) continue;
          final landing = import.substring(_selfPrefix.length);
          if (landing.startsWith(_zoneInternals)) {
            offences.add('${file.path}: $import');
          }
        }
      }

      expect(
        offences,
        isEmpty,
        reason:
            'Only lib/$_barrel may be imported from outside lib/src.\n'
            'These reach into the internals instead:\n'
            '  ${offences.join('\n  ')}',
      );
    });

    test('the barrel and the tree name the same set of files', () {
      // A file the barrel forgets is still reachable through its `src/` path
      // inside this repository, so the omission is invisible here and total for
      // a consumer. Checked against the tree rather than a list kept by hand,
      // in both directions.
      final exported = RegExp(r"^export '([^']+)'", multiLine: true)
          .allMatches(File('lib/$_barrel').readAsStringSync())
          .toSet()
          .map((m) => m.group(1)!)
          .toSet();

      final present = _dartFilesUnder(_zoneInternals.replaceAll('/', ''))
          .map(_libRelative)
          .toSet();

      expect(
        present.difference(exported),
        isEmpty,
        reason: 'In lib/src but not exported — invisible to every consumer.',
      );
      expect(
        exported.difference(present),
        isEmpty,
        reason: 'Exported by the barrel but not present in lib/src.',
      );
    });

    test('every import line is actually read', () {
      // The rules above are filters over whatever `_importsOf` returns, so a
      // regex that matched nothing would report no offences and pass. Nothing
      // else here can tell "clean" from "not looked at".
      //
      // The single-quote form is what `dart format` produces; this asserts that
      // assumption rather than inheriting it, so a file written with double
      // quotes, or a conditional import, fails here instead of disappearing
      // from the rules.
      for (final file in _allDartFiles()) {
        final lines = file
            .readAsLinesSync()
            .where((l) => l.startsWith('import '))
            .length;
        expect(
          _importsOf(file),
          hasLength(lines),
          reason:
              '${file.path} has $lines import lines but the rules parsed '
              '${_importsOf(file).length} of them — the unparsed ones are '
              'exempt without saying so.',
        );
      }
    });

    test('lib is not empty, and neither is any area in it', () {
      // A rule that walks nothing passes. This is what would catch a rename
      // that emptied the tree and turned every rule above green by removing its
      // subject.
      //
      // The areas are read from the tree rather than listed here. A list would
      // be a second roster to keep in step, and it went stale the first time an
      // area was added in the repository this came from: the test named three
      // while the tree held five.
      expect(_allDartFiles(), isNotEmpty, reason: 'lib is empty.');

      final areas = Directory('lib/$_zoneInternals')
          .listSync()
          .whereType<Directory>()
          .toList();
      expect(areas, isNotEmpty, reason: 'lib/$_zoneInternals has no areas.');

      for (final area in areas) {
        expect(
          area
              .listSync(recursive: true)
              .whereType<File>()
              .where((f) => f.path.endsWith('.dart')),
          isNotEmpty,
          reason:
              '${area.path} is an area but holds no Dart files — a move '
              'left it behind.',
        );
      }
    });
  });
}
