# AI-Native Development Bootstrap

A GitHub template repository for teams adopting AI-native development practices.
Provides project structure, Spec-Driven Development (SDD) workflow, and Claude Code integration out of the box.

## What This Template Provides

- **CLAUDE.md** -- AI assistant configuration scoped to your project
- **Constitution** -- Non-negotiable project rules (specs before code, no secrets, etc.)
- **PRD template** -- Domain boundaries, ubiquitous language, and bounded contexts
- **Architecture doc** -- Single source of truth for system design
- **SDD workflow** -- Templates for specs, plans, and task breakdowns
- **SDD skill** -- Auto-loaded Claude skill encoding the full SDD workflow
- **ADR template** -- Architecture Decision Records for tracking decisions
- **Monorepo skeleton** -- `backend/` (Go Connect RPC + DDD) + `frontend/` (React Bun + TanStack Router + connect-query) with Taskfile orchestration
- **Proto-first API** -- Protocol Buffers schema in `proto/`, code generation via `buf generate`
- **Claude commands** -- `/new-spec` for feature specs, `/adr` for architecture decisions, `/setup` for project initialization

## Quick Start

1. Click **"Use this template"** on GitHub to create your repo
2. Clone your new repo
3. Run `/setup` in Claude Code to configure project name, stack, architecture, and PRD
4. Run `task proto:gen` to generate code from proto files
5. Run `task dev` to start both Go and React development servers
6. Review `docs/constitution.md`: customize rules for your team
7. Start building: run `/new-spec` in Claude Code to create your first feature spec

## Project Structure

```
.
├── CLAUDE.md                        # AI assistant project config
├── Taskfile.yml                     # Root orchestrator (task dev/test/lint/ci)
├── .env.example                     # Environment variable template
├── proto/                           # Protocol Buffers schema definitions
│   └── {service}/v1/{service}.proto # Service definitions
├── buf.yaml                         # Buf module config
├── buf.gen.yaml                     # Code generation config
├── backend/                         # Go backend
│   ├── Taskfile.yml                 # Go tasks (go:dev, go:build, go:test, go:lint)
│   ├── cmd/
│   │   └── server/main.go          # Entry + wiring + mux + graceful shutdown
│   ├── internal/                    # Internal packages (DDD layers)
│   │   ├── gen/                     # (gitignored) protobuf generated code
│   │   ├── domain/                  # Entities, value objects, repository interfaces
│   │   ├── usecase/                 # Application logic (commands, queries)
│   │   ├── infrastructure/          # Database, cache adapters
│   │   └── interface/               # Connect RPC handlers, interceptors
│   └── pkg/                         # Shared packages (logger, config)
├── frontend/                        # React frontend
│   ├── Taskfile.yml                 # React tasks (react:dev, react:build, react:test, react:lint)
│   └── src/                         # React source
│       ├── gen/                     # (gitignored) protobuf generated code
│       ├── app/                     # Router, QueryClient, TransportProvider
│       ├── components/              # Shared UI (layout, primitives)
│       ├── features/                # Feature modules (pages, components, api, hooks)
│       ├── lib/                     # Shared infrastructure (transport, validation)
│       ├── stores/                  # Zustand stores
│       └── test/                    # Test setup and utilities
├── docs/
│   ├── constitution.md              # Project rules and principles
│   ├── architecture.md              # System design (source of truth)
│   ├── prd.md                       # PRD (domain boundaries)
│   ├── stacks/                      # Stack reference architecture
│   ├── decisions/                   # Architecture Decision Records
│   └── specs/                       # Feature specs (SDD workflow)
├── .claude/
│   ├── skills/sdd/                  # SDD workflow knowledge
│   └── commands/                    # /new-spec, /adr, /setup commands
└── .github/                         # GitHub config (PR templates, CI)
```

## How to Customize

### 1. Project Identity

Edit `CLAUDE.md` to set your project name, tech stack, and overview.
Add project-specific rules in the "Project Rules" section.

### 2. Constitution

Review `docs/constitution.md`. The articles are starting points.
Add, modify, or remove articles to match your team's standards.

### 3. Architecture

Fill in `docs/architecture.md` with your system design.
Keep it current -- this is the single source of truth.

### 4. SDD Templates

The spec/plan/tasks templates in `docs/specs/_templates/` work for most projects.
Customize them if your workflow needs additional sections.

## Spec-Driven Development

SDD ensures every feature starts with a written specification:

1. **Spec** -- Define the problem, user stories, and acceptance criteria
2. **Plan** -- Map out components, architecture decisions, and risks
3. **Tasks** -- Break work into small, dependency-ordered tasks
4. **Implement** -- Build task by task, committing atomically
5. **Verify** -- Confirm all acceptance criteria pass

Run `/new-spec` in Claude Code to start this workflow.
See the [SDD Templates Guide](docs/specs/_templates/README.md) for how spec/plan/tasks relate and how to review them.

## Links

- [Constitution](docs/constitution.md)
- [Architecture](docs/architecture.md)
- [PRD](docs/prd.md)
- [ADR Template](docs/decisions/000-template.md)
- [Spec Template](docs/specs/_templates/spec.md)
- [SDD Templates Guide](docs/specs/_templates/README.md)
