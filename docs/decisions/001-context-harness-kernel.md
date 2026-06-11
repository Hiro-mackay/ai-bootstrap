# ADR-001: Context-harness kernel — in-code annotations bound to a definitions doc

## Status

Proposed

## Date

2026-06-12

## Context

The technical-semantic harness (lint, type-check, `check-architecture.sh`, ADRs) is strong, but
nothing carries **product/business context** — what a capability is, its domain invariants, the why
a human or agent needs when editing the code — in a form that stays trustworthy and is available at
change-time. Issue #34 consolidates a long exploration (#30–#33) and the airCloset *cortex*
write-ups into a fixed direction. Two prior attempts failed and taught the constraints this ADR
encodes: an auto-merge increment (#32, rejected: false-AUTO is the dominant risk, auto-merge is
product-scale) and a scattered-`why.md` adjacency spike (#33, rejected: no authoritative input,
a half-baked knowledge graph).

cortex's lesson, confirmed by research: the source of truth must be **in-code annotations on the
declaration** (cortex's `@graph-business` JSDoc), any graph must be **derived deterministically**,
and product **requirements** are not managed in a doc — they stay a human gate.

## Decision

Build the **template-scale kernel** of a context harness, with no new infrastructure (POSIX sh +
git, folded into the one custom sensor). Three layers, two of which are new:

1. **Definitions** — `docs/prd.md` (reframed from "Product Requirements" to **Domain Definitions**)
   holds bounded contexts, ubiquitous language, invariants. It is the authoritative *definitions*
   source; it does **not** hold requirements/goals.
2. **Code meaning** — declaration-local annotations are the SSoT: `@context <Name>` (binds to a
   bounded context in `docs/prd.md`), `@business <one line>`, `@invariant <Subject MUST/MUST NOT …>`.
   Carriers: Go doc comments on the aggregate-root entity and usecase command/query; React JSDoc on
   the feature's primary export (documented; not gated in the kernel).
3. **Requirement correctness** — unchanged: a human gate (`/triage-review`). Not built.

Enforcement (`scripts/check-context.sh` via `task arch`): **completeness** (Go domain/usecase
anchors must carry `@context` + `@business`) and **binding** (every code `@context` must match a
context defined in `docs/prd.md`). Surface (`task context`): print a touched anchor's annotations
plus the matching definitions block. The anti-rot guarantee is **co-located + enforced**: the
annotation moves with the declaration and a missing/stale one fails the commit.

Heavy elements (AST extractor, `@business` embeddings, MCP query tools, a persisted graph store,
self-healing, auto-merge, frontend gating) are **delegated** to real projects via a growth ladder
in `docs/context-harness.md`.

## Consequences

### Positive

- Product context is available where/when code is edited, by deterministic adjacency — no retrieval.
- Append-/declaration-bound + enforced resists rot (separate maintained docs drift; research-backed).
- Gives the human `confirm` gate (#31) a written assumption to check a change against.
- Starts vacuous: an empty template with no defined contexts and no domain code is not blocked.

### Negative

- The annotation's *quality* (AI-authored `@business`) rides on the model, not the deterministic gate.
- Kernel completeness is file-level (grep), not declaration-level (the AST upgrade is delegated).
- An invariant in an annotation can disagree with the code with nothing catching it — this kernel
  only surfaces; a `@invariant`-vs-code checker is deliberately deferred (would repeat #32's over-build).

### Neutral

- `docs/prd.md` keeps its filename for historical reasons; the content is definitions.
- Frontend annotations are a documented convention, not a gate, in the kernel.

## Alternatives Considered

### Alternative 1: scattered `why.md` files + adjacency surfacer (#33 spike)

A `why.md` per directory, surfaced by nearest-enclosing match. Rejected: no authoritative input
(context was manufactured at change-time), files scatter, and it is a half-baked knowledge graph
with no derivation or enforcement. Superseded by declaration-local annotations + a definitions doc
+ a deterministic gate.

### Alternative 2: manage product requirements in a doc

A maintained PRD/requirements catalogue as the source of truth. Rejected: cortex does not manage
requirements in a doc, and our own conclusion is that spec/requirement correctness is irreducibly
human. A managed requirements doc would rot (the `sdd.md` banned spec file). `docs/prd.md` holds
*definitions*, not requirements.

### Alternative 3: build the full cortex stack (graph DB + embeddings + MCP)

Rejected for a clone-and-go template: requires infrastructure and scale a fresh clone lacks. Shipped
as the documented growth ladder instead, so a real project grows into it when a trigger fires.
