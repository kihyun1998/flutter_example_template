# Flutter Example Template

A reusable starting point for Flutter package projects. Downstream repos are created from this
template, so anything defined here is inherited by every project that starts from it.

## Language

_No domain terms yet._

`lib/` now holds a transplanted example-app shell — 3,758 lines over five areas — so the domain
exists in the code and not yet in this file. The vocabulary is already earned rather than waiting to
be invented: the words the code itself uses are *zone*, *barrel*, *port*, *destination*, *host*,
*stage*, *knobs*, *device wall*, *recipe* and *scenario*.

**Read `docs/inherited-decisions.md` before filling this in.** It carries what the transplant could
not: the alternatives that were tried, measured and refused, and eight dated measurements. It is raw
material for this file and for `docs/adr/`, and is meant to be consumed and deleted rather than
kept.

Add terms here as the domain emerges — one or two sentences each, defining what a thing **is** rather
than what it does, with rejected synonyms under `_Avoid_`:

```md
**Order**:
A customer's request for goods, accepted and awaiting fulfilment.
_Avoid_: Purchase, transaction
```

Only concepts specific to this project belong here. General programming concepts (timeouts, error
types, utility patterns) do not, however heavily they are used.

See `docs/agents/domain.md` for how the engineering skills consume this file, and `docs/adr/` for
recorded decisions.
