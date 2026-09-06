# Everything a consumer supplies arrives through three ports

A consumer supplies what the menu points at, what a settings panel contains, and the named
combinations offered above it — through `ShellDestinations`, `SettingsHost` and `PresetSummary`.
**Every member on each was read off a real call site rather than designed.** When a port grew a
member nobody was calling, it was not added.

## Considered options

**A bare `List<ShellDestination>` instead of `ShellDestinations`.** Rejected because the port
carries a *lifetime*, not just a set. Every destination that does anything is backed by a
`ChangeNotifier` the stage and the knob pane both read, and something has to dispose them. The
shell's state built that list and disposed those notifiers; handing it a list instead moves the
building out and leaves the disposing behind — the shape a half-repair always takes. A leaked
notifier throws nothing and fails no test.

**Carrying `featuresOn` on `PresetSummary`.** Rejected because the bar never reads it. A preset in
the subject is a set of that package's switch ids; the bar draws a chip and a line of guidance and
hands an id back. Carrying the set across the seam would put a consumer's vocabulary in this package
for the sake of a field nothing here looks at.

## Consequences

`SettingsHost` has five members because the panes did five things with the settings class they were
typed on: walk the spec, read a switch, write a switch, build one control, and draw something no
registry entry could express. A sixth would be a guess.

An implementation is an ordinary short-lived value wrapping the current settings and the callback
that replaces them. It is not a store and holds no state of its own.
