# Taskfile Workflow

## Rule

ALWAYS use Taskfile commands (`task <name>`) for all project operations. NEVER run raw commands (go run, bun run, air, migrate, etc.) directly.

## Command Reference

| Operation | Command | Raw command (DO NOT USE) |
|-----------|---------|--------------------------|
| Start all | `task dev` | go run / bun run dev |
| Backend dev | `task go:dev` | air / go run ./cmd/server/ |
| Frontend dev | `task react:dev` | bun run dev |
| Infra up | `task infra:up` | podman compose up |
| Infra down | `task infra:down` | podman compose down |
| Migrate up | `task go:migrate:up` | migrate -path ... |
| Migrate down | `task go:migrate:down` | migrate -path ... |
| Test all | `task test` | go test / bun test |
| Backend test | `task go:test` | go test ./... |
| Frontend test | `task react:test` | bun test (DO NOT USE directly) |
| Lint | `task lint` | golangci-lint / biome |
| Build | `task build` | go build / bun run build |
| Proto gen | `task proto:gen` | buf generate |
| Full CI | `task ci` | (manual chaining) |

## Why

- Taskfile encapsulates correct flags, env loading, and directory context
- Prevents inconsistency between manual commands and CI
- Single source of truth for how operations are executed
