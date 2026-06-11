# {{PROJECT_NAME}}

{{PROJECT_DESCRIPTION}}

Shared instructions for all AI agents (Claude Code, Codex, etc.). `CLAUDE.md` imports this file via `@AGENTS.md`. Each agent's personal/global instructions still apply on top of this; do not duplicate them here.

## Tech Stack

- Backend: Go 1.25, Connect-RPC, PostgreSQL, sqlc
- Frontend: React 19, TanStack Router, TanStack Query, connect-query, Tailwind CSS, Bun
- Proto: buf, protobuf

## Guiding Documents

- [Constitution](docs/constitution.md) -- project rules and principles
- [Architecture](docs/architecture.md) -- single source of truth for system design
- [Domain Definitions](docs/prd.md) -- bounded contexts, ubiquitous language, invariants (definitions, not requirements; see #34)
- [Stack Reference](docs/stacks/) -- tech-stack-specific implementation patterns (populated during /setup)
- [Harness Engineering](docs/harness.md) -- how this repo steers AI agents (guides, sensors, the feedback loop)
- [Context Harness](docs/context-harness.md) -- carrying the product *why* (definitions + code annotations) to change-time; kernel + growth path

## Commands

- **Lint**: `task lint` (lint + type-check + architecture fitness)
- **Test**: `task test`
- **Build**: `task build`
- **Proto Generate**: `task proto:gen`
- **Proto Lint**: `task proto:lint`

## Conventions

- Per-change workflow: `gh issue` -> `/impl <issue#>` -> `/ship` -> `/triage-review`
  -> merge. The issue is the context package. **Single source:** `.claude/rules/git-workflow.md`.
- `docs/stacks/` holds the **canonical** implementation patterns. Mirror them and the
  nearest existing slice; do not invent layer structure. This keeps implementations
  consistent across the codebase and across projects built from this template.
- Run project operations through the Taskfile (`task <name>`), never raw tool
  commands -- it owns the correct flags, env loading, and directory context.
- Before writing UI, read `frontend/src/components/primitives/INDEX.md` and reuse/extend
  an existing primitive (`.claude/rules/use-primitives.md`); install missing ones with
  `task react:shadcn -- <name>`. Do not hand-roll what shadcn provides.

## Project Rules

<!-- Add project-specific rules below (injected during /setup) -->

## Domain Context

<!-- Populated during /setup: domain name, core bounded contexts, key invariant -->

## Agent Roles

Substantial changes get a cross-provider review: the implementing agent and a second, different-provider agent.

- **Claude Code** -- primary implementer. Drives the workflow (`/impl`, `/ship`, `/setup`), writes code and tests, makes atomic commits. Claude-specific config lives in `.claude/`.
- **Codex** -- cross-provider reviewer / second opinion on substantial changes. Primary path is **local** via `/triage-review` (Claude `/review` + Codex adversarial-review, you pick the fixes). The CI workflow (`.github/workflows/pr-review.yml`) is the optional remote equivalent. Codex reads this `AGENTS.md` and `~/.codex/config.toml`.

Keep the division stable: one provider implements, the other reviews. Do not let a single provider both write and sign off on substantial changes.
