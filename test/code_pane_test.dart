import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_example_template/flutter_example_template.dart';

class _Bundle extends CachingAssetBundle {
  _Bundle(this._files);

  final Map<String, String> _files;

  @override
  Future<ByteData> load(String key) async {
    final text = _files[key];
    if (text == null) throw FlutterError('no asset for $key');
    return ByteData.sublistView(Uint8List.fromList(utf8.encode(text)));
  }
}

/// The pane's scroll position on [axis].
ScrollPosition _position(WidgetTester tester, Axis axis) => tester
    .stateList<ScrollableState>(find.byType(Scrollable))
    .firstWhere((s) => axisDirectionToAxis(s.axisDirection) == axis)
    .position;

/// One mouse wheel notch of [delta] over the pane.
Future<void> _wheel(WidgetTester tester, Offset delta) async {
  tester.binding.handlePointerEvent(
    PointerScrollEvent(
      kind: PointerDeviceKind.mouse,
      position: tester.getCenter(find.byType(Scrollbar)),
      scrollDelta: delta,
    ),
  );
  await tester.pump();
}

void main() {
  const path = 'lib/recipes/basic_action_bar.dart';
  const source =
      "import 'package:flutter/material.dart';\n"
      '\n'
      'class BasicActionBar extends StatelessWidget {\n'
      "  static const label = 'x \${1 + 1} y';\n"
      '}\n';

  testWidgets('the pane draws the bytes it was handed', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: CodePane(assetPath: path, bundle: _Bundle({path: source})),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.textContaining(path), findsWidgets, reason: 'the path bar');
    expect(
      find.textContaining('BasicActionBar'),
      findsWidgets,
      reason: 'the source itself, which is the whole point of the pane',
    );
  });

  testWidgets('an unreadable asset says so rather than drawing nothing', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: CodePane(assetPath: path, bundle: _Bundle(const {})),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.textContaining('Could not read'), findsOneWidget);
  });

  group('a mouse wheel', () {
    // Taller and wider than the default 800x600 surface, and under 50 KB.
    final long = [
      for (var i = 0; i < 120; i++) '// line $i ${'x' * 200}',
    ].join('\n');

    Future<void> pumpLong(WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CodePane(assetPath: path, bundle: _Bundle({path: long})),
          ),
        ),
      );
      await tester.pumpAndSettle();
    }

    testWidgets('glides down to its target rather than jumping', (
      tester,
    ) async {
      await pumpLong(tester);
      final position = _position(tester, Axis.vertical);

      await _wheel(tester, const Offset(0, 60));
      await tester.pump(const Duration(milliseconds: 16));
      expect(position.pixels, greaterThan(0));
      expect(position.pixels, lessThan(60));

      await tester.pumpAndSettle();
      expect(position.pixels, 60);
    });

    testWidgets('held with Shift, glides sideways along a long line', (
      tester,
    ) async {
      await pumpLong(tester);
      final position = _position(tester, Axis.horizontal);

      await tester.sendKeyDownEvent(LogicalKeyboardKey.shiftLeft);
      try {
        await _wheel(tester, const Offset(0, 60));
        await tester.pump(const Duration(milliseconds: 16));
        expect(position.pixels, greaterThan(0));
        expect(position.pixels, lessThan(60));

        await tester.pumpAndSettle();
        expect(position.pixels, 60);
        expect(_position(tester, Axis.vertical).pixels, 0);
      } finally {
        await tester.sendKeyUpEvent(LogicalKeyboardKey.shiftLeft);
      }
    });

    testWidgets('glides when turned over the scrollbar track, too', (
      tester,
    ) async {
      debugDefaultTargetPlatformOverride = TargetPlatform.windows;
      try {
        await pumpLong(tester);
        final position = _position(tester, Axis.vertical);
        final box = tester.getRect(find.byType(Scrollbar).first);
        final track = Offset(box.right - 3, box.center.dy);
        final view = tester.renderObject(
          find.byWidgetPredicate(
            (w) =>
                w is SingleChildScrollView &&
                w.scrollDirection == Axis.vertical,
          ),
        );

        final pointer = TestPointer(1, PointerDeviceKind.mouse);
        await tester.sendEventToBinding(pointer.hover(track));
        await tester.pumpAndSettle();
        expect(
          tester
              .hitTestOnBinding(track)
              .path
              .any((entry) => identical(entry.target, view)),
          isFalse,
          reason: 'the view takes the wheel here, so the track is not reached',
        );

        tester.binding.handlePointerEvent(
          PointerScrollEvent(
            kind: PointerDeviceKind.mouse,
            position: track,
            scrollDelta: const Offset(0, 60),
          ),
        );
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 16));
        expect(position.pixels, greaterThan(0));
        expect(position.pixels, lessThan(60));

        await tester.pumpAndSettle();
        expect(position.pixels, 60);
      } finally {
        debugDefaultTargetPlatformOverride = null;
      }
    });

    testWidgets('leaves a drag to follow the finger directly', (tester) async {
      await pumpLong(tester);
      final position = _position(tester, Axis.vertical);

      final gesture = await tester.startGesture(
        tester.getCenter(find.byType(Scrollbar)),
      );
      await gesture.moveBy(const Offset(0, -40));
      await gesture.moveBy(const Offset(0, -60));
      await tester.pump();

      // No time has passed, so anything but an immediate move is still at 0.
      expect(position.pixels, greaterThan(0));
      await gesture.up();
    });

    testWidgets('opens another recipe at its top, even mid-glide', (
      tester,
    ) async {
      const other = 'lib/recipes/other.dart';
      final bundle = _Bundle({path: long, other: long});
      Widget pane(String assetPath) => MaterialApp(
        home: Scaffold(
          body: CodePane(assetPath: assetPath, bundle: bundle),
        ),
      );

      await tester.pumpWidget(pane(path));
      await tester.pumpAndSettle();
      await _wheel(tester, const Offset(0, 120));
      await tester.pump(const Duration(milliseconds: 16));
      expect(_position(tester, Axis.vertical).pixels, greaterThan(0));

      await tester.pumpWidget(pane(other));
      await tester.pumpAndSettle();

      expect(_position(tester, Axis.vertical).pixels, 0);
    });
  });
}
