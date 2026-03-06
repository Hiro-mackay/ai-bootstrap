# {{PROJECT_NAME}}

{{PROJECT_DESCRIPTION}}

## Tech Stack

{{TECH_STACK}}

## Guiding Documents

- [Constitution](docs/constitution.md) -- project rules and principles
- [Architecture](docs/architecture.md) -- single source of truth for system design
- [Product Requirements](docs/prd.md) -- domain boundaries and product scope
- [Stack Reference](docs/stacks/) -- tech-stack-specific implementation patterns (populated during /setup)

## Commands

<!-- Fill in after project setup. Examples by stack:
  Node/TS:  Lint: `npx eslint .`  Test: `npx vitest`  Build: `npm run build`
  Go:       Lint: `golangci-lint run`  Test: `go test ./...`  Build: `go build ./...`
  Python:   Lint: `ruff check .`  Test: `pytest`  Build: `python -m build`
-->
- **Lint**: `{{LINT_COMMAND}}`
- **Test**: `{{TEST_COMMAND}}`
- **Build**: `{{BUILD_COMMAND}}`
<!-- Uncomment during /setup if buf.yaml exists:
- **Proto Generate**: `buf generate`
- **Proto Lint**: `buf lint`
-->

## Project Rules

<!-- Add project-specific rules below -->

## Domain Context

<!-- Summarize the project's domain here after setup.
  This section helps Claude understand business terminology and constraints
  without reading every doc. Update as the domain model evolves.

  Example:
  - Domain: E-commerce marketplace
  - Core contexts: Catalog, Orders, Payments
  - Key invariant: Order total must equal sum of line items
-->
