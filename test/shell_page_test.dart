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

StageDestination _stage(String id) => StageDestination(
  id: id,
  label: id,
  category: ShellCategory.recipes,
  stage: (context) => Text('the $id stage'),
  knobs: (context) => Text('the $id knobs'),
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
      expect(
        find.text('nothing here yet'),
        findsNWidgets(ShellCategory.values.length),
        reason: 'every category is empty, and the roster of them is not typed '
            'out here',
      );
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
}
