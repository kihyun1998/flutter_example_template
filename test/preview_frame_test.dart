import 'package:flutter/material.dart';
import 'package:flutter_example_template/flutter_example_template.dart';
import 'package:flutter_test/flutter_test.dart';

void _surface(WidgetTester t, Size size) {
  t.view.physicalSize = size;
  t.view.devicePixelRatio = 1.0;
  addTearDown(t.view.reset);
}

/// The stage's rect on screen: its viewport size times the frame's factor.
Size _renderedStageSize(WidgetTester t) =>
    t.getRect(find.byType(PreviewStage)).size;

Future<void> _pumpFrame(
  WidgetTester t, {
  required ViewportSpec spec,
  required bool fit,
  required Size surface,
  Widget? child,
}) async {
  _surface(t, surface);
  await t.pumpWidget(
    MaterialApp(
      home: Scaffold(
        body: PreviewFrame(
          spec: spec,
          fit: fit,
          child: child ?? const SizedBox.expand(),
        ),
      ),
    ),
  );
  await t.pumpAndSettle();
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
  group('fitting', () {
    testWidgets('shrinks a viewport wider than the room it has', (t) async {
      await _pumpFrame(
        t,
        spec: ViewportSpec.desktop,
        fit: true,
        surface: const Size(800, 700),
      );

      final rendered = _renderedStageSize(t);
      expect(rendered.width, lessThan(ViewportSpec.desktop.width));
      expect(rendered.width, lessThanOrEqualTo(800));
      expect(
        rendered.width / rendered.height,
        closeTo(ViewportSpec.desktop.width / ViewportSpec.desktop.height, 0.01),
      );
    });

    testWidgets('leaves a viewport that already fits alone', (t) async {
      await _pumpFrame(
        t,
        spec: ViewportSpec.mobile,
        fit: true,
        surface: const Size(1400, 1200),
      );

      expect(_renderedStageSize(t), ViewportSpec.mobile.size);
    });

    testWidgets('says which factor it used', (t) async {
      await _pumpFrame(
        t,
        spec: ViewportSpec.desktop,
        fit: true,
        surface: const Size(800, 700),
      );

      expect(find.textContaining('1440 × 900 · 0.'), findsOneWidget);
      expect(find.textContaining('1:1'), findsNothing);
    });

    testWidgets('1:1 keeps real pixels and does not shrink', (t) async {
      await _pumpFrame(
        t,
        spec: ViewportSpec.desktop,
        fit: false,
        surface: const Size(800, 700),
      );

      expect(_renderedStageSize(t), ViewportSpec.desktop.size);
      expect(find.text('1440 × 900 · 1:1'), findsOneWidget);
    });
  });

  group('interaction survives the scale', () {
    testWidgets('a tap inside a shrunken frame reaches the row it landed on', (
      t,
    ) async {
      final tapped = <int>[];
      await _pumpFrame(
        t,
        spec: ViewportSpec.desktop,
        fit: true,
        surface: const Size(800, 700),
        child: Column(
          children: [
            for (var i = 0; i < 10; i++)
              GestureDetector(
                onTap: () => tapped.add(i),
                child: SizedBox(
                  height: 40,
                  width: double.infinity,
                  child: ColoredBox(
                    color: const Color(0xFFEEEEEE),
                    child: Text('row $i'),
                  ),
                ),
              ),
          ],
        ),
      );
      expect(_renderedStageSize(t).width, lessThan(800));

      for (final row in [0, 3, 9]) {
        await t.tapAt(t.getCenter(find.text('row $row')));
      }

      expect(tapped, [0, 3, 9]);
    });

    testWidgets("a pointer arrives in the child's own unscaled frame", (
      t,
    ) async {
      Offset? local;
      await _pumpFrame(
        t,
        spec: ViewportSpec.desktop,
        fit: true,
        surface: const Size(800, 700),
        child: Align(
          alignment: Alignment.topLeft,
          child: Listener(
            onPointerDown: (e) => local = e.localPosition,
            child: const SizedBox(
              key: ValueKey('target'),
              width: 400,
              height: 200,
              child: ColoredBox(color: Color(0xFF888888)),
            ),
          ),
        ),
      );
      final target = t.getRect(find.byKey(const ValueKey('target')));
      expect(target.width, lessThan(390), reason: 'the frame did not shrink');

      await t.tapAt(target.center);

      expect(local!.dx, closeTo(200, 0.5));
      expect(local!.dy, closeTo(100, 0.5));
    });
  });

  group('an overlay belongs to the viewport it opens in', () {
    testWidgets('a drag feedback is drawn at the scale of its own frame', (
      t,
    ) async {
      await _pumpFrame(
        t,
        spec: ViewportSpec.desktop,
        fit: true,
        surface: const Size(700, 500),
        child: Center(child: _draggable()),
      );

      final source = t.getRect(find.byKey(const ValueKey('source')));
      expect(source.width, lessThan(190), reason: 'the frame did not shrink');

      final gesture = await t.startGesture(source.center);
      for (var i = 0; i < 5; i++) {
        await gesture.moveBy(const Offset(12, 0));
        await t.pump();
      }

      final feedback = t.getRect(find.byKey(const ValueKey('feedback')));
      expect(feedback.width, closeTo(source.width, 0.5));
      expect(feedback.height, closeTo(source.height, 0.5));

      await gesture.up();
      await t.pumpAndSettle();
    });
  });
}
