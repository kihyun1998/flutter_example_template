# CLAUDE.md

## Agent skills

### Issue tracker

Issues live in this repo's GitHub Issues (`github.com/kihyun1998/flutter_example_template`), operated via the `gh` CLI. See `docs/agents/issue-tracker.md`.

### Triage labels

The five canonical triage roles, each using its default label string (`needs-triage`, `needs-info`, `ready-for-agent`, `ready-for-human`, `wontfix`). See `docs/agents/triage-labels.md`.

### Domain docs

Single-context: one `CONTEXT.md` and one `docs/adr/` at the repo root. See `docs/agents/domain.md`.

### The map

Territory notes and cross-cutting invariants live in `docs/map/`. Entry point:
[`docs/map/README.md`](docs/map/README.md). Read the territory a change touches before
designing it, and read its blast radius as a checklist.

### Comments

A comment says what the code is. Why it is this way, what it deliberately leaves out, the
trap and the measured value go to the territory note under `docs/map/`; history goes to the
commit message.
