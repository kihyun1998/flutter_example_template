import 'package:flutter/material.dart';
import 'package:flutter_example_template/flutter_example_template.dart';
import 'package:flutter_test/flutter_test.dart';

void _surface(WidgetTester t, [Size size = const Size(1600, 1200)]) {
  t.view.physicalSize = size;
  t.view.devicePixelRatio = 1.0;
  addTearDown(t.view.reset);
}

/// A box that can start a drag, and the box the drag draws.
Widget _draggable() => const Draggable<int>(
  data: 1,
  feedback: SizedBox(
    key: ValueKey('feedback'),
    width: 200,
    height: 100,
    child: ColoredBox(color: Color(0xFF000000)),
  ),
  child: SizedBox(
    key: ValueKey('source'),
    width: 200,
    height: 100,
    child: ColoredBox(color: Color(0xFF888888)),
  ),
);

void main() {
  group('ViewportSpec', () {
    test('the named viewports carry the sizes their labels claim', () {
      expect(ViewportSpec.desktop.size, const Size(1440, 900));
      expect(ViewportSpec.tablet.size, const Size(834, 1112));
      expect(ViewportSpec.mobile.size, const Size(390, 844));

      for (final v in ViewportSpec.values) {
        expect(v.label, contains('${v.size.width.toInt()}'));
        expect(v.label, contains('${v.size.height.toInt()}'));
      }
    });

    test('chrome is kept at the two wide viewports and dropped at the phone', () {
      expect(ViewportSpec.desktop.showsChrome, isTrue);
      expect(ViewportSpec.tablet.showsChrome, isTrue);
      expect(ViewportSpec.mobile.showsChrome, isFalse);
    });

    test('byId round-trips every value and refuses an unknown one', () {
      for (final v in ViewportSpec.values) {
        expect(ViewportSpec.byId(v.id), v);
      }
      expect(() => ViewportSpec.byId('watch'), throwsArgumentError);
    });
  });

  group('PreviewStage', () {
    testWidgets('lays the child out at the size and reports that size', (
      t,
    ) async {
      _surface(t);
      late Size reported;
      final probe = Builder(
        builder: (context) {
          reported = MediaQuery.sizeOf(context);
          return const SizedBox.expand();
        },
      );

      await t.pumpWidget(
        MaterialApp(
          home: Center(
            child: PreviewStage(spec: ViewportSpec.mobile, child: probe),
          ),
        ),
      );

      expect(t.getSize(find.byWidget(probe)), const Size(390, 844));
      expect(reported, const Size(390, 844));
    });

    testWidgets("reports no insets rather than inheriting the host's", (
      t,
    ) async {
      _surface(t);
      late MediaQueryData seen;
      final probe = Builder(
        builder: (context) {
          seen = MediaQuery.of(context);
          return const SizedBox.expand();
        },
      );

      await t.pumpWidget(
        MaterialApp(
          home: MediaQuery(
            data: const MediaQueryData(
              size: Size(1600, 1200),
              padding: EdgeInsets.only(top: 44, bottom: 34),
              viewInsets: EdgeInsets.only(bottom: 300),
              viewPadding: EdgeInsets.only(top: 44, bottom: 34),
            ),
            child: Center(
              child: PreviewStage(spec: ViewportSpec.mobile, child: probe),
            ),
          ),
        ),
      );

      expect(seen.padding, EdgeInsets.zero);
      expect(seen.viewInsets, EdgeInsets.zero);
      expect(seen.viewPadding, EdgeInsets.zero);
    });

    testWidgets('carries the rest of the host data through', (t) async {
      _surface(t);
      late MediaQueryData seen;
      final probe = Builder(
        builder: (context) {
          seen = MediaQuery.of(context);
          return const SizedBox.expand();
        },
      );

      await t.pumpWidget(
        MaterialApp(
          home: MediaQuery(
            data: const MediaQueryData(
              size: Size(1600, 1200),
              textScaler: TextScaler.linear(1.3),
              platformBrightness: Brightness.dark,
            ),
            child: Center(
              child: PreviewStage(spec: ViewportSpec.mobile, child: probe),
            ),
          ),
        ),
      );

      expect(seen.textScaler, const TextScaler.linear(1.3));
      expect(seen.platformBrightness, Brightness.dark);
    });

    testWidgets('owns the overlay a drag out of it lands in', (t) async {
      _surface(t);
      await t.pumpWidget(
        MaterialApp(
          home: Center(
            child: PreviewStage(
              spec: ViewportSpec.mobile,
              child: Center(child: _draggable()),
            ),
          ),
        ),
      );

      final source = t.getRect(find.byKey(const ValueKey('source')));
      final gesture = await t.startGesture(source.center);
      for (var i = 0; i < 5; i++) {
        await gesture.moveBy(const Offset(12, 0));
        await t.pump();
      }

      expect(
        find.descendant(
          of: find.byType(PreviewStage),
          matching: find.byKey(const ValueKey('feedback')),
        ),
        findsOneWidget,
      );

      await gesture.up();
      await t.pumpAndSettle();
    });

    testWidgets('shows the child it is given now, not the first one', (
      t,
    ) async {
      _surface(t);
      Widget stage(String text) => MaterialApp(
        home: Center(
          child: PreviewStage(spec: ViewportSpec.mobile, child: Text(text)),
        ),
      );

      await t.pumpWidget(stage('first'));
      await t.pumpWidget(stage('second'));

      expect(find.text('second'), findsOneWidget);
      expect(find.text('first'), findsNothing);
    });
  });
}
