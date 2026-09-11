# The palette is not a port, until a second consumer asks

The chrome font is a parameter ([ADR-0008](0008-the-chrome-font-is-a-parameter.md)) and the colours
are not. `exampleTheme` seeds `DynamicSchemeVariant.monochrome` from black and derives everything
from it, and it stays that way.

## What the achromatic chrome buys

**The only colour anywhere on screen is the one the subject is wearing.** That is what makes "this
colour is something you set" need no caption, and it is the whole reason a gallery that names no
subject can still show one. A chrome with an accent of its own puts two colours on screen and the
reader has to be told which is which.

The cost is real and is already written down where it is paid: state has nowhere to go but value,
so a switch, a selected sidebar row and a slider all express themselves through lightness alone.
`error` is the one exemption, because a failure that reads as a shade of grey is not a failure
anyone notices.

## Why not take the parameter anyway

**It is cheap, and that is the trap.** `exampleTheme` is a pure function of its arguments, so a seed
argument would reach the 52 sites across nine files that read from the scheme without any of them
being touched. An hour's work, and nothing in the tree would resist it.

What it would cost is the property above, which no signature records and no test holds. And nobody
has asked: there is one consumer of this package and it is this repository's own `example/`.
[ADR-0010](0010-two-gates-declined.md) declined two gates on the same ground — *a rare papercut
whose automation should wait for a second occurrence rather than a first scare* — and a
generalisation built for a consumer who does not exist is that shape exactly.

## What would change the answer

A second consumer that wants its own identity in the chrome, and says so. Then this is the fourth
port, and the thing to get right is not the parameter — that part is easy — but shaping it so
that taking it does not cost the reason the chrome is achromatic in the first place. A seed that
only tints surfaces, an opt-in that the demo modes ignore, a scheme accepted whole: those are the
question, and they are worth asking with a real consumer's constraint in hand rather than
without.

**Half of that trigger has since arrived, and it is recorded here rather than left to be
rediscovered.** The sentence above — *"there is one consumer of this package and it is this
repository's own `example/`"* — stopped being true in September 2026, when
`kihyun1998/flutter_dropdown_button` adopted the shell against 0.1.0 and filed #10 and #11 from
doing so. The decision is unchanged: that consumer has asked for neither a palette nor an identity
in the chrome, and the trigger is a second consumer *that says so*. What has gone is the ground of
"a consumer who does not exist". Re-proposing the port still argues against this record; it no
longer argues against a count.

## Consequences

**Recorded rather than left open**, because "surely the palette should be configurable too" is the
next sentence after reading ADR-0008, and the tree shows a hardcoded seed without showing what it is
buying. Anyone re-proposing it is re-proposing against this, not against silence.
