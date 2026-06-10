# Harness Engineering

How this repo steers AI agents to produce correct, consistent work. `Agent =
Model + Harness`; the harness is everything around the model. The design favors a
few strong, deterministic mechanisms over many weak ones: every part either
changes what the agent generates or reliably catches a mistake. If a mechanism
does neither, it is removed.

## The model

Every control is either a **guide** (feedforward -- shapes output before the
agent acts) or a **sensor** (feedback -- catches mistakes after). Sensors are
**computational** (deterministic, run on every change) or **inferential**
(judgment, run selectively). The strongest guide is executable; the strongest
sensor is deterministic.

## When is it approvable? (the approve model)

Guides and sensors shape and catch, but neither says *when the sensor output is
enough to ship*. That is a risk judgment: `P(wrong) × cost(wrong) < threshold`.
Coverage, naming, behavior are evidence that lowers `P(wrong)`, not approval itself.
The bar is **variable** -- set by how much you must hold in your head to be confident
(confinement), not by diff size. The harness encodes this as two gates (#31):

1. **Oracle** -- does a verification oracle exist, and where? *Mechanizable* (a
   test/check confirms) → gate 2. *Human-held* (a domain assumption only a person can
   confirm) → a human confirms. *None* (a trade-off with no right answer) → a human
   decides + ADR. The `.claude/rules/sdd.md` ADR triggers **are** the no-oracle class.
2. **Confinement** -- is the effect local and observable? Confined + evidence-complete
   → **auto-mergeable**; unconfined → a human, regardless of size.

`scripts/classify-change.sh` computes this into `auto / confirm / decide`, and
`.claude/rules/git-workflow.md` grants auto-merge to a green `auto`. Auto-merge is
**routing, and a ratchet** -- it grows one encoded pattern at a time and never reaches
100%, because spec-correctness (is the intent itself right) is irreducibly human. The
goal is to shrink the human gate to *that* core plus domain-assumption confirmation
and trade-off decisions, not to remove it.

## Three pillars

### 1. Guides (feedforward)
| Guide | Strength |
|---|---|
| `docs/stacks/` -- canonical implementation patterns | Reference code all new code mirrors. The primary anchor against drift |
| `components/primitives/INDEX.md` + `.claude/rules/use-primitives.md` -- UI primitive catalog | Text catalog the agent reads before writing UI (it can't see Storybook) |
| `AGENTS.md` (+ `CLAUDE.md` import) -- stack, commands, conventions | Always-loaded instructions |
| `docs/constitution.md` -- principles | Project law |
| Orchestration (`/impl`, `/ship`, `/triage-review`, `.claude/rules/git-workflow.md`) -- the per-change flywheel | The issue is the context package; plan approval is the one human stop |
| SDD (`.claude/rules/sdd.md`) -- intent before code | The spec lives in the issue + plan mode + tests, never in spec files (they rot) |

### 2. Sensors (feedback)
| Sensor | Kind |
|---|---|
| `task lint` / `task test` / type-check / `buf lint` | Computational, generic |
| Escape-hatch bans -- `any` (biome `noExplicitAny: error`), TODO/FIXME + lint-suppression (`godox`/`nolintlint` for Go, `check-architecture.sh` for TS) | Computational. Closes the "quiet workaround" loopholes |
| `scripts/check-architecture.sh` -- layering, no-barrel, no cross-feature imports, file size, no domain serialization tags, no manual queryKey, no server state in stores, no escape hatches | Computational, architecture-specific. The one custom sensor |
| `scripts/check-coverage.sh` -- domain test coverage >= 80% (skips until domain logic exists) | Computational. Domain only; usecase/infra covered by shipped tests + review |
| `scripts/classify-change.sh` -- routes the diff into auto/confirm/decide by oracle × confinement (#31) | Computational categorizer (not a gate, exits 0). Decides which class a change is, hence whether a human is required |
| `/triage-review` -- Claude `/review` + Codex adversarial-review locally on the PR, you pick the fixes | Inferential, **local** (no CI). The primary review path |
| `.github/workflows/pr-review.yml` -- the same semantic review in CI | Inferential, optional remote equivalent (auto-on when API keys exist) |

#### Where each guard runs -- one definition, one home

The trap is the same check living in three places (lefthook, `ci.yml`, the
Taskfile) that drift apart. So: **every computational guard is defined exactly
once, as a Taskfile target. lefthook and CI never inline a raw check command --
they call `task <name>`.** A guard has one definition and one home; the chance a
guard is bypassed is a reason to make it reliable, never a reason to copy it as a
"net" or to water it down.

This repo is a personal, AI-native template, not a multi-team codebase where
contributors are untrusted. So local is the primary gate and remote is its
complement, not its duplicate:

| Concern | Home | What runs |
|---|---|---|
| Per-change correctness | **lefthook + the `/impl`,`/ship` agent loop** (local) | pre-commit: `proto:lint`, `go:lint` (govet + staticcheck deprecation), `go:tidy:check`, `react:lint`, `react:type-check`, `arch`. pre-push: `go:test`, `coverage`, `react:test` |
| "Does the committed state build from clean?" | **`ci.yml`** (remote, per-push) | build only -- `go build ./...` + frontend build. The one thing local incremental state can mask. No lint/test/audit here |
| Supply-chain / security | **`security-audit.yml`** (scheduled + manual) | gitleaks, dependency vuln (govulncheck), CodeQL. Dependency vulns are DB-driven (disclosed independent of your code), so the cadence is weekly, not per-push; run `task go:vuln` on dep bumps for an early signal |
| Semantic review | `/triage-review` (local) / `pr-review.yml` (optional remote) | inferential, judgment |

Why no remote re-run of lint/test: doing it both locally and remotely on every
push is wasted compute on a resource-limited runner, and "local can be skipped"
is not license to weaken the local guard -- `task hooks` installs lefthook and the
agent loop runs `task check` explicitly. Frontend line coverage is deliberately
**not** gated -- Bun only counts files touched by tests, so a threshold would give
false confidence; rely on shipped tests + review there.

### 3. The loop (adaptive)
The feedback loop is simply: **a sensor fails loudly -> you fix it.** There is no
separate telemetry pipe -- the sensor output (local and CI) *is* the observability.

When the *same class* of mistake recurs, tighten the harness deliberately: add one
check to `scripts/check-architecture.sh`, or a pattern to `docs/stacks/`. The
harness grows by intent, not by automation.

## Ownership of the SDD architecture gate

The `sdd.md` Architecture Gate (a--p) is split by who enforces it:
- **Automated** (a, b, i, j, k, n + file size): `scripts/check-architecture.sh` via
  `task arch`, enforced locally (pre-commit + the agent loop). A violation blocks the
  commit; no manual check.
- **Inferential review** (c, d, e, f, g, h, l, m, o, p): `/triage-review` (local;
  `pr-review.yml` is the optional CI equivalent). These need judgment.

The gate list lives once in `sdd.md`; the sensor and the review prompt reference it.

## Reducing first-move variance
AI weights in-repo code over docs, so a too-empty repo produces high-variance
first generations. The anchor is `docs/stacks/` (canonical patterns) plus the
nearest existing slice: `/impl` mirrors them instead of improvising structure, and
`scripts/check-architecture.sh` (via `task arch`, on pre-commit) blocks the commit
when it drifts.

## Not built (deliberately)
- **Output-quality eval** -- no golden-task regression set yet. Add it when there
  is a real consumer for the data; until then it would be unmeasured complexity.

## References
- Fowler, [Harness Engineering for Coding Agents](https://martinfowler.com/articles/harness-engineering.html)
- LangChain, [The Anatomy of an Agent Harness](https://www.langchain.com/blog/the-anatomy-of-an-agent-harness)
