/// The shell — the page the rest of this example is built in.
library;

import 'package:flutter/material.dart';

import '../preview/device_wall.dart';
import '../preview/preview_frame.dart';
import '../preview/preview_stage.dart';
import '../preview/viewport_spec.dart';
import '../theme/theme_mode_button.dart';
import 'shell_destination.dart';
import 'shell_destinations.dart';
import 'shell_menu.dart';
import 'code_pane.dart';

/// A category menu, and — while a destination is open in it — a preview stage
/// and a knob region.
///
/// The menu points at destinations; a destination fills the other two, which is
/// why a roster supplying none leaves the menu alone on the page (ADR-0005).
/// That division is what makes the shell reusable — nothing here knows what a
/// recipe or a scenario is, only that a destination supplies a stage and some
/// knobs.
///
/// **A full page is pointed at, not absorbed.** Something with its own app bar
/// and its own panes would have to be taken apart to sit inside the stage, so
/// [RouteDestination] opens it on its own route instead.
///
/// **Nothing here names a destination.** The set arrives through
/// [ShellDestinations], and the bar's [title] with it, because both are the one
/// thing a shell around a different package could not reuse. The list used to be
/// a field of this state, which is what made a page that knows nothing about
/// recipes import every one of them.
class ShellPage extends StatefulWidget {
  const ShellPage({
    super.key,
    required this.title,
    required this.createDestinations,
  });

  /// What the app bar says.
  ///
  /// Deliberately not defaulted. A shell with a plausible fallback title is a
  /// shell that ships someone else's product name when a caller forgets.
  final String title;

  /// Builds the destinations, once, when this page's state is created.
  ///
  /// A factory rather than a built value: the state owns the result for exactly
  /// as long as it owns itself, which is the lifetime the notifiers behind the
  /// destinations already had. See [ShellDestinations].
  final ShellDestinations Function() createDestinations;

  /// What the knob region is given, and the width a destination's knobs have
  /// to work in.
  ///
  /// Public because the panes are written against it and were written against
  /// the wrong number: three comments in `lib/src/settings/` and two test pumps
  /// said 380, which is what this region was in the repository these files came
  /// from. A pane tested at 380 and drawn at 320 is a guard reading a width the
  /// app does not use — measured 2026-09-06, four sites out of step with one
  /// field.
  static const knobRegionWidth = 320.0;

  /// Below this the three regions do not fit side by side, and the shell shows
  /// one at a time instead. Measured against the widest of them plus the stage's
  /// narrowest viewport, not chosen for the shape of any particular device.
  static const narrowBreakpoint = 900.0;

  @override
  State<ShellPage> createState() => _ShellPageState();
}

class _ShellPageState extends State<ShellPage> {
  /// Built once, owned for exactly as long as this state is.
  late final ShellDestinations _destinationSet = widget.createDestinations();

  List<ShellDestination> get _destinations => _destinationSet.all;

  /// The open destination's id, or null when the roster holds none to open.
  ///
  /// **Nullable because a roster of [RouteDestination]s alone is a legal
  /// roster.** That is what `RouteDestination` already promises — the shell
  /// hands over, and nothing about the page it opens changes to accommodate
  /// being listed. This read `.whereType<StageDestination>().first.id` and
  /// threw `Bad state: No element` on the first build of any such roster, which
  /// is the shell requiring a shape nothing had written down.
  late String? _selectedId = _destinations
      .whereType<StageDestination>()
      .firstOrNull
      ?.id;

  /// A [ViewportSpec.id], or [ViewportBar.wallId] for the Device Wall.
  String _viewportId = ViewportSpec.desktop.id;

  /// The last single-viewport mode chosen.
  ///
  /// So a wall exit the reader did not ask for has somewhere to return to. The
  /// voluntary path needs nothing like this — leaving the wall by
  /// picking a segment *is* the choice — but the forced one used to land
  /// on `desktop` whatever the reader had been looking at, which is a constant
  /// standing in for a decision.
  String _lastViewportId = ViewportSpec.desktop.id;

  bool get _showingWall => _viewportId == ViewportBar.wallId;

