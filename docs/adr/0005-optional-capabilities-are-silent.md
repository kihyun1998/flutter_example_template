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
