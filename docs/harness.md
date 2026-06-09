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
| `/triage-review` -- Claude `/review` + Codex adversarial-review locally on the PR, you pick the fixes | Inferential, **local** (no CI). The primary review path |
| `.github/workflows/pr-review.yml` -- the same semantic review in CI | Inferential, optional remote equivalent (auto-on when API keys exist) |

Local enforcement runs via `lefthook`: lint/type/architecture/escape-hatches on
**pre-commit**; tests + coverage + build on **pre-push** (`task hooks` installs
it). `ci.yml` mirrors it remotely. Frontend line coverage is deliberately **not**
gated -- Bun only counts files touched by tests, so a threshold would give false
confidence; rely on shipped tests + review there.

### 3. The loop (adaptive)
The feedback loop is simply: **a sensor fails loudly -> you fix it.** There is no
separate telemetry pipe -- the sensor output (local and CI) *is* the observability.

When the *same class* of mistake recurs, tighten the harness deliberately: add one
check to `scripts/check-architecture.sh`, or a pattern to `docs/stacks/`. The
harness grows by intent, not by automation.

## Ownership of the SDD architecture gate

The `sdd.md` Architecture Gate (a--p) is split by who enforces it:
- **Automated** (a, b, i, j, k, n + file size): `scripts/check-architecture.sh`.
  Build fails on violation; no manual check.
- **Inferential review** (c, d, e, f, g, h, l, m, o, p): `/triage-review` (local;
  `pr-review.yml` is the optional CI equivalent). These need judgment.

The gate list lives once in `sdd.md`; the sensor and the review prompt reference it.

## Reducing first-move variance
AI weights in-repo code over docs, so a too-empty repo produces high-variance
first generations. The anchor is `docs/stacks/` (canonical patterns) plus the
nearest existing slice: `/impl` mirrors them instead of improvising structure, and
`scripts/check-architecture.sh` fails the build when it drifts.

## Not built (deliberately)
- **Output-quality eval** -- no golden-task regression set yet. Add it when there
  is a real consumer for the data; until then it would be unmeasured complexity.

## References
- Fowler, [Harness Engineering for Coding Agents](https://martinfowler.com/articles/harness-engineering.html)
- LangChain, [The Anatomy of an Agent Harness](https://www.langchain.com/blog/the-anatomy-of-an-agent-harness)