  /// Shrink the whole viewport into view, rather than showing a 1:1 slice of it.
  ///
  /// The default, because the question the preview answers is "what does this
  /// look like on a desktop" — and a clipped 1:1 slice answers a different one.
  bool _fit = true;

  /// Whether the stage region is showing the open recipe's source instead of
  /// the recipe running.
  ///
  /// Kept across destination switches on purpose: a reader comparing two
  /// recipes' code should not have to press Code again for each one. It is
  /// ignored — and the control is not drawn — for a destination with no source.
  bool _showCode = false;

  @override
  void dispose() {
    _destinationSet.dispose();
    super.dispose();
  }

  /// The open destination, or null when the roster supplies none.
  StageDestination? get _open => _destinations
      .whereType<StageDestination>()
      .where((d) => d.id == _selectedId)
      .firstOrNull;

  void _select(ShellDestination destination) {
    switch (destination) {
      case RouteDestination(:final open):
        Navigator.of(context).push(MaterialPageRoute<void>(builder: open));
      case StageDestination(:final id, :final allowsWall):
        setState(() {
          _selectedId = id;
          // Leaving the wall is half of the exclusion, and it is the half
          // nothing reports. `_viewportId` is the shell's state and the open
          // destination is a different one, so without this the wall stays up
          // over a destination that refuses it while the control that says so
          // has already gone — `SegmentedButton` draws a selection matching no
          // segment as no highlight at all, and asserts nothing.
          if (!allowsWall && _showingWall) _viewportId = _lastViewportId;
        });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // Whose name this is belongs to the caller — see [ShellPage.title].
        // What stays here is that the shell has an app bar at all: it is the
        // app's front door, not one entry in a home list.
        title: Text(widget.title),
        actions: const [ThemeModeButton()],
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final open = _open;
          if (open == null) return _menuOnly();
          final narrow = constraints.maxWidth < ShellPage.narrowBreakpoint;
          return narrow ? _narrow(context, open) : _wide(context, open);
        },
      ),
    );
  }

  /// The menu alone, when the roster supplies no [StageDestination].
  ///
  /// **No stage, no knob region and no tab bar — not empty ones.** An unclaimed
  /// capability draws nothing at all (ADR-0005), and a stage beside a knob
  /// region with nothing in either is chrome announcing two regions the roster
  /// never filled. What is there is already said once, per category, by the
  /// menu.
  Widget _menuOnly() => ShellMenu(
    // The field, not a literal `null`. It is usually null here and it is not
    // only null here: this branch fires whenever `_open` is, which also covers
    // a selected id matching nothing left in the roster — and the menu is the
    // one thing that can say so, by highlighting nothing.
    //
    // Passing the literal would also make the nullable initialiser stop being
    // load-bearing, since nothing on this path would read the field and
    // `Iterable.where` is lazy enough that `_open` does not force it either.
    // Measured: with the literal here, mutating that initialiser back to
    // `.first` left the whole suite green.
    selectedId: _selectedId,
    destinations: _destinations,
    onSelected: _select,
    width: double.infinity,
  );

  Widget _wide(BuildContext context, StageDestination open) {
    return Row(
      children: [
        ShellMenu(
          destinations: _destinations,
          selectedId: _selectedId,
          onSelected: _select,
        ),
        Expanded(child: _stageRegion(context, open)),
        Container(
          width: ShellPage.knobRegionWidth,
          decoration: BoxDecoration(
            border: Border(
              left: BorderSide(color: Theme.of(context).dividerColor),
            ),
          ),
          child: open.knobs(context),
        ),
      ],
    );
  }

  /// One region at a time, chosen by a tab bar.
  ///
  /// Not a narrower version of the wide layout: three columns squeezed into a
  /// phone gives three unusable columns. The regions are the same widgets, shown
  /// one at a time.
  Widget _narrow(BuildContext context, StageDestination open) {
    return DefaultTabController(
      length: 3,
      child: Column(
        children: [
          const TabBar(
            tabs: [
              Tab(text: 'Menu'),
              Tab(text: 'Preview'),
              Tab(text: 'Knobs'),
            ],
          ),
          Expanded(
            child: TabBarView(
              children: [
                ShellMenu(
                  destinations: _destinations,
                  selectedId: _selectedId,
                  onSelected: _select,
                  width: double.infinity,
                ),
                _stageRegion(context, open),
                open.knobs(context),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _stageRegion(BuildContext context, StageDestination open) {
    final scheme = Theme.of(context).colorScheme;
    final source = open.source;
    final showingCode = _showCode && source != null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 10),
          child: Row(
            children: [
              if (source != null)
                SegmentedButton<bool>(
                  showSelectedIcon: false,
                  style: const ButtonStyle(
                    visualDensity: VisualDensity.compact,
                  ),
                  segments: const [
                    ButtonSegment(
                      value: false,
                      label: Text('Preview'),
                      icon: Icon(Icons.play_arrow_outlined, size: 17),
                    ),
                    ButtonSegment(
                      value: true,
                      label: Text('Code'),
                      icon: Icon(Icons.code, size: 17),
                    ),
                  ],
                  selected: {showingCode},
                  onSelectionChanged: (s) =>
                      setState(() => _showCode = s.first),
                ),
              const Spacer(),
              // Source has no viewport, and no fit factor either. Leaving these
              // on screen over a block of code would say the code was being
              // rendered at 390px, which is not a thing that happens.
              if (!showingCode) ...[
                // The wall has no fit control for the same kind of reason. A
                // wall column is whatever a third of this region happens to
                // be, so 1:1 there would be three clipped slices at three
                // arbitrary widths — a control that can only make the view
                // worse is one the toolbar should not be offering.
                if (!_showingWall) ...[
                  Tooltip(
                    message: _fit
                        ? 'Shrink the whole viewport into view'
                        : 'Show real pixels and scroll',
                    child: TextButton.icon(
                      onPressed: () => setState(() => _fit = !_fit),
                      icon: Icon(
                        _fit ? Icons.fit_screen_outlined : Icons.crop_free,
                        size: 18,
                      ),
                      label: Text(_fit ? 'Fit' : '1:1'),
                    ),
                  ),
                  const SizedBox(width: 8),
                ],
                ViewportBar(
                  compact: true,
                  // The destination's call, not the page's — see
                  // `StageDestination.allowsWall`. This was unconditional at
                  // first, and correct only while every destination was a
                  // single subject.
                  //
                  // **Hiding the segment is half of it.** The other half is in
                  // `_select`, which leaves the wall when a destination that
                  // refuses it is opened; hiding a segment out from under the
                  // current selection is silent.
                  //
                  // Data volume is a separate axis and is deliberately not
                  // guarded: a destination can offer a large data set from a
                  // knob pane that sits outside the wall, so the expensive
                  // shape is reachable there too. A subject that builds its
                  // content lazily costs three times what is on screen rather
                  // than three times the data — measured, and judged not worth
                  // binding the knob pane to the shell's viewport state.
                  showsWall: open.allowsWall,
                  selectedId: _viewportId,
                  onChanged: (id) => setState(() {
                    _viewportId = id;
                    if (id != ViewportBar.wallId) _lastViewportId = id;
                  }),
                ),
              ],
            ],
          ),
        ),
        Expanded(
          child: showingCode
              // Beside the frame, not inside it. A `PreviewFrame` would scale
              // the source to whatever factor fits 1440px into the pane and
              // then clip it to a phone, which is unreadable and answers a
              // question nobody asked.
              ? CodePane(assetPath: source)
              : ColoredBox(
                  color: scheme.surfaceContainerHighest,
                  child: _showingWall
                      // The builder, not `open.stage(context)`. Three frames
                      // over one built widget would hand the same subtree to
                      // three places in the tree; the wall wants three
                      // layouts over one set of knobs, which is the destination
                      // built three times.
                      ? DeviceWall(stage: open.stage)
                      : PreviewFrame(
                          spec: ViewportSpec.byId(_viewportId),
                          fit: _fit,
                          child: open.stage(context),
                        ),
                ),
        ),
      ],
    );
  }
}
