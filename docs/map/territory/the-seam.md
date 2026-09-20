# The seam

## What it is
Where the gallery meets the subject: the three ports a consumer implements, and the rules
that keep the two apart. This territory owns the *shape* of the crossing — what may be
asked, in which direction, and who owns the state behind it. It does not own what any one
pane draws; the panes are [the settings panel](settings-panel.md) and
[the menu and roster](menu-and-roster.md), and they are the seam's two largest customers.

The vocabulary is [`CONTEXT.md`](../../../CONTEXT.md)'s: Port, Host, Seam, Zone, Barrel.

## Governing decisions
→ [ADR-0001 — the gallery names no subject](../../adr/0001-the-gallery-names-no-subject.md)
→ [ADR-0003 — everything a consumer supplies arrives through three ports](../../adr/0003-three-ports.md)
→ [ADR-0004 — writes across the seam are commands, not values](../../adr/0004-writes-are-commands.md)
→ [ADR-0005 — an unclaimed capability draws nothing at all](../../adr/0005-optional-capabilities-are-silent.md)
→ [ADR-0006 — the barrel is the only public surface](../../adr/0006-the-barrel-is-the-only-public-surface.md)

This is the best-governed territory in the repository, and it is the only one where the
governing set is dense enough that a change here should be assumed to contradict a record
until checked.

## Design model
Three ports and no fourth: `ShellDestinations` for what the menu points at and how long it
lives, `SettingsHost` for a panel over a settings object this package must not name, and
`PresetSummary` for named combinations.

**Members are read off call sites, never designed.** `SettingsHost` carries five members
because five operations were what the three panes actually performed on the subject's
settings class; the doc-comment states that a sixth would be a guess. This is the rule that
keeps the seam from accumulating speculative surface.

**A port exists where a lifetime does, not merely where a value does.**
`ShellDestinations` is a port rather than a `List` parameter because every destination is
backed by a `ChangeNotifier` that something must dispose. Handing the shell a bare list
would move the building out and leave the disposing behind — and a leaked notifier throws
nothing and fails no test, so nothing would report it.

**Optional capability is expressed by a default, not by a flag.** `presets` and
`activePresetId` have defaults on the port, so a host that does not claim them draws
nothing. There is no `hasPresets` to fall out of step.

**Writes are commands.** `setSwitch(id, on)` names an intention; it does not hand back a
mutated settings object. The host is a short-lived value wrapping what it currently owns,
rebuilt whenever that changes — it is not a store.

## Code
`lib/src/shell/shell_destinations.dart` — `ShellDestinations`
`lib/src/settings/settings_host.dart` — `SettingsHost`
`lib/src/settings/setting_spec.dart` — `PresetSummary`
`test/portable_seam_test.dart` — the zone rule, walking the tree rather than trusting intent
`test/settings_host_test.dart` — the port's defaults, including the empty-`presets` default

## Reference behaviour
**None.**

No decision record in this repository carries a named-prior-art section, so nothing here has
a pin into a verified external fact. `settings_host.dart` does reach for one in prose —
*"Prior art in this repository: `RowLocator`"* — and that pin is wrong; see
`## Known holes / open`. Where a comparison would be made, the sources are named in
[`docs/agents/thegraph.md`](../../agents/thegraph.md).

## Cross-cutting invariants
→ [a subject is evidence, never vocabulary](../invariant/subject-is-evidence-never-vocabulary.md)
→ [never hand-maintain a roster](../invariant/never-hand-maintain-a-roster.md)
→ [classify by transitive dependency](../invariant/classify-by-transitive-dependency.md)
→ [a green nobody watched fail is not evidence](../invariant/watched-it-fail.md)

## Blast radius
→ [the menu and roster](menu-and-roster.md) — `ShellDestinations.all` is read on every build;
  changing its shape changes what the menu and the stage walk on the same frame
→ [the settings panel](settings-panel.md) — all five `SettingsHost` members are consumed by
  the three panes, and a sixth member would appear here first
→ [the shell page composition](shell-page-composition.md) — the shell creates and disposes
  the ports with its own state; a lifetime change lands there
→ [the published artifact](published-artifact.md) — a port is public API, so any change is a
  breaking change and reaches the changelog and the version

## Known holes / open
- **A prior-art citation points outside this repository and says otherwise.**
  `settings_host.dart` reads *"Prior art in this repository: `RowLocator`"*. `RowLocator`
  does not exist here; it is `flutter_table_plus`, at `lib/src/widgets/row_locator.dart`.
  The claim is true and the address is wrong, which is the dangerous combination — it reads
  as checkable and is not. Not fixed here: this map does not edit source.
- Nothing decides whether a fourth port is ever permitted, or what would justify one. The
  five-members-read-off-call-sites rule governs members within a port and says nothing about
  the count of ports; ADR-0003 names three without stating the condition for a fourth.
