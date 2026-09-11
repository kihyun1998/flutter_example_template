/// What the shell is asked to show — and who owns the state behind it.
library;

import 'shell_destination.dart';

/// The set of destinations one shell draws, together with their lifetime.
///
/// **The lifetime is why this is a port rather than a `List` parameter.** Every
/// destination that does anything is backed by a `ChangeNotifier` the stage and
/// the knob pane both read — that is what a destination *is* here, one object
/// with two views of it — and something has to dispose them. `ShellPage`'s state
/// did, because it also built the list; handing it a bare `List` would move the
/// building out and leave the disposing behind, which is the half-repair shape
/// a half-repair always takes: the building moves out and the disposing stays
/// behind, and nothing anywhere reports it. A leaked
/// notifier throws nothing and fails no test.
///
/// So the shell still creates this once with its state and disposes it with its
/// state, exactly as before. What it no longer does is *know what is in it*.
///
/// [all] is read on every build. Implementations return a field, not a fresh
/// list: the shell holds the selected id rather than the selected object, but
/// `ShellMenu` and the stage both walk this on the same frame and a list rebuilt
/// per call would rebuild every destination's builder with it.
abstract class ShellDestinations {
  /// Every destination, in menu order. Grouping is [ShellCategory]'s job.
  ///
  /// **No shape is required of it.** Any mix of the two kinds is legal,
  /// including none of one: a roster holding only [RouteDestination]s claims no
  /// stage and no knob region, and the shell draws neither rather than drawing
  /// them empty (ADR-0005). Nothing here has to be ordered by kind either — the
  /// first [StageDestination] opens, wherever in the list it sits.
  ///
  /// What is *not* free is changing that shape later: the shell reads it once,
  /// with its state, so a list that grows its first [StageDestination] after
  /// the first build keeps the menu-only page until the reader picks something.
  /// That is the same field-not-a-fresh-list rule above, seen from the other
  /// side.
  List<ShellDestination> get all;

  /// Releases whatever the destinations hold.
  void dispose();
}
