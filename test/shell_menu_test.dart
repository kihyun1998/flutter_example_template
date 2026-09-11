import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_example_template/flutter_example_template.dart';

// #11 chose "hide an empty category outright", so the first two tests here are
// the inverse of what they asserted before: they used to pin a header and a
// *nothing here yet* over every category the roster left empty. They are kept
// as the same two cases rather than deleted because the behaviour they cover
// is the same behaviour, answered the other way — a reader comparing them
// against the issue should find both halves.
//
// The empty-roster line is the one thing that survived from the old empty
// state, and it is somewhere else on purpose: an empty category is a
// capability nobody claimed and draws nothing (ADR-0005), while an empty
// roster is the whole page. The third test is what keeps those two from
// collapsing back into each other.
//
// Pumping through `ShellPage` cannot ask these questions: the shell hands the
// menu whatever the roster holds, so a partly-filled roster and a null
// selection are reachable from here and from nowhere else.

// Mutated and watched failing, and one of these was worth the pass: swapping
// the highlight predicate for "the first entry in the category" left *the open
// one is the only entry highlighted* green, because it counted the highlights
// without asking which row wore one. The same root showed up again at the
// open-in-new icon. Both now name the row.
//
// The three mutations run for #11, each reddening only what it should. Putting
// the header back outside the empty check took the first two tests; dropping
// the empty-roster line took the third. The third mutation is the one that
// shaped these: drawing that line beside the sections rather than instead of
// them reddens the first two and *not* the third, because a line that is
// always there is still there when the roster is empty. What catches it is the
// `findsNothing` below and the text count beside it — an assertion about where
// the line is absent, which is the half a test of the empty case cannot make.
//
// A first attempt at that mutation replaced the whole condition with `true`,
// which dropped every entry as well and reddened nine tests. A mutation that
// breaks more than the rule under test says nothing about the rule.

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
      find
          .ancestor(of: find.text(label), matching: find.byType(Material))
          .first,
    )
    .color;

void main() {
  testWidgets('a category with nothing in it is not drawn at all', (t) async {
    await t.pumpWidget(_menu([_stage('basic', ShellCategory.recipes)]));

    expect(
      find.text(ShellCategory.recipes.title.toUpperCase()),
      findsOneWidget,
      reason: 'the one the roster filled',
    );
    for (final category in ShellCategory.values.where(
      (c) => c != ShellCategory.recipes,
    )) {
      expect(
        find.text(category.title.toUpperCase()),
        findsNothing,
        reason: '${category.title} has no header, not an empty one',
      );
    }
    // The empty-roster line belongs to a roster, not to a category, and this
    // roster is not empty. Without this a line drawn unconditionally would sit
    // under the one filled category and no test here would mind.
    expect(find.text('No destinations yet.'), findsNothing);
  });

  testWidgets('a roster of routes alone draws its category and no other', (
    t,
  ) async {
    await t.pumpWidget(_menu([_route('about', ShellCategory.pages)]));

    expect(find.text('about'), findsOneWidget);
    expect(
      find.text(ShellCategory.pages.title.toUpperCase()),
      findsOneWidget,
      reason: 'the route is listed under its own category',
    );
    expect(
      find.byType(Text),
      findsNWidgets(2),
      reason:
          'a header and an entry — the two content categories contribute '
          'no text at all, which counting is the only way to say without '
          'naming every category that is absent',
    );
  });

  testWidgets('a roster with nothing in it says so once, for the roster', (
    t,
  ) async {
    await t.pumpWidget(_menu([]));

    expect(
      find.text('No destinations yet.'),
      findsOneWidget,
      reason: 'once for the menu, not once per category',
    );
    for (final category in ShellCategory.values) {
      expect(
        find.text(category.title.toUpperCase()),
        findsNothing,
        reason: category.title,
      );
    }
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
