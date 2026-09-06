# Writes across the seam are commands, not values

`setSwitch(id, on)` and `applyPreset(id)` — never "here is the new settings object". A pane says
what it wants done and the host decides how.

The panes originally computed the new settings object and handed it back through a callback.
Constructing that value is exactly the step that requires knowing the type, which is the one thing
this package must not know. Who applies a change, and how, belongs to the side that owns the
settings.

## Consequences

Whether a hand-edit clears the active preset is answerable only by the host, so `activePresetId`
lives there too. It is a question about what a preset *means*, and the bar has no standing to answer
it.
