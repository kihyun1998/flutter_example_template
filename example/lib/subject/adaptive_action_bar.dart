/// The package this example demonstrates.
///
/// It is not a table, and that is the point: the shell around it was extracted
/// from a table package's example app, so a gallery that could only be shown
/// demonstrating a table would not have proven anything.
///
/// **Nothing in this directory imports the shell.** A consumer's package does
/// not know it is being demonstrated.
library;

import 'package:flutter/material.dart';

/// How much room each action is given.
enum ActionBarDensity {
  comfortable('Comfortable'),
  dense('Dense');

  const ActionBarDensity(this.label);
  final String label;
}

/// Where the actions sit when there is room to spare.
enum ActionBarAlignment {
  start('Start'),
  center('Center'),
  end('End');

  const ActionBarAlignment(this.label);
  final String label;
}

/// One thing the bar can do.
@immutable
class BarAction {
  const BarAction({required this.id, required this.label, required this.icon});

  final String id;
  final String label;
  final IconData icon;
}

/// A row of actions that gives up label text, and then whole actions, as the
/// room it is given runs out.
///
/// The behaviour worth seeing is what happens when there **isn't** room: the
/// bar drops to icons, then moves what will not fit into an overflow menu. On a
/// desktop window there is always room, so that is the one thing a desktop-sized
/// demo can never show.
class AdaptiveActionBar extends StatelessWidget {
  const AdaptiveActionBar({
    super.key,
    required this.actions,
    this.showLabels = true,
    this.density = ActionBarDensity.comfortable,
    this.alignment = ActionBarAlignment.start,
    this.allowOverflow = true,
    this.showDivider = false,
    this.onPressed,
  });

  final List<BarAction> actions;
  final bool showLabels;
  final ActionBarDensity density;
  final ActionBarAlignment alignment;

  /// Whether actions that do not fit move into a menu.
  ///
  /// With this off they are simply not drawn. That is a real choice rather than
  /// a broken one — a bar of optional shortcuts can afford to lose the tail —
  /// but it is the choice most likely to surprise, so the gallery makes it a
  /// switch rather than a constant.
  final bool allowOverflow;

  final bool showDivider;
  final ValueChanged<BarAction>? onPressed;

  /// Roughly what one action asks for, in logical pixels.
  ///
  /// An estimate rather than a measurement: laying every action out twice to
  /// find out which ones fit costs more than it saves, and the bar only needs
  /// to be right about the *order* actions drop in.
  static double widthOf(
    BarAction action, {
    required bool showLabels,
    required ActionBarDensity density,
  }) {
    final dense = density == ActionBarDensity.dense;
    final button = dense ? 36.0 : 44.0;
    if (!showLabels) return button;
    return button + action.label.length * (dense ? 6.5 : 7.5) + (dense ? 8 : 12);
  }

  static const _overflowWidth = 44.0;

  /// How many of [actions] survive in [available] pixels.
  ///
  /// Exposed because the gallery reports it, and because a number a reader can
  /// see is worth more than a layout they have to infer.
  static int fitCount(
    List<BarAction> actions,
    double available, {
    required bool showLabels,
    required ActionBarDensity density,
    required bool allowOverflow,
  }) {
    final widths = [
      for (final a in actions)
        widthOf(a, showLabels: showLabels, density: density),
    ];
    final total = widths.fold(0.0, (sum, w) => sum + w);
    if (total <= available) return actions.length;

    final room = available - (allowOverflow ? _overflowWidth : 0);
    var used = 0.0;
    var n = 0;
    for (final w in widths) {
      if (used + w > room) break;
      used += w;
      n++;
    }
    return n;
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final visible = fitCount(
          actions,
          constraints.maxWidth,
          showLabels: showLabels,
          density: density,
          allowOverflow: allowOverflow,
        );
        final shown = actions.take(visible).toList();
        final hidden = actions.skip(visible).toList();

        return Row(
          mainAxisAlignment: switch (alignment) {
            ActionBarAlignment.start => MainAxisAlignment.start,
            ActionBarAlignment.center => MainAxisAlignment.center,
            ActionBarAlignment.end => MainAxisAlignment.end,
          },
          children: [
            for (var i = 0; i < shown.length; i++) ...[
              if (showDivider && i > 0)
                const SizedBox(
                  height: 20,
                  child: VerticalDivider(width: 9, thickness: 1),
                ),
              _button(context, shown[i]),
            ],
            if (hidden.isNotEmpty && allowOverflow)
              PopupMenuButton<BarAction>(
                icon: const Icon(Icons.more_horiz),
                tooltip: '${hidden.length} more',
                onSelected: (a) => onPressed?.call(a),
                itemBuilder: (context) => [
                  for (final a in hidden)
                    PopupMenuItem(
                      value: a,
                      child: Row(
                        children: [
                          Icon(a.icon, size: 18),
                          const SizedBox(width: 12),
                          Text(a.label),
                        ],
                      ),
                    ),
                ],
              ),
          ],
        );
      },
    );
  }

  Widget _button(BuildContext context, BarAction action) {
    final dense = density == ActionBarDensity.dense;
    if (!showLabels) {
      return IconButton(
        icon: Icon(action.icon),
        iconSize: dense ? 18 : 20,
        tooltip: action.label,
        visualDensity: dense ? VisualDensity.compact : VisualDensity.standard,
        onPressed: () => onPressed?.call(action),
      );
    }
    return TextButton.icon(
      icon: Icon(action.icon, size: dense ? 16 : 18),
      label: Text(action.label),
      style: TextButton.styleFrom(
        visualDensity: dense ? VisualDensity.compact : VisualDensity.standard,
        padding: EdgeInsets.symmetric(horizontal: dense ? 8 : 12),
      ),
      onPressed: () => onPressed?.call(action),
    );
  }
}

/// A plausible set, long enough that a phone cannot hold it.
const demoActions = [
  BarAction(id: 'undo', label: 'Undo', icon: Icons.undo),
  BarAction(id: 'redo', label: 'Redo', icon: Icons.redo),
  BarAction(id: 'cut', label: 'Cut', icon: Icons.content_cut),
  BarAction(id: 'copy', label: 'Copy', icon: Icons.content_copy),
  BarAction(id: 'paste', label: 'Paste', icon: Icons.content_paste),
  BarAction(id: 'link', label: 'Link', icon: Icons.link),
  BarAction(id: 'image', label: 'Image', icon: Icons.image_outlined),
  BarAction(id: 'comment', label: 'Comment', icon: Icons.comment_outlined),
  BarAction(id: 'share', label: 'Share', icon: Icons.share_outlined),
  BarAction(id: 'more', label: 'Settings', icon: Icons.settings_outlined),
];
