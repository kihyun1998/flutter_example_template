import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_example_template/flutter_example_template.dart';

/// What the subject was told the screen is, and what it was actually given.
class _Seen {
  Size? told;
  BoxConstraints? given;
  EdgeInsets? padding;
  EdgeInsets? viewInsets;
  EdgeInsets? viewPadding;
}

Widget _subject(_Seen seen) => LayoutBuilder(
  builder: (context, constraints) {
    final mq = MediaQuery.of(context);
    seen
      ..told = mq.size
      ..given = constraints
      ..padding = mq.padding
      ..viewInsets = mq.viewInsets
      ..viewPadding = mq.viewPadding;
    return const SizedBox.expand();
  },
);

/// A [PreviewRoom] given 600 × 400, in a window of 1440 × 900 that reports
/// insets of its own.
Future<void> _pumpRoom(WidgetTester t, Widget child) async {
  t.view.physicalSize = const Size(1440, 900);
  t.view.devicePixelRatio = 1.0;
  t.view.padding = const FakeViewPadding(top: 24, bottom: 34);
  addTearDown(t.view.reset);

  await t.pumpWidget(
    MaterialApp(
      home: Align(
        alignment: Alignment.topLeft,
        child: SizedBox(
          width: 600,
          height: 400,
          child: PreviewRoom(child: child),
        ),
      ),
    ),
  );
}

void main() {
  group('PreviewRoom', () {
    testWidgets('tells the subject the screen is the box it was given', (
      t,
    ) async {
      final seen = _Seen();
      await _pumpRoom(t, _subject(seen));

      expect(seen.given!.biggest, const Size(600, 374));
      expect(seen.told, const Size(600, 374));
    });

    testWidgets('reports no insets, whatever the window reports', (t) async {
      final seen = _Seen();
      await _pumpRoom(t, _subject(seen));

      expect(seen.padding, EdgeInsets.zero);
      expect(seen.viewPadding, EdgeInsets.zero);
      expect(seen.viewInsets, EdgeInsets.zero);
    });

    testWidgets('captions its own size at 1:1', (t) async {
      await _pumpRoom(t, const SizedBox.expand());

      expect(find.text('600 × 374 · 1:1'), findsOneWidget);
    });

    testWidgets('follows the room it is given when that changes', (t) async {
      await _pumpRoom(t, const SizedBox.expand());
      await t.pumpWidget(
        MaterialApp(
          home: Align(
            alignment: Alignment.topLeft,
            child: SizedBox(
              width: 500,
              height: 300,
              child: PreviewRoom(child: const SizedBox.expand()),
            ),
          ),
        ),
      );

      expect(find.text('500 × 274 · 1:1'), findsOneWidget);
    });

    testWidgets('gives the subject nothing when the room is smaller than '
        'its caption', (t) async {
      final seen = _Seen();
      t.view.physicalSize = const Size(1440, 900);
      t.view.devicePixelRatio = 1.0;
      addTearDown(t.view.reset);

      await t.pumpWidget(
        MaterialApp(
          home: Align(
            alignment: Alignment.topLeft,
            child: SizedBox(
              width: 600,
              height: 20,
              child: PreviewRoom(child: _subject(seen)),
            ),
          ),
        ),
      );

      expect(seen.told, const Size(600, 0));
    });

    testWidgets('puts no overlay of its own between the subject and the app', (
      t,
    ) async {
      await _pumpRoom(t, const SizedBox.expand());

      expect(
        find.descendant(
          of: find.byType(PreviewRoom),
          matching: find.byType(Overlay),
        ),
        findsNothing,
      );
    });
  });
}
