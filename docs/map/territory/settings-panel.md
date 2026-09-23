# The settings panel

## What it is
A panel drawn from a description, over a settings object this package must not name. It
owns the vocabulary a panel is described in — groups, features, switches, options,
interactions, presets — and the three panes that render it. It holds no settings: which
settings exist is the subject's business and lives beside it.

## Governing decisions
**None.**

Ten public types, the largest count in the repository, and no governing record. Adjacent and
not governing: ADR-0003 decides that the description arrives through a port, ADR-0005 decides
that unclaimed presets draw nothing. Both decide *delivery*; neither decides the model — why
groups are cut by intent, why the hierarchy is the dependency, or why evidence is mandatory.

## Design model
**Types only, no settings.** The split is what lets the same panel draw one package's dozens
of options and the next package's handful.

**Groups are cut by intent, never by what a setting configures.** A feature's own options do
not share an effect — one may build a column while its neighbour builds a theme — so cutting
by effect would tear a feature in half and hide half of it from anyone looking for it.

**The hierarchy is the dependency.** An option is reachable exactly when the feature holding
it is on, so there is no separate `dependsOn` field to drift out of step with the tree.

**A feature without a switch is always live** — a heading over settings that are always on,
not a feature that is off.

**No interaction is asserted without a citation.** A test can insist `evidence` is present;
it cannot read the code the citation points at and confirm the stated effect happens there.
So the rule is drawn exactly where it is enforceable, and the rest is a reviewer's job.

**A label travels with its control**, so a search can read it before the control is built.
That is why `SettingsControl` carries the label rather than the pane composing one.

**A preset earns its name from the interaction it produces**, not from the switches it flips.

## Code
`lib/src/settings/setting_spec.dart` — `SettingGroup`, `SettingFeature`, `Interaction`, `PresetSummary`
`lib/src/settings/settings_host.dart` — `SettingsHost`
`lib/src/settings/settings_controls.dart` — `SettingsControl`
`lib/src/settings/feature_list_pane.dart` — `FeatureListPane`
`lib/src/settings/feature_detail_pane.dart` — `FeatureDetailPane`
`lib/src/settings/feature_search.dart` — `FeatureMatch`
`lib/src/settings/preset_bar.dart` — `PresetBar`
`test/settings_host_test.dart` — the port's contract, including the empty-`presets` default

## Reference behaviour
**None.**

Never compared to a reference. `setting_spec.dart` notes that a spec is held honest by a test
in the app that owns it, which is a consumer-side check rather than a reference comparison.

## Cross-cutting invariants
→ [a subject is evidence, never vocabulary](../invariant/subject-is-evidence-never-vocabulary.md)
→ [a green nobody watched fail is not evidence](../invariant/watched-it-fail.md)
→ [classify by transitive dependency](../invariant/classify-by-transitive-dependency.md)

## Blast radius
→ [the seam](the-seam.md) — all five `SettingsHost` members are consumed here, and a sixth
  would be argued for here first
→ [the shell page composition](shell-page-composition.md) — the panel is drawn in the knob
  region, whose room is the shell's to give
→ [the theme and chrome](theme-and-chrome.md) — controls express state through lightness
  alone, because the chrome carries no hue

## Known holes / open
- **The largest public surface in the package has no governing record at all.** Ten types,
  five of them structural vocabulary a consumer must implement against. A change here is
  currently unreviewable against anything written down.
- `SettingsHost.control` is the member that exists because one pane drew something no
  registry entry could express. Nothing records what that case was, so nothing says when the
  escape hatch is being used correctly.
