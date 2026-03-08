# ai-bootstrap

Full-stack monorepo template with Go DDD backend and React frontend.

## Tech Stack

- Backend: Go 1.25, Connect-RPC, PostgreSQL, sqlc
- Frontend: React 19, TanStack Router, TanStack Query, connect-query, Tailwind CSS, Bun
- Proto: buf, protobuf
- CI: GitHub Actions, golangci-lint, Biome, Vitest

## Guiding Documents

- [Constitution](docs/constitution.md) -- project rules and principles
- [Architecture](docs/architecture.md) -- single source of truth for system design
- [Product Requirements](docs/prd.md) -- domain boundaries and product scope
- [Stack Reference](docs/stacks/) -- tech-stack-specific implementation patterns (populated during /setup)

## Commands

- **Lint**: `task lint`
- **Test**: `task test`
- **Build**: `task build`
- **Proto Generate**: `buf generate`
- **Proto Lint**: `buf lint`

## Project Rules

<!-- Add project-specific rules below -->

## Domain Context

- Domain: Todo application (template scaffold)
- Core contexts: Todo management
- Key invariant: Todo status transitions follow pending -> completed -> pending cycle
