# AI-Native Development Bootstrap

A GitHub template repository for teams adopting AI-native development practices.
Provides project structure, Spec-Driven Development (SDD) workflow, and multi-agent
integration (Claude Code + Codex) out of the box.

## AI Agents

- **Instructions**: `AGENTS.md` is the shared source of truth read by every agent.
  `CLAUDE.md` imports it via `@AGENTS.md`; Codex reads `AGENTS.md` directly.
- **Roles**: Claude Code is the primary implementer and drives the SDD workflow;
  Codex provides a cross-provider review on substantial changes. See the
  Agent Roles section in `AGENTS.md`.
- **Enforcement split**: deterministic architecture gates (layering, barrels,
  cross-feature imports, domain tags, manual queryKey, store state, file size) are
  enforced by `scripts/check-architecture.sh` (`task arch`, lefthook). The
  semantic gates that need judgment are reviewed by `/triage-review`.
- **Review**: `/triage-review` runs Claude + Codex on the PR **locally** (no CI) and
  you pick the fixes -- the primary path. `.github/workflows/pr-review.yml` is the
  **optional** CI equivalent (dormant until an API key secret exists; delete it if
  you review locally only).

## Prerequisites

- [Go](https://go.dev/) 1.25+
- [Bun](https://bun.sh/) 1.3+
- [buf](https://buf.build/) (Protocol Buffers code generation)
- [Task](https://taskfile.dev/) (task runner)
- [Podman](https://podman.io/) + podman-compose (container runtime)
- [sqlc](https://sqlc.dev/) (SQL code generation) -- installed via `task go:install-tools`
- [golang-migrate](https://github.com/golang-migrate/migrate) -- installed via `task go:install-tools`

## Getting Started

```bash
git clone <your-repo-url> && cd <your-repo>
task setup   # .env, DB, migrations, codegen, dependencies
task dev     # Start Go + React dev servers
```

<details>
<summary>What <code>task setup</code> does</summary>

1. Copy `.env.example` to `.env`
2. Install Go tools (air, sqlc, migrate)
3. Install git hooks (`lefthook`) so lint, type-check, and architecture checks run on every commit
4. Start PostgreSQL (`podman compose up -d`)
5. Run database migrations
6. Generate code from proto files (`buf generate`)
7. Generate Go code from SQL queries (`sqlc generate`)
8. Install frontend dependencies (`bun install`)

Each step can also be run individually -- see [Available Tasks](#available-tasks).
</details>

## Development Workflow

The spec is not a document -- WHAT lives in the issue, HOW lives in the PR, and the
link between them lives in the code (tests + comments). Per change:

1. Open a GitHub issue: WHAT + Why (label `type` + `area`)
2. `/impl <issue#>` -- research, plan (you approve), implement to green
3. `/ship` -- quality gates, push, open the PR
4. `/triage-review` -- Claude (+ Codex) review the PR, you pick the fixes
5. Merge (Rebase and merge)

See [`.claude/rules/git-workflow.md`](.claude/rules/git-workflow.md).

## Project Structure

```
.
├── AGENTS.md                        # AI agent project config (shared source of truth)
├── CLAUDE.md                        # Imports AGENTS.md for Claude Code
├── Taskfile.yml                     # Root orchestrator (task dev/test/lint/ci)
├── compose.yml                      # Podman compose (PostgreSQL)
├── .env.example                     # Environment variable template
├── proto/                           # Protocol Buffers schema definitions
│   └── {service}/v1/{service}.proto # Service definitions
├── buf.yaml / buf.gen.yaml          # Buf module + code generation config
├── backend/                         # Go backend (Connect RPC + DDD)
│   ├── Taskfile.yml                 # Go tasks (go:dev, go:build, go:test, go:lint)
│   ├── cmd/server/main.go           # Entry point + wiring + graceful shutdown
│   ├── internal/
│   │   ├── gen/                     # (generated) protobuf + sqlc code
│   │   ├── domain/                  # Entities, value objects, repository interfaces
│   │   ├── usecase/                 # Application logic (commands, queries)
│   │   ├── infrastructure/          # Database, cache adapters
│   │   └── interface/               # Connect RPC handlers, interceptors
│   ├── migrations/                  # SQL migration files
│   └── pkg/                         # Shared packages (logger, config)
├── frontend/                        # React frontend (Bun + Tailwind CSS v4)
│   ├── Taskfile.yml                 # React tasks (react:dev, react:build, react:test)
│   └── src/
│       ├── gen/                     # (generated) protobuf TypeScript types
│       ├── app/                     # Router, QueryClient, TransportProvider
│       ├── components/              # Shared UI (layout, primitives)
│       ├── features/                # Feature modules (pages, components, api)
│       ├── lib/                     # Shared infrastructure (transport, validation)
│       ├── stores/                  # Zustand stores (client-only state)
│       └── test/                    # Test setup and utilities
└── docs/
    ├── constitution.md              # Project rules and principles
    ├── architecture.md              # System design (source of truth)
    ├── domain-definitions.md        # Domain definitions (bounded contexts, invariants)
    ├── harness.md                   # How the AI harness works (guides, sensors, the loop)
    ├── stacks/                      # Stack reference architecture (canonical patterns)
    └── decisions/                   # Architecture Decision Records
```

## Available Tasks

| Command | Description |
|---|---|
| `task setup` | Initial project setup (run once after cloning) |
| `task dev` | Start all development servers (Go + React) |
| `task test` | Run all tests |
| `task lint` | Run all linters |
| `task check` | Static guards (proto lint, lint, tidy, type-check, architecture) |
| `task proto:gen` | Generate code from proto files |
| `task proto:lint` | Lint proto files |
| `task logs:db` | Follow PostgreSQL logs |
| `task logs:backend` | Follow Go backend logs |
| `task logs:frontend` | Follow React frontend logs |
| `task infra:up` | Start PostgreSQL |
| `task infra:down` | Stop PostgreSQL |
| `task infra:reset` | Stop PostgreSQL and remove volumes |
| `task go:dev` | Start Go server with hot-reload |
| `task go:test` | Run Go tests |
| `task go:lint` | Run Go linter |
| `task go:migrate:up` | Run database migrations |
| `task go:migrate:down` | Rollback last migration |
| `task go:sqlc:generate` | Generate Go code from SQL queries |
| `task react:dev` | Start React dev server |
| `task react:test` | Run React tests |
| `task react:lint` | Run React linter |
| `task react:build` | Build React for production |
| `task react:type-check` | TypeScript type check |

## Tech Stack

**Backend**: Go, Connect RPC, Domain-Driven Design, PostgreSQL, sqlc, golang-migrate

**Frontend**: React 19, Bun, Tailwind CSS v4, TanStack Router, TanStack Query, connect-query, Zod, Zustand

**Tooling**: Protocol Buffers (buf), Task, Podman, Biome (lint/format)

## Spec-Driven Development

SDD here does **not** mean accumulating spec documents -- those rot the moment they
are written and drift from the code. Instead:

- **WHAT (+ Why)** lives in the GitHub issue
- **HOW** is realized in the PR (code + atomic commits)
- The **spec** (problem, user stories, acceptance criteria) is defined in plan mode and expressed as **tests**, not document files
- The **link** between intent and code lives in the codebase: tests, and comments where the *why* is non-obvious

Run it with `/impl <issue#>`. See [`.claude/rules/sdd.md`](.claude/rules/sdd.md)
and [`docs/harness.md`](docs/harness.md).

## Links

- [Constitution](docs/constitution.md)
- [Architecture](docs/architecture.md)
- [Domain Definitions](docs/domain-definitions.md)
- [Harness Engineering](docs/harness.md)
- [Git Workflow](.claude/rules/git-workflow.md)
- [ADR Template](docs/decisions/000-template.md)
