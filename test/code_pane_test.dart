import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
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
      position: tester.getCenter(find.byType(Scrollbar).first),
      scrollDelta: delta,
    ),
  );
  await tester.pump();
}

/// The scrollbar thumbs on [axis] that are painted in the pane and take a
/// pointer, as global rects.
///
/// Read from each [ScrollbarPainter]'s own hit test, which answers from the
/// thumb it last painted and refuses one faded to transparent or belonging to a
/// non-interactive bar, swept over the band along the pane's bottom edge
/// (horizontal) or right edge (vertical). Two painters drawing the same thumb in
/// the same place count as two. Counting [Scrollbar] widgets cannot tell a
/// painted thumb from a wrapper.
List<Rect> _thumbs(WidgetTester tester, Axis axis) {
  final pane = tester.getRect(find.byType(Scrollbar).first);
  final band = switch (axis) {
    Axis.horizontal => Rect.fromLTRB(
      pane.left,
      pane.bottom - 48,
      pane.right - 24,
      pane.bottom,
    ),
    Axis.vertical => Rect.fromLTRB(
      pane.right - 24,
      pane.top,
      pane.right,
      pane.bottom - 48,
    ),
  };
  final thumbs = <Rect>[];
  for (final box in tester.renderObjectList<RenderCustomPaint>(
    find.descendant(
      of: find.byType(CodePane),
      matching: find.byType(CustomPaint),
    ),
  )) {
    final painter = box.foregroundPainter;
    if (painter is! ScrollbarPainter) continue;
    Rect? hits;
    for (var y = band.top; y < band.bottom; y += 1) {
      for (var x = band.left; x < band.right; x += 1) {
        final at = Offset(x, y);
        if (painter.hitTestOnlyThumbInteractive(
          box.globalToLocal(at),
          PointerDeviceKind.mouse,
        )) {
          hits =
              hits?.expandToInclude(Rect.fromPoints(at, at)) ??
              Rect.fromPoints(at, at);
        }
      }
    }
    if (hits == null) continue;
    final along = axis == Axis.horizontal ? hits.width : hits.height;
    final across = axis == Axis.horizontal ? hits.height : hits.width;
    if (along > across) thumbs.add(hits);
  }
  return thumbs;
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
        tester.getCenter(find.byType(Scrollbar).first),
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

  group('a long line', () {
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

    testWidgets(
      'can be reached on Android by dragging the bar, drawn at rest',
      (tester) async {
        debugDefaultTargetPlatformOverride = TargetPlatform.android;
        try {
          await pumpLong(tester);
          final position = _position(tester, Axis.horizontal);

          final thumbs = _thumbs(tester, Axis.horizontal);
          expect(
            thumbs,
            hasLength(1),
            reason: 'drawn, and taking a finger, before anything scrolls',
          );

          final pane = tester.getRect(find.byType(Scrollbar).first);
          await tester.timedDragFrom(
            thumbs.single.center,
            Offset(pane.right - thumbs.single.center.dx, 0),
            const Duration(milliseconds: 400),
          );
          await tester.pumpAndSettle();
          expect(position.pixels, position.maxScrollExtent);
        } finally {
          debugDefaultTargetPlatformOverride = null;
        }
      },
    );

    testWidgets('can still be selected on Android with a long press', (
      tester,
    ) async {
      debugDefaultTargetPlatformOverride = TargetPlatform.android;
      try {
        await pumpLong(tester);
        await tester.longPressAt(
          tester.getCenter(find.byType(Scrollbar).first),
        );
        await tester.pumpAndSettle();

        final selection = tester
            .widget<EditableText>(find.byType(EditableText))
            .controller
            .selection;
        expect(selection.isCollapsed, isFalse);
      } finally {
        debugDefaultTargetPlatformOverride = null;
      }
    });

    testWidgets('has one bar per axis on desktop, at the top and at the end', (
      tester,
    ) async {
      debugDefaultTargetPlatformOverride = TargetPlatform.windows;
      try {
        await pumpLong(tester);
        expect(
          _thumbs(tester, Axis.horizontal),
          isEmpty,
          reason: 'hidden at rest',
        );

        Future<List<Rect>> afterShiftWheel() async {
          await tester.sendKeyDownEvent(LogicalKeyboardKey.shiftLeft);
          await _wheel(tester, const Offset(0, 60));
          await tester.sendKeyUpEvent(LogicalKeyboardKey.shiftLeft);
          // Frame by frame: the glide's notifications are what fade the bar
          // in, and one long pump is a single frame.
          for (var i = 0; i < 4; i++) {
            await tester.pump(const Duration(milliseconds: 100));
          }
          expect(_position(tester, Axis.horizontal).pixels, greaterThan(0));
          return _thumbs(tester, Axis.horizontal);
        }

        expect(await afterShiftWheel(), hasLength(1), reason: 'at the top');
        await tester.pumpAndSettle();

        await _wheel(tester, const Offset(0, 60));
        for (var i = 0; i < 4; i++) {
          await tester.pump(const Duration(milliseconds: 100));
        }
        expect(
          _thumbs(tester, Axis.vertical),
          hasLength(1),
          reason: 'and one vertical bar, not a second drawn over it',
        );
        await tester.pumpAndSettle();

        final vertical = _position(tester, Axis.vertical);
        vertical.jumpTo(vertical.maxScrollExtent);
        await tester.pumpAndSettle();
        expect(await afterShiftWheel(), hasLength(1), reason: 'at the end');
        await tester.pumpAndSettle();
      } finally {
        debugDefaultTargetPlatformOverride = null;
      }
    });

    testWidgets('keeps the bar clear of the system gesture area on a phone', (
      tester,
    ) async {
      debugDefaultTargetPlatformOverride = TargetPlatform.android;
      // Measured on the Medium Phone API 36.1 emulator, in physical pixels.
      tester.view
        ..devicePixelRatio = 2.625
        ..physicalSize = const Size(1080, 2400)
        ..padding = const FakeViewPadding(top: 63, bottom: 63)
        ..viewPadding = const FakeViewPadding(top: 63, bottom: 63)
        ..systemGestureInsets = const FakeViewPadding(bottom: 84);
      try {
        await pumpLong(tester);
        final thumbs = _thumbs(tester, Axis.horizontal);
        expect(thumbs, hasLength(1));

        final height = 2400 / 2.625;
        expect(thumbs.single.bottom, lessThanOrEqualTo(height - 84 / 2.625));

        // A pane whose bottom inset something else already took is not at the
        // edge, and its bar stays at its own bottom.
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: MediaQuery.removePadding(
                context: tester.element(find.byType(Scaffold)),
                removeBottom: true,
                child: CodePane(assetPath: path, bundle: _Bundle({path: long})),
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();
        expect(
          _thumbs(tester, Axis.horizontal).single.bottom,
          greaterThan(height - 84 / 2.625),
        );
      } finally {
        debugDefaultTargetPlatformOverride = null;
        tester.view.reset();
      }
    });
  });
}
