import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_example_template/flutter_example_template.dart';

// `shell_menu.dart` keeps a branch no roster in this repository reaches: a
// category with nothing in it. Its own doc-comment says the branch is kept
// because "the next category added is added empty, which is exactly when it is
// needed and exactly when nobody would think to write it", and that it is held
// by a test pumping the widget directly rather than through the shell.
//
// These pin what the widget does today, which is not the same as endorsing it:
// whether an empty category should be visible at all is open in #11, and
// "hide an empty category outright" is one of the options there. If that is
// what gets chosen, the first two tests change with it. What they are for
// meanwhile is that the behaviour stopped being unguarded.
//
// This is that test. Pumping through `ShellPage` cannot ask these questions:
// the shell hands the menu whatever the roster holds, so the empty branch and a
// null selection are reachable from here and from nowhere else.

// Mutated and watched failing, and one of these was worth the pass: swapping
// the highlight predicate for "the first entry in the category" left *the open
// one is the only entry highlighted* green, because it counted the highlights
// without asking which row wore one. The same root showed up again at the
// open-in-new icon. Both now name the row. Dropping the header text and
// dropping the empty-category line were mutated separately, so each half of
// the first test is known to fail on its own.

StageDestination _stage(String id, ShellCategory category) => StageDestination(
  id: id,
  label: id,
  category: category,
  stage: (context) => const SizedBox.shrink(),
  knobs: (context) => const SizedBox.shrink(),
);

RouteDestination _route(String id, ShellCategory category) => RouteDestination(
  id: id,
  label: id,
  category: category,
  open: (context) => const SizedBox.shrink(),
);

Widget _menu(List<ShellDestination> destinations, {String? selected}) =>
    MaterialApp(
      home: Scaffold(
        body: ShellMenu(
          destinations: destinations,
          selectedId: selected,
          onSelected: (_) {},
        ),
      ),
    );

/// The highlight, read off what is painted rather than off the selected id.
///
/// Every `Material` under the menu is one entry's background, and the open one
/// is the only entry that is not transparent.
Iterable<Color?> _entryColours(WidgetTester t) => t
    .widgetList<Material>(
      find.descendant(
        of: find.byType(ShellMenu),
        matching: find.byType(Material),
      ),
    )
    .map((m) => m.color);

/// The background painted behind one entry, found by its label.
Color? _colourOf(WidgetTester t, String label) => t
    .widget<Material>(
      find.ancestor(of: find.text(label), matching: find.byType(Material)).first,
    )
    .color;

void main() {
  testWidgets('a category with nothing in it is still drawn, and says so', (
    t,
  ) async {
    await t.pumpWidget(_menu([_stage('basic', ShellCategory.recipes)]));

    for (final category in ShellCategory.values) {
      expect(
        find.text(category.title.toUpperCase()),
        findsOneWidget,
        reason: category.title,
      );
    }
    expect(
      find.text('nothing here yet'),
      findsNWidgets(ShellCategory.values.length - 1),
      reason: 'one for every category the roster left empty',
    );
  });

  testWidgets('a roster of routes alone leaves every content category empty', (
    t,
  ) async {
    await t.pumpWidget(_menu([_route('about', ShellCategory.pages)]));

    expect(
      find.text('nothing here yet'),
      findsNWidgets(ShellCategory.values.length - 1),
      reason: 'every category but the one this roster fills',
    );
    expect(find.text('about'), findsOneWidget);
  });

  testWidgets('no selection highlights nothing', (t) async {
    await t.pumpWidget(
      _menu([
        _stage('basic', ShellCategory.recipes),
        _route('about', ShellCategory.pages),
      ]),
    );

    expect(
      _entryColours(t),
      everyElement(Colors.transparent),
      reason: 'a null selection is a real state, not a missing one',
    );
  });

  testWidgets('the open one is the only entry highlighted', (t) async {
    await t.pumpWidget(
      _menu([
        _stage('basic', ShellCategory.recipes),
        _stage('other', ShellCategory.recipes),
      ], selected: 'other'),
    );

    expect(
      _entryColours(t).where((c) => c != Colors.transparent),
      hasLength(1),
    );
    // Which one, not how many. Highlighting the wrong single entry counts the
    // same, and a menu whose highlight follows position rather than the open
    // id passes anything that only counts.
    expect(_colourOf(t, 'other'), isNot(Colors.transparent));
    expect(_colourOf(t, 'basic'), Colors.transparent);
  });

  testWidgets('an entry that leaves the shell says so', (t) async {
    await t.pumpWidget(
      _menu([
        _stage('basic', ShellCategory.recipes),
        _route('about', ShellCategory.pages),
      ]),
    );

    // Beside which entry, not how many on screen. One icon on the wrong row
    // counts the same as one on the right row.
    expect(
      find.descendant(
        of: find.ancestor(of: find.text('about'), matching: find.byType(Row)),
        matching: find.byIcon(Icons.open_in_new),
      ),
      findsOneWidget,
    );
    expect(
      find.descendant(
        of: find.ancestor(of: find.text('basic'), matching: find.byType(Row)),
        matching: find.byIcon(Icons.open_in_new),
      ),
      findsNothing,
      reason: 'a stage destination does not leave the shell',
    );
  });
}
