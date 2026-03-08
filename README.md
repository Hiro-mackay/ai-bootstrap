# AI-Native Development Bootstrap

A GitHub template repository for teams adopting AI-native development practices.
Provides project structure, Spec-Driven Development (SDD) workflow, and Claude Code integration out of the box.

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
3. Start PostgreSQL (`podman compose up -d`)
4. Run database migrations
5. Generate code from proto files (`buf generate`)
6. Generate Go code from SQL queries (`sqlc generate`)
7. Install frontend dependencies (`bun install`)

Each step can also be run individually -- see [Available Tasks](#available-tasks).
</details>

## Development Workflow

1. Run `/new-spec` in Claude Code to create a feature spec
2. Review and approve the spec, plan, and task breakdown
3. Implement task by task with atomic commits
4. Run `task check` to verify linting, types, and build
5. Run `task test` to ensure all tests pass

## Project Structure

```
.
├── CLAUDE.md                        # AI assistant project config
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
    ├── prd.md                       # PRD (domain boundaries)
    ├── stacks/                      # Stack reference architecture
    ├── decisions/                   # Architecture Decision Records
    └── specs/                       # Feature specs (SDD workflow)
```

## Available Tasks

| Command | Description |
|---|---|
| `task setup` | Initial project setup (run once after cloning) |
| `task dev` | Start all development servers (Go + React) |
| `task test` | Run all tests |
| `task lint` | Run all linters |
| `task check` | Full check (proto lint, format, lint, type-check, build) |
| `task ci` | Full CI pipeline |
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

SDD ensures every feature starts with a written specification:

1. **Spec** -- Define the problem, user stories, and acceptance criteria
2. **Plan** -- Map out components, architecture decisions, and risks
3. **Tasks** -- Break work into small, dependency-ordered tasks
4. **Implement** -- Build task by task, committing atomically
5. **Verify** -- Confirm all acceptance criteria pass

Run `/new-spec` in Claude Code to start this workflow.
See the [SDD Templates Guide](docs/specs/_templates/README.md) for details.

## Links

- [Constitution](docs/constitution.md)
- [Architecture](docs/architecture.md)
- [PRD](docs/prd.md)
- [ADR Template](docs/decisions/000-template.md)
- [Spec Template](docs/specs/_templates/spec.md)
- [SDD Templates Guide](docs/specs/_templates/README.md)
