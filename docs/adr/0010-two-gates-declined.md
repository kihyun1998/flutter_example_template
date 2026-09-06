# Two gates considered and declined

**A repeatable extraction probe** — some check that re-runs the portability analysis and reports how
much of the tree could still move. Declined on two grounds: it duplicates what
`portable_seam_test.dart` and `settings_host_test.dart` already assert, and it cannot see runtime
portability anyway. The original was green while a font was missing.

**A README link checker.** A rare papercut whose automation should wait for a second occurrence
rather than a first scare.

## Consequences

Both are cheap to add later and neither is load-bearing. They are recorded because a gate that
sounds obviously worth having gets proposed again, and the reason it was not taken is not visible
from the tree.
