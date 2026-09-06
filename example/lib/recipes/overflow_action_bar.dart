// The same bar, given less room than it wants.
//
// Three fixed widths, stacked, so the drop order is visible without resizing
// anything: labels go first, then whole actions move into the menu. The
// preview stage answers the same question for a real viewport; this answers it
// for three widths at once inside one viewport, which is what a reader gets by
// pasting the file rather than running the gallery.

import 'package:flutter/material.dart';

import '../subject/adaptive_action_bar.dart';

class OverflowActionBar extends StatelessWidget {
  const OverflowActionBar({super.key});

  static const _widths = [520.0, 320.0, 180.0];

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        for (final width in _widths) ...[
          Text(
            '${width.toInt()} px',
            style: Theme.of(context).textTheme.labelMedium,
          ),
          const SizedBox(height: 6),
          Align(
            alignment: Alignment.centerLeft,
            child: SizedBox(
              width: width,
              child: Card(
                margin: EdgeInsets.zero,
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  child: AdaptiveActionBar(actions: demoActions),
                ),
              ),
            ),
          ),
          const SizedBox(height: 24),
        ],
      ],
    );
  }
}
