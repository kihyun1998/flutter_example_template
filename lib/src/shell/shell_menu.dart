/// The category menu down the left of the shell.
library;

import 'package:flutter/material.dart';

import 'shell_destination.dart';

/// Lists every destination under its category, and says which one is open.
///
/// A category with nothing in it is still drawn, with a line saying so. That is
/// a real empty state rather than a placeholder: the categories are the shape of
/// what this example intends to hold, and hiding one until it fills would make
/// the menu appear to grow new sections out of nowhere.
///
/// **The branch below is reachable from `ShellPage` again.** A roster holding
/// no `StageDestination` leaves both content categories empty, and the shell
/// draws this menu alone for one (ADR-0005) — so the empty state is somewhere a
/// reader lands rather than somewhere the next category will.
///
/// This paragraph is its own counter-example twice over, which is why the
/// history stays. It once named `Scenarios` as the live empty category and went
/// false when scenarios arrived, with no test noticing. It then claimed the
/// branch was "pinned by a test that pumps this widget directly" while no such
/// test existed anywhere in the tree. `test/shell_menu_test.dart` is that test
/// now.
class ShellMenu extends StatelessWidget {
  const ShellMenu({
    super.key,
    required this.destinations,
    required this.selectedId,
    required this.onSelected,
    this.width = 232,
  });

  final List<ShellDestination> destinations;

  /// The open [StageDestination], or null when none is.
  ///
  /// A [RouteDestination] never becomes the selection — it leaves the shell, so
  /// there is nothing here for it to be selected *into*.
  final String? selectedId;

  final ValueChanged<ShellDestination> onSelected;
  final double width;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Container(
      width: width,
      decoration: BoxDecoration(
        border: Border(
          right: BorderSide(color: Theme.of(context).dividerColor),
        ),
      ),
      child: ListView(
        padding: const EdgeInsets.symmetric(vertical: 8),
        children: [
          for (final category in ShellCategory.values) ...[
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 6),
              child: Text(
                category.title.toUpperCase(),
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 1.1,
                  color: scheme.onSurfaceVariant,
                ),
              ),
            ),
            ..._entriesFor(context, category, scheme),
          ],
        ],
      ),
    );
  }

  List<Widget> _entriesFor(
    BuildContext context,
    ShellCategory category,
    ColorScheme scheme,
  ) {
    final entries = destinations.where((d) => d.category == category).toList();
    if (entries.isEmpty) {
      return [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 2, 16, 6),
          child: Text(
            'nothing here yet',
            style: TextStyle(fontSize: 12.5, color: scheme.outline),
          ),
        ),
      ];
    }

    return [
      for (final destination in entries)
        _Entry(
          destination: destination,
          selected: destination.id == selectedId,
          onTap: () => onSelected(destination),
        ),
    ];
  }
}

class _Entry extends StatelessWidget {
  const _Entry({
    required this.destination,
    required this.selected,
    required this.onTap,
  });

  final ShellDestination destination;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final leavesTheShell = destination is RouteDestination;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 1),
      child: Material(
        color: selected ? scheme.secondaryContainer : Colors.transparent,
        borderRadius: BorderRadius.circular(6),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(6),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    destination.label,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 13.5,
                      fontWeight: selected
                          ? FontWeight.w600
                          : FontWeight.normal,
                      color: selected
                          ? scheme.onSecondaryContainer
                          : scheme.onSurface,
                    ),
                  ),
                ),
                // Says out loud that this one leaves. Without it the menu
                // promises every entry behaves the same way, and one does not.
                if (leavesTheShell)
                  Icon(
                    Icons.open_in_new,
                    size: 14,
                    color: scheme.onSurfaceVariant,
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
