import 'package:flutter/material.dart';
import 'package:flutter_example_template/flutter_example_template.dart';
import 'package:flutter_test/flutter_test.dart';

void _surface(WidgetTester t, Size size) {
  t.view.physicalSize = size;
  t.view.devicePixelRatio = 1.0;
  addTearDown(t.view.reset);
}

Future<void> _pump(WidgetTester t, Widget child, Size surface) async {
  _surface(t, surface);
  await t.pumpWidget(MaterialApp(home: Scaffold(body: child)));
  await t.pumpAndSettle();
}

/// A stage that shows the size it was told, filling the size it was given.
class _Probe extends StatelessWidget {
  const _Probe({this.onTap, this.text});

  final void Function(double toldWidth)? onTap;
  final String? text;

  @override
  Widget build(BuildContext context) {
    final told = MediaQuery.sizeOf(context);
    return GestureDetector(
      onTap: onTap == null ? null : () => onTap!(told.width),
      child: ColoredBox(
        color: const Color(0xFFEEEEEE),
        child: SizedBox.expand(
          child: Text(text ?? 'told ${told.width.toInt()}'),
        ),
      ),
    );
  }
}

void main() {
  group('every viewport at once', () {
    testWidgets('draws each one, saying which size and at what factor', (
      t,
    ) async {
      await _pump(
        t,
        DeviceWall(stage: (context) => const _Probe()),
        const Size(1600, 900),
      );

      for (final spec in ViewportSpec.values) {
        expect(
          find.textContaining('${spec.width.toInt()} × ${spec.height.toInt()}'),
          findsOneWidget,
          reason: '${spec.id} is not on the wall',
        );
      }
      expect(find.textContaining('1440 × 900 · 1:1'), findsNothing);
      expect(find.textContaining('390 × 844 · 1:1'), findsOneWidget);
    });

    testWidgets('each frame lays out and tells its own viewport', (t) async {
      await _pump(
        t,
        DeviceWall(stage: (context) => const _Probe()),
        const Size(1600, 900),
      );

      final probes = find.byType(_Probe);
      expect(probes, findsNWidgets(3));
      for (var i = 0; i < ViewportSpec.values.length; i++) {
        final spec = ViewportSpec.values[i];
        expect(t.getSize(probes.at(i)), spec.size);
        expect(find.text('told ${spec.width.toInt()}'), findsOneWidget);
      }
      expect(t.getRect(probes.first).width, lessThan(1440));
    });

    testWidgets('one knob change reaches all three', (t) async {
      var count = 0;
      _surface(t, const Size(1600, 900));
      await t.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: StatefulBuilder(
              builder: (context, setState) => Column(
                children: [
                  TextButton(
                    onPressed: () => setState(() => count++),
                    child: const Text('more'),
                  ),
                  Expanded(
                    child: DeviceWall(
                      stage: (context) => _Probe(text: 'count $count'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
      await t.pumpAndSettle();
      expect(find.text('count 0'), findsNWidgets(3));

      await t.tap(find.text('more'));
      await t.pumpAndSettle();

      expect(find.text('count 1'), findsNWidgets(3));
      expect(find.text('count 0'), findsNothing);
    });

    testWidgets('no caption is wider than the column it sits in', (t) async {
      await _pump(
        t,
        DeviceWall(stage: (context) => const _Probe()),
        const Size(620, 900),
      );

      final column = t.getSize(find.byType(PreviewFrame).first).width;
      final label = t.getSize(find.textContaining('1440 × 900').first).width;

      expect(label, lessThanOrEqualTo(column));
    });
  });

  group('every frame is live', () {
    testWidgets('a tap in each frame reaches the subject in that frame', (
      t,
    ) async {
      final tapped = <double>[];
      await _pump(
        t,
        DeviceWall(stage: (context) => _Probe(onTap: tapped.add)),
        const Size(1600, 900),
      );

      final probes = find.byType(_Probe);
      for (var i = 0; i < 3; i++) {
        await t.tapAt(t.getCenter(probes.at(i)));
      }

      expect(tapped, [1440, 834, 390]);
    });

    testWidgets('and the other two frames show what it did', (t) async {
      var count = 0;
      _surface(t, const Size(1600, 900));
      await t.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: StatefulBuilder(
              builder: (context, setState) => DeviceWall(
                stage: (context) => _Probe(
                  text: 'count $count',
                  onTap: (_) => setState(() => count++),
                ),
              ),
            ),
          ),
        ),
      );
      await t.pumpAndSettle();

      await t.tapAt(t.getCenter(find.byType(_Probe).last));
      await t.pumpAndSettle();

      expect(find.text('count 1'), findsNWidgets(3));
    });
  });
}
