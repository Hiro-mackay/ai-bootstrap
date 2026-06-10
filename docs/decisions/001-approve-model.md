# ADR-001: Approve model — route changes by oracle × confinement

## Status

Proposed

## Date

2026-06-10

## Context

The harness had guides (feedforward) and sensors (feedback) but no statement of *when
sensor output is sufficient to ship*. Every change went through the same human gate:
`/triage-review` dumped all findings to the user, who then merged by hand — the same
attention spent on a typo as on a domain change. Issue #30 proposed an autonomous
review *loop* to close this, but shaping it (#31) showed the loop re-derives the
approval criteria every pass, so it cannot converge cheaply and its cost never
amortizes. The real question is upstream: what does "approve" mean, and which changes
can the harness approve without a human?

## Decision

Model "approve" as a risk judgment (`P(wrong) × cost(wrong) < threshold`) and encode
the variable bar as two gates, computed deterministically by
`scripts/classify-change.sh` into `auto / confirm / decide`:

1. **Oracle** — *mechanizable* (a test/check confirms) advances; *human-held* (a domain
   assumption) → `confirm`; *none* (a trade-off) → `decide` + ADR. The `sdd.md` ADR
   triggers are the no-oracle class.
2. **Confinement** — effect local and observable (not diff size). Confined +
   mechanizable + evidence-complete → `auto`; unconfined → a human.

`/triage-review` routes by class: a green `auto` skips the cross-provider review and
squash-auto-merges; `confirm` leads with the domain assumption; `decide` requires an
ADR. `/impl` requires failing-test-first for fixes so the `auto` evidence is complete
by construction. The classifier is biased to a human — every ambiguity falls to
`confirm`, and `feat` is never `auto`.

This first increment is deliberately narrow (one classifier + routing); human-oracle
*detection*, a general inferential classifier, and the ratchet promotion rule are
deferred (#31 Q2/Q3/Q5).

## Consequences

### Positive

- The human gate shrinks toward its irreducible core (spec correctness); the auto-class
  merges with zero human attention.
- Every fix ships a permanent regression guard, so #30's "catches regressions in its own
  fixes" becomes a free, deterministic `task test` guard instead of an LLM loop.
- The expensive Codex pass no longer runs for confined, mechanizable changes.

### Negative

- The classifier is a new failure surface; the dangerous error is *false-auto*
  (a change needing a human classified `auto`). Mitigated by defaulting to `confirm`
  and gating auto-merge on all deterministic checks being green.
- The `auto` evidence inherits the test suite's blind spots ("behavior preserved" is
  proxied by "tests still pass").

### Neutral

- `confirm`/`decide` changes are no faster — `decide` gains ADR ceremony.
- Coverage of the `auto` class grows as a ratchet, never to 100%.

## Alternatives Considered

### Alternative 1: Converge-to-approve review loop (#30)

Loop cross-provider review → fix → re-review until both approve. Rejected: it
re-derives approval criteria each pass (no finite obligation set → no cheap
convergence), pays full cross-provider cost per iteration, and has no home under this
model — redundant in the auto-class, unable to replace the human in confirm/decide.

### Alternative 2: Fold confinement into `check-architecture.sh`

Add the classification to the existing fitness script. Rejected: that script is a
pass/fail *gate* (exits 1 on violation); classification is a *categorizer* (always
exits 0, emits a class). Mixing the two muddles both output contracts.
