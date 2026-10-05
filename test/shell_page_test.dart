import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_example_template/flutter_example_template.dart';

// Every rule here was mutated and watched failing before it was believed. Two
// of the mutations did **not** redden, and both bought an assertion:
//
// * `_selectedId`'s initialiser reverted to `.first` — green, because
//   `_menuOnly` passed a literal `null` and `Iterable.where` is lazy, so
//   nothing forced it. Closed in the code, not the test: the page passes the
//   field, and the same mutation now throws where the crash was reported.
// * the initialiser changed to "first destination of any kind" — green,
//   because every roster here that held a stage destination held it first.
//   Closed by the route-first case below.
//
// Two more reddened as named: turning the whole change off took the four
// no-stage-destination cases and left the other group green, and drawing an
// empty stage beside the menu instead of nothing took exactly the width
// assertion — which is the one carrying the decision, the `findsNothing` trio
// being unable to tell full silence from empty chrome.

/// A roster the shell is handed, with nothing behind it to dispose.
///
/// The port exists so the shell can be given a set it did not build; that is
/// what makes these cases reachable at all without a subject.
class _Roster implements ShellDestinations {
  _Roster(this.all);

  @override
  final List<ShellDestination> all;

  @override
  void dispose() {}
}

RouteDestination _route(String id) => RouteDestination(
  id: id,
  label: id,
  category: ShellCategory.pages,
  open: (context) => Scaffold(body: Text('the $id page')),
);

StageDestination _stage(String id, {bool allowsWall = true}) =>
    StageDestination(
      id: id,
      label: id,
      category: ShellCategory.recipes,
      stage: (context) => Text('the $id stage'),
      knobs: (context) => Text('the $id knobs'),
      allowsWall: allowsWall,
    );

Widget _shell(List<ShellDestination> all) => MaterialApp(
  home: ShellPage(title: 'x', createDestinations: () => _Roster(all)),
);

/// The shell above its own breakpoint, where all three regions fit.
///
/// The default 800x600 surface is below [ShellPage.narrowBreakpoint], so a test
/// that never sets this exercises one of the two layouts and says nothing about
/// the other. The reported crash was raised from the wide one.
Future<void> _wide(WidgetTester t) async {
  await t.binding.setSurfaceSize(const Size(1400, 900));
  addTearDown(() => t.binding.setSurfaceSize(null));
}

