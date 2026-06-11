# Context Harness — growth path

The technical-semantic harness (lint, type-check, `check-architecture.sh`) keeps code *correct*.
The **context harness** keeps the product *why* — what a capability is, its domain invariants —
available and trustworthy when code is edited, by an engineer or an agent. This template ships the
**kernel**; grow toward the full shape (the airCloset *cortex* architecture) only when a trigger
fires. Background, the rejected alternatives, and the journey that shaped this live in #34.

## What the kernel is (shipped)

- **Definitions** live in `docs/prd.md` (a domain-definitions doc): bounded contexts, ubiquitous
  language, invariants. **Not** requirements — those stay a human judgment at change-time.
- **Code meaning** lives in declaration-local annotations (`docs/stacks/*`): `@context <Name>`,
  `@business <one line>`, `@invariant <Subject MUST/MUST NOT …>`. The SSoT; moves with the code.
- **Enforcement** — `scripts/check-context.sh` (via `task arch`, on pre-commit and the `/impl`
  loop): completeness (Go domain/usecase anchors carry `@context` + `@business`) and binding
  (every code `@context` matches a context in `docs/prd.md`). Anti-rot = co-located + enforced.
- **Surface** — `task context` prints a touched file's annotations + the matching `docs/prd.md`
  block; wired into `/impl` Research and `/triage-review`.

Coverage grows with the project: an empty clone with no defined contexts and no domain code passes
vacuously, so development can start immediately. The gate bites only where a real context exists.

### Why this shape

- **Annotations on the declaration, not a separate doc.** They move with the code under refactor and
  are enforced, so they cannot silently drift. A scattered per-feature `why.md` (an earlier rejected
  spike) had neither property.
- **Not a banned spec file** (`.claude/rules/sdd.md` forbids per-feature spec/plan docs because they
  rot). The annotations describe *intent*, not implementation; `docs/prd.md` holds *definitions*,
  scoped to the bounded context, not a per-PR requirements catalogue.
- **Requirements are not managed here.** Spec correctness is a human judgment at change-time
  (`/triage-review`); the harness carries definitions + code meaning, not product requirements.

### Known limitations (kernel)

- **Completeness is file-level, not declaration-level.** A Go anchor file passes if `@context` +
  `@business` appear *anywhere* in it, so an unannotated aggregate root alongside an annotated
  secondary declaration is not caught. Declaration-level checking is the stage-2 AST upgrade.
- The kernel **surfaces** an `@invariant` but does not verify the code obeys it (also stage-2+).

## The ladder (delegated — build in your project, not the template)

Each stage has an explicit trigger. Do not build ahead of the trigger.

| Stage | What | Trigger to add it |
|---|---|---|
| 1. Kernel | grep/sed extraction, literal `@context` binding, prd.md definitions | shipped |
| 2. AST extraction | `go/ast`+`go/doc` and ts-morph instead of grep | grep gives false positives/negatives as annotation count grows |
| 3. Embeddings | embed `@business`; semantic "where does X live" search | literal-name lookup stops scaling across many contexts |
| 4. MCP query tools | semantic search / BFS graph traversal exposed to agents | agents need to traverse context↔code edges, not just read one record |
| 5. Persisted graph store | nodes/edges in a DB (cortex uses BigQuery) | the derived index is too big to recompute on demand |

Everything from stage 2 on requires infrastructure a fresh clone lacks (AST tooling, an embedding
model, a running MCP server, a database). That is why the template stops at stage 1 and documents
the rest here.

## Deliberately not in scope

Auto-merge and automated self-healing (cortex runs them internal-only; this template keeps merge a
human call and review manual — see #34). A `@invariant`-vs-code consistency checker is also a later
increment: the kernel **surfaces** the invariant; verifying code obeys it is stage-2+ work.
