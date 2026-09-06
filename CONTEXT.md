# Flutter Example Template

A reusable starting point for Flutter package projects. Downstream repos are created from this
template, so anything defined here is inherited by every project that starts from it.

## Language

_No domain terms yet._

This repo is currently the unmodified `flutter create --template=package` scaffold: the only code is
the placeholder `Calculator` class, which is not a domain concept and will be removed.

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
