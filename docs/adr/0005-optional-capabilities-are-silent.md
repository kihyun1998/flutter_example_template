# An unclaimed capability draws nothing at all

Every optional part of a port is opt-in and silent when it is not taken up. `presets` and the two
extras hooks default to empty, and a host that needs none says nothing to get none.

Silence means *no widget*, not an empty one. `PresetBar` over an empty list renders
`SizedBox.shrink()` — not an empty strip with a rule under it, which is chrome announcing a
capability that is not there. A host given no way to apply a preset should report none rather than
offering chips that do nothing.

## Consequences

A port's default is asserted by a fake that overrides only what the port leaves abstract. The
ordinary fake overrode `presets`, which left the empty default asserted **nowhere** — a port that
started handing out presets nobody declared would have shipped. That gap was found by mutating the
rule and watching it fail, not by reading it.

**The same rule applies to the shape of a roster, not only to a port's optional fields.** A
`ShellDestinations` that supplies no `StageDestination` has claimed no stage and no knobs, so
`ShellPage` draws neither region — and no tab bar over them — rather than an empty stage beside an
empty knob pane. The menu alone takes the width. This was found the other way round, by the shell
throwing `Bad state: No element` on such a roster (#10): the requirement was never written down
anywhere, so the decision recorded here had never been read as reaching that far.

**Claimed-and-empty is not the same as unclaimed, and gets the opposite answer.** The port decides
which of the two a thing is. `knobs` is a required field of a `StageDestination`, so a destination
returning an empty widget from it has claimed the knob region, and the region is drawn — the same
way a `PresetBar` over a host that declares one empty preset would still be a bar. This silence is
about what was never supplied, never about what came back empty, and a rule stated only on one side
of that pair is the side it fails on next.