void main() {
  group('a roster with no stage destination', () {
    testWidgets('opens', (t) async {
      await t.pumpWidget(_shell([_route('about')]));

      expect(find.byType(ShellMenu), findsOneWidget);
      expect(find.text('about'), findsOneWidget, reason: 'the route is listed');
    });

    testWidgets('draws no stage, no knob region and no tab bar', (t) async {
      await t.pumpWidget(_shell([_route('about')]));

      expect(find.byType(PreviewFrame), findsNothing, reason: 'no stage');
      expect(find.byType(ViewportBar), findsNothing, reason: 'no toolbar');
      expect(find.byType(TabBar), findsNothing, reason: 'nothing to tab to');
    });

    testWidgets('gives the menu the whole width, above the breakpoint too', (
      t,
    ) async {
      await _wide(t);
      await t.pumpWidget(_shell([_route('about')]));

      expect(find.byType(PreviewFrame), findsNothing, reason: 'no stage');
      expect(find.byType(ViewportBar), findsNothing, reason: 'no toolbar');
      // Read off the screen rather than off the layout branch: a menu still
      // 232 wide would mean the other two regions are there and empty.
      expect(t.getSize(find.byType(ShellMenu)).width, 1400);
    });

    testWidgets('and neither does an empty one', (t) async {
      await t.pumpWidget(_shell([]));

      expect(find.byType(ShellMenu), findsOneWidget);
      // What the menu says here is `shell_menu_test.dart`'s question. What
      // this one asks is that the shell still draws it: with #11's fix the
      // empty categories are gone, so this page's entire content is the one
      // line below, and silence would be a blank screen indistinguishable
      // from a failed build.
      expect(find.text('No destinations yet.'), findsOneWidget);
    });

    testWidgets('a route still opens on its own route', (t) async {
      await t.pumpWidget(_shell([_route('about')]));

      await t.tap(find.text('about'));
      await t.pumpAndSettle();

      expect(find.text('the about page'), findsOneWidget);
    });
  });

  group('a roster that does supply one', () {
    testWidgets('draws the stage, its toolbar and the knobs', (t) async {
      await _wide(t);
      await t.pumpWidget(_shell([_stage('basic'), _route('about')]));

      expect(find.text('the basic stage'), findsOneWidget);
      expect(find.text('the basic knobs'), findsOneWidget);
      expect(find.byType(ViewportBar), findsOneWidget);
      expect(
        t.getSize(find.byType(ShellMenu)).width,
        lessThan(1400),
        reason: 'the menu is one of three regions again',
      );
    });

    testWidgets('opens the first stage destination, not the first entry', (
      t,
    ) async {
      await _wide(t);
      await t.pumpWidget(_shell([_route('about'), _stage('basic')]));

      // Ordered route-first on purpose. Picking "the first destination of any
      // kind" leaves nothing to open here while a stage destination is sitting
      // in the roster, and every other case in this file would still pass.
      expect(find.text('the basic stage'), findsOneWidget);
    });

    testWidgets('below the breakpoint the three regions become tabs', (
      t,
    ) async {
      await t.pumpWidget(_shell([_stage('basic')]));

      expect(find.byType(TabBar), findsOneWidget);
    });
  });

  group('the stage modes', () {
    SegmentedButton<String> bar(WidgetTester t) =>
        t.widget(find.byType(SegmentedButton<String>));

    List<String> segments(WidgetTester t) =>
        bar(t).segments.map((s) => s.value).toList();

    Future<void> choose(WidgetTester t, String label) async {
      await t.tap(find.byTooltip(label));
      await t.pumpAndSettle();
    }

    testWidgets('offers the room between the viewports and the wall', (
      t,
    ) async {
      await _wide(t);
      await t.pumpWidget(_shell([_stage('basic')]));

      expect(segments(t), ['desktop', 'tablet', 'mobile', 'room', 'all']);
    });

    testWidgets('offers the room where the wall is refused', (t) async {
      await _wide(t);
      await t.pumpWidget(_shell([_stage('basic', allowsWall: false)]));

      expect(segments(t), ['desktop', 'tablet', 'mobile', 'room']);
    });

    testWidgets('opens on the desktop viewport, framed', (t) async {
      await _wide(t);
      await t.pumpWidget(_shell([_stage('basic')]));

      expect(find.byType(PreviewFrame), findsOneWidget);
      expect(find.byType(PreviewRoom), findsNothing);
      expect(bar(t).selected, {'desktop'});
    });

    testWidgets('the room draws the stage unframed, with no fit control', (
      t,
    ) async {
      await _wide(t);
      await t.pumpWidget(_shell([_stage('basic')]));
      expect(find.text('Fit'), findsOneWidget, reason: 'framed, it is there');

      await choose(t, ViewportBar.roomLabel);

      expect(find.byType(PreviewRoom), findsOneWidget);
      expect(find.byType(PreviewFrame), findsNothing);
      expect(find.text('the basic stage'), findsOneWidget);
      expect(find.text('Fit'), findsNothing);
      expect(find.text('1:1'), findsNothing);
    });

    testWidgets('the stage builder itself is told the room, not the window', (
      t,
    ) async {
      await _wide(t);
      await t.pumpWidget(
        _shell([
          StageDestination(
            id: 'reads',
            label: 'reads',
            category: ShellCategory.recipes,
            stage: (context) => Text('told ${MediaQuery.sizeOf(context)}'),
            knobs: (context) => const SizedBox(),
          ),
        ]),
      );

      await choose(t, ViewportBar.roomLabel);

      final room = t.widget<MediaQuery>(
        find.descendant(
          of: find.byType(PreviewRoom),
          matching: find.byType(MediaQuery),
        ),
      );
      expect(room.data.size.width, lessThan(1400));
      expect(find.text('told ${room.data.size}'), findsOneWidget);
    });

    testWidgets('the stage builder itself is told a framed viewport too', (
      t,
    ) async {
      await _wide(t);
      await t.pumpWidget(
        _shell([
          StageDestination(
            id: 'reads',
            label: 'reads',
            category: ShellCategory.recipes,
            stage: (context) => Text('told ${MediaQuery.sizeOf(context)}'),
            knobs: (context) => const SizedBox(),
          ),
        ]),
      );

      await choose(t, ViewportSpec.mobile.label);

      expect(find.text('told Size(390.0, 844.0)'), findsOneWidget);
    });

    testWidgets('a forced exit from the wall returns to the room', (t) async {
      await _wide(t);
      await t.pumpWidget(
        _shell([_stage('basic'), _stage('costly', allowsWall: false)]),
      );

      await choose(t, ViewportBar.roomLabel);
      await choose(t, ViewportBar.wallLabel);
      expect(find.byType(DeviceWall), findsOneWidget);

      await t.tap(find.text('costly'));
      await t.pumpAndSettle();

      expect(find.byType(DeviceWall), findsNothing);
      expect(find.byType(PreviewRoom), findsOneWidget);
      expect(bar(t).selected, {'room'});
    });
  });

  group('the stage toolbar', () {
    // Every width the narrow layout can be given, at a step fine enough to
    // land inside the band where it used to overflow.
    final widths = [for (var w = 400; w < 900; w += 10) w];

    Future<List<int>> overflowing(WidgetTester t, String? source) async {
      final found = <int>[];
      for (final w in widths) {
        t.view.physicalSize = Size(w.toDouble(), 800);
        t.view.devicePixelRatio = 1.0;
        await t.pumpWidget(
          MaterialApp(
            key: ValueKey(w),
            home: ShellPage(
              title: 'x',
              createDestinations: () => _Roster([
                StageDestination(
                  id: 'basic',
                  label: 'basic',
                  category: ShellCategory.recipes,
                  stage: (context) => const SizedBox.expand(),
                  knobs: (context) => const SizedBox(),
                  source: source,
                ),
              ]),
            ),
          ),
        );
        await t.tap(find.text('Preview').first);
        await t.pumpAndSettle();
        if (t.takeException() != null) found.add(w);
      }
      t.view.reset();
      return found;
    }

    testWidgets('fits every narrow width', (t) async {
      expect(await overflowing(t, null), isEmpty);
    });

    testWidgets('fits every narrow width with the Code control too', (t) async {
      expect(await overflowing(t, 'lib/basic.dart'), isEmpty);
    });
  });
}
