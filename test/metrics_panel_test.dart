import 'package:flutter/material.dart';
import 'package:flutter_example_template/flutter_example_template.dart';
import 'package:flutter_test/flutter_test.dart';

// The metrics panel used to name its subject in its fields — a row count, a
// sort time, and thresholds of 1 000 / 10 000 / 50 000 written into the widget
// that drew them. Nothing in this package referenced any of it, so neither seam
// suite could see it: `portable_seam_test` reads imports, and this file's
// ancestor read only the settings port. The area passed both while being the
// least portable code in the tree.
//
// So the properties below are the ones that would go quietly. A reading whose
// value the panel formats is a panel that knows what is being counted; a normal
// reading wearing a hue is the achromatic chrome decision eroding one row at a
// time; a chip drawing bare numbers is a chip that says what something is worth
// and not what it is.

ColorScheme? _scheme;

Future<ColorScheme> _pump(WidgetTester tester, Widget child) async {
  await tester.pumpWidget(
    MaterialApp(
      home: Builder(
        builder: (context) {
          _scheme = Theme.of(context).colorScheme;
          return Scaffold(body: child);
        },
      ),
    ),
  );
  return _scheme!;
}

Metrics _at(DateTime when, List<Reading> readings) =>
    Metrics(readings: readings, lastUpdate: when);

void main() {
  group('the panel draws readings it cannot interpret', () {
    testWidgets('severity is the loudest reading, and normal when there are none', (
      tester,
    ) async {
      expect(_at(DateTime.now(), const []).severity, ReadingSeverity.normal);

      final mixed = _at(DateTime.now(), const [
        Reading(label: 'A', value: '1', severity: ReadingSeverity.notable),
        Reading(label: 'B', value: '2', severity: ReadingSeverity.critical),
        Reading(label: 'C', value: '3'),
      ]);
      expect(mixed.severity, ReadingSeverity.critical);

      // Order must not decide it. The loudest reading is the loudest wherever
      // the consumer happened to put it.
      final reversed = _at(
        DateTime.now(),
        mixed.readings.reversed.toList(),
      );
      expect(reversed.severity, ReadingSeverity.critical);
    });

    testWidgets('every reading is drawn, label and value, exactly as handed over', (
      tester,
    ) async {
      await _pump(
        tester,
        MetricsPanel(
          title: 'Readings',
          metrics: _at(DateTime.now(), const [
            Reading(label: 'Total Rows', value: '128.4K', subtitle: '40K/sec'),
            Reading(label: 'Last Sort', value: '1.28s'),
          ]),
        ),
      );

      expect(find.text('Readings'), findsOneWidget);
      // The value is drawn as given. A panel that reformatted `128.4K` would
      // have had to know it was a count.
      expect(find.text('128.4K'), findsOneWidget);
      expect(find.text('Total Rows'), findsOneWidget);
      expect(find.text('40K/sec'), findsOneWidget);
      expect(find.text('1.28s'), findsOneWidget);
      expect(find.textContaining('Last updated:'), findsOneWidget);
    });

    testWidgets('a normal reading stays achromatic; a critical one is the error colour', (
      tester,
    ) async {
      final scheme = await _pump(
        tester,
        MetricsPanel(
          metrics: _at(DateTime.now(), const [
            Reading(label: 'Quiet', value: '1'),
            Reading(
              label: 'Loud',
              value: '2',
              severity: ReadingSeverity.critical,
            ),
          ]),
        ),
      );

      // The chrome carries no hue so that the only colour on screen is the
      // subject's. Severity is the stated exemption — and an exemption that
      // spreads to the default is the rule gone.
      expect(tester.widget<Text>(find.text('Quiet')).style?.color, scheme.onSurface);
      expect(tester.widget<Text>(find.text('Loud')).style?.color, scheme.error);
      expect(tester.widget<Text>(find.text('1')).style?.color, scheme.onSurface);
    });

    testWidgets('an icon is optional, and its absence costs no layout', (
      tester,
    ) async {
      await _pump(
        tester,
        MetricsPanel(
          metrics: _at(DateTime.now(), const [
            Reading(label: 'Bare', value: '1'),
            Reading(label: 'Iconed', value: '2', icon: Icons.memory),
          ]),
        ),
      );

      expect(find.text('Bare'), findsOneWidget);
      // Not `Icons.speed`: the panel wears that one itself, in its header.
      expect(find.byIcon(Icons.memory), findsOneWidget);
    });
  });

  group('the chip', () {
    testWidgets('names every reading in its tooltip, because a bare value does not', (
      tester,
    ) async {
      await _pump(
        tester,
        MetricsChip(
          metrics: _at(DateTime.now(), const [
            Reading(label: 'Total Rows', value: '128.4K'),
            Reading(label: 'Last Sort', value: '1.28s'),
          ]),
        ),
      );

      final tooltip = tester.widget<Tooltip>(find.byType(Tooltip));
      expect(tooltip.message, 'Total Rows: 128.4K\nLast Sort: 1.28s');
    });

    testWidgets('status colour is ink, never ground', (tester) async {
      // The filled form is what this was, and it carried the panel's own bug in
      // miniature: a ground chosen for one brightness. Asserted here because a
      // future edit reaching for `color: _ink(...)` on the decoration would
      // look tidier and would be the regression.
      final scheme = await _pump(
        tester,
        MetricsChip(
          metrics: _at(DateTime.now(), const [
            Reading(
              label: 'Loud',
              value: '2',
              severity: ReadingSeverity.critical,
            ),
          ]),
        ),
      );

      final box = tester.widget<Container>(
        find.descendant(
          of: find.byType(MetricsChip),
          matching: find.byType(Container),
        ),
      );
      final decoration = box.decoration! as BoxDecoration;
      expect(decoration.color, scheme.surfaceContainerHighest);
      expect(decoration.color, isNot(scheme.error));
      expect(tester.widget<Text>(find.text('2')).style?.color, scheme.error);
    });
  });
}
