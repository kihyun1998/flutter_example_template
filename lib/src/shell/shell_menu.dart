/// The category menu down the left of the shell.
library;

import 'package:flutter/material.dart';

import 'shell_destination.dart';

/// Lists every destination under its category, and says which one is open.
///
/// **A category the roster left empty is not drawn at all** — no header, and no
/// line under it saying so. An unclaimed capability draws nothing (ADR-0005),
/// and nothing a host can pass claims a category: [ShellCategory] is a fixed
/// enum and `destinations` is the only input, so an empty one is always a
/// capability nobody supplied rather than one supplied empty. A header over a
/// *nothing here yet* was the same empty strip with a rule under it that the
/// ADR rejects for `PresetBar` by name.
///
/// The cost is that the menu grows a section when the first destination of a
/// kind arrives, which an earlier version of this comment argued against. It
/// was the wrong side of the trade: what it bought instead was three headings
/// that got emptier-looking as an example got better (#11).
///
/// **A roster holding nothing at all is a different question and gets a line.**
/// That is not an unclaimed capability but a shell with nothing to point at,
/// and since `ShellPage` draws this menu alone at full width for one (ADR-0005)
/// it is the whole screen — the one state a reader cannot tell apart from a
/// broken build.
///
/// Claims made here about the empty case have gone false three times without
/// the compiler caring: this paragraph named `Scenarios` as the live empty
/// category and went stale when scenarios arrived, then claimed a test pinned
/// the branch while no such test existed, and the behaviour both were
/// defending is now deleted. `test/shell_menu_test.dart` is what holds the
/// current answer, and it is the reason this comment is shorter than it was.
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
        children: destinations.isEmpty
            ? [_nothingToPointAt(scheme)]
            : [
                for (final category in ShellCategory.values)
                  ..._sectionFor(context, category, scheme),
              ],
      ),
    );
  }

  /// One category's header and its entries, or nothing when it has none.
  ///
  /// The header belongs to the entries rather than to the category, which is
  /// the whole change: walking [ShellCategory.values] still decides the order,
  /// but a value the roster did not fill contributes no widgets to walk past.
  List<Widget> _sectionFor(
    BuildContext context,
    ShellCategory category,
    ColorScheme scheme,
  ) {
    final entries = destinations.where((d) => d.category == category).toList();
    if (entries.isEmpty) return const [];

    return [
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
      for (final destination in entries)
        _Entry(
          destination: destination,
          selected: destination.id == selectedId,
          onTap: () => onSelected(destination),
        ),
    ];
  }

  /// Said once for the whole menu, and only when the roster is empty.
  ///
  /// Not per category: that is what this change removed. The reader being
  /// answered here is one who has wired the shell up and passed it nothing
  /// yet, and what they need to know is that they are looking at a working
  /// shell rather than a failed build.
  Widget _nothingToPointAt(ColorScheme scheme) => Padding(
    padding: const EdgeInsets.fromLTRB(20, 10, 16, 6),
    child: Text(
      'No destinations yet.',
      style: TextStyle(fontSize: 12.5, color: scheme.outline),
    ),
  );
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
