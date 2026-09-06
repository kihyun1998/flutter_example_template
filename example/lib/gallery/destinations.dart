// What the menu points at, and who owns the state behind it.
//
// The one file besides `main.dart` that both knows the shell and knows the
// package being demonstrated. Everything else sits on one side or the other.

import 'package:flutter/material.dart';
import 'package:flutter_example_template/flutter_example_template.dart';

import '../pages/about_page.dart';
import '../recipes/basic_action_bar.dart';
import '../recipes/overflow_action_bar.dart';
import '../scenarios/editor_toolbar.dart';
import 'settings.dart';
import 'settings_panel.dart';

class ActionBarDestinations implements ShellDestinations {
  ActionBarDestinations();

  final _settings = GallerySettingsNotifier();

  /// A field, not a fresh list. The menu and the stage both walk this on the
  /// same frame, and a list rebuilt per call would rebuild every destination's
  /// builder with it.
  late final List<ShellDestination> _all = [
    StageDestination(
      id: 'basic',
      label: 'Basic bar',
      category: ShellCategory.recipes,
      source: 'lib/recipes/basic_action_bar.dart',
      stage: (context) => const BasicActionBar(),
      knobs: (context) => const _Note(
        'A recipe has no knobs of its own. It is one file, shown running and '
        'shown as source, and the Code tab above is the point of it.',
      ),
    ),
    StageDestination(
      id: 'overflow',
      label: 'Overflow order',
      category: ShellCategory.recipes,
      source: 'lib/recipes/overflow_action_bar.dart',
      stage: (context) => const OverflowActionBar(),
      knobs: (context) => const _Note(
        'Three fixed widths in one viewport, so the drop order is visible '
        'without resizing anything.',
      ),
      // Three stacked bars in each of three frames is nine bars over one
      // question. The wall compares viewports; this recipe already compares
      // widths, so the two answer the same thing twice.
      allowsWall: false,
    ),
    StageDestination(
      id: 'toolbar',
      label: 'Editor toolbar',
      category: ShellCategory.scenarios,
      // No source: the Code pane is the affordance of the pasteable claim, and
      // a scenario is not the unit anyone pastes.
      stage: (context) => ListenableBuilder(
        listenable: _settings,
        builder: (context, _) {
          final s = _settings.value;
          return EditorToolbar(
            actionCount: s.actionCount,
            showLabels: s.showLabels,
            density: s.density,
            alignment: s.alignment,
            allowOverflow: s.allowOverflow,
            showDivider: s.showDivider,
          );
        },
      ),
      knobs: (context) => SettingsPanel(notifier: _settings),
    ),
    RouteDestination(
      id: 'about',
      label: 'About',
      category: ShellCategory.pages,
      open: (context) => const AboutPage(),
    ),
  ];

  @override
  List<ShellDestination> get all => _all;

  @override
  void dispose() => _settings.dispose();
}

class _Note extends StatelessWidget {
  const _Note(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Text(
        text,
        style: TextStyle(
          height: 1.5,
          color: Theme.of(context).colorScheme.onSurfaceVariant,
        ),
      ),
    );
  }
}
