import 'dart:io';

import 'package:example/gallery/destinations.dart';
import 'package:flutter_example_template/flutter_example_template.dart';
import 'package:flutter_test/flutter_test.dart';

// The fourth seam rule, and the one that could not be written in the shell's
// own repository.
//
// `docs/adr/0002-depended-on-not-copied.md` settles that a consumer depends on
// the shell rather than copying it, and the boundary that makes that safe is
// **the pasteable unit never imports the shell**. A recipe is handed to a
// destination as a builder and knows nothing of its host; one file in this
// example knows the shell exists, and it is not one of the files the Code pane
// shows.
//
// That is legal Dart when violated, like the three rules in the shell's own
// seam suite. A recipe could import the shell, compile, run, and look right in
// the pane — and the first person to paste it into their own app would find out.
//
// The shell could not hold this rule itself: with no destinations in that
// repository it would walk nothing and pass, which is the shape its own
// "lib is not empty" case guards against. Here there are destinations, so here
// it walks.

const _shellPackage = 'package:flutter_example_template/';

List<String> _importsOf(File file) => RegExp(
  r"^import\s+'([^']+)'",
  multiLine: true,
).allMatches(file.readAsStringSync()).map((m) => m.group(1)!).toList();

/// The asset paths this app declares, read from the pubspec rather than listed
/// here. A second roster kept in step by hand is the shape that goes stale.
Set<String> _declaredAssets() {
  final lines = File('pubspec.yaml').readAsLinesSync();
  final assets = <String>{};
  var inAssets = false;
  for (final line in lines) {
    if (RegExp(r'^\s{2}assets:\s*$').hasMatch(line)) {
      inAssets = true;
      continue;
    }
    if (!inAssets) continue;
    final entry = RegExp(r'^\s+-\s+(\S+)\s*$').firstMatch(line);
    if (entry == null) break;
    assets.add(entry.group(1)!);
  }
  return assets;
}

void main() {
  late ActionBarDestinations destinations;
  late List<StageDestination> withSource;

  setUp(() {
    destinations = ActionBarDestinations();
    withSource = destinations.all
        .whereType<StageDestination>()
        .where((d) => d.source != null)
        .toList();
  });

  tearDown(() => destinations.dispose());

  group('a pasteable file names no shell', () {
    test('there is something to check, and the rule is not walking nothing', () {
      // The rules below are filters over whatever `withSource` holds, so an
      // empty list would report no offences and pass. Nothing else here can
      // tell "clean" from "not looked at".
      expect(
        withSource,
        isNotEmpty,
        reason: 'No destination declares a source, so the rules below assert '
            'nothing. Either the recipes lost their sources or this suite is '
            'guarding an empty tree.',
      );
    });

    test('every source a destination points at exists and is bundled', () {
      for (final destination in withSource) {
        final path = destination.source!;
        expect(
          File(path).existsSync(),
          isTrue,
          reason: '${destination.id} points at $path, which is not on disk.',
        );
        expect(
          _declaredAssets(),
          contains(path),
          reason: '${destination.id} points at $path, which pubspec.yaml does '
              'not declare as an asset. It resolves in the tree and fails in '
              'the bundle, which is a failure only a running app reports.',
        );
      }
    });

    test('no file the Code pane shows imports the shell', () {
      final offences = <String>[];

      for (final destination in withSource) {
        final file = File(destination.source!);
        for (final import in _importsOf(file)) {
          if (import.startsWith(_shellPackage)) {
            offences.add('${file.path}: $import');
          }
        }
      }

      expect(
        offences,
        isEmpty,
        reason: 'A recipe that imports the shell is not pasteable, and the '
            'Code pane offers it as though it were.\nEach line below breaks '
            'that:\n  ${offences.join('\n  ')}',
      );
    });

    test('every import line is actually read', () {
      // The rule above filters whatever `_importsOf` returns, so a regex that
      // matched nothing would report no offences and pass. The single-quote
      // form is what `dart format` produces; this asserts that assumption
      // rather than inheriting it.
      for (final destination in withSource) {
        final file = File(destination.source!);
        final lines = file
            .readAsLinesSync()
            .where((l) => l.startsWith('import '))
            .length;
        expect(
          _importsOf(file),
          hasLength(lines),
          reason: '${file.path} has $lines import lines but the rule parsed '
              '${_importsOf(file).length} of them — the unparsed ones are '
              'exempt without saying so.',
        );
      }
    });

    test('every bundled recipe is reachable from a destination', () {
      // The other direction. A recipe bundled but pointed at by nothing is
      // dead weight the pane can never show, and the omission is invisible.
      final pointedAt = withSource.map((d) => d.source!).toSet();
      final bundled = _declaredAssets()
          .where((a) => a.startsWith('lib/recipes/'))
          .toSet();

      expect(
        bundled.difference(pointedAt),
        isEmpty,
        reason: 'Bundled but pointed at by no destination.',
      );
    });
  });
}
