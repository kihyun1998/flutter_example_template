// The bar doing its job inside something, rather than on its own.
//
// A scenario is several things assembled, so it is the one place the knobs
// reach a realistic composition: the bar sits over a document body, and the
// space it is given is the space a real toolbar gets.
//
// **This passes no `source` to its destination**, and that is deliberate rather
// than an oversight. The Code pane is the affordance of the pasteable claim,
// and a scenario is not the unit anyone pastes.

import 'package:flutter/material.dart';

import '../subject/adaptive_action_bar.dart';

class EditorToolbar extends StatelessWidget {
  const EditorToolbar({
    super.key,
    required this.actionCount,
    required this.showLabels,
    required this.density,
    required this.alignment,
    required this.allowOverflow,
    required this.showDivider,
  });

  final int actionCount;
  final bool showLabels;
  final ActionBarDensity density;
  final ActionBarAlignment alignment;
  final bool allowOverflow;
  final bool showDivider;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Column(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: scheme.surfaceContainerLow,
            border: Border(bottom: BorderSide(color: scheme.outlineVariant)),
          ),
          child: AdaptiveActionBar(
            actions: demoActions.take(actionCount).toList(),
            showLabels: showLabels,
            density: density,
            alignment: alignment,
            allowOverflow: allowOverflow,
            showDivider: showDivider,
          ),
        ),
        Expanded(
          child: Container(
            width: double.infinity,
            color: scheme.surface,
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Untitled', style: Theme.of(context).textTheme.titleLarge),
                const SizedBox(height: 12),
                Text(
                  'The toolbar above is the thing being demonstrated. Narrow the '
                  'viewport, or open the Device Wall, and watch which actions it '
                  'gives up first.',
                  style: TextStyle(color: scheme.onSurfaceVariant, height: 1.5),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
