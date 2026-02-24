---
allowed-tools:
  - Read
  - Write
  - Edit
  - Bash
  - Glob
  - Grep
---

# Project Setup Wizard

## Step 1: Project Name

Ask for the project name. Validate: lowercase, hyphens allowed, no spaces or special characters. Store as `$PROJECT_NAME`.

## Step 2: Tech Stack

Ask the user to describe their tech stack (e.g. "Next.js + TypeScript + Prisma + PostgreSQL"). Store as `$TECH_STACK`.

## Step 3: Description

Ask for a one-line project description. Store as `$PROJECT_DESCRIPTION`.

## Step 4: Apply Configuration

Replace placeholders using the Edit tool.

**CLAUDE.md:** Replace `{{PROJECT_NAME}}`, `{{TECH_STACK}}`, `{{PROJECT_DESCRIPTION}}`.

**README.md:** Replace the title with `$PROJECT_NAME`. Update the description paragraph.

## Step 4a: Configure Commands

Based on `$TECH_STACK` from Step 2, propose lint/test/build commands appropriate for the stack. Present them to the user for confirmation.

Once confirmed, replace `{{LINT_COMMAND}}`, `{{TEST_COMMAND}}`, `{{BUILD_COMMAND}}` in `CLAUDE.md` using the Edit tool.

Common defaults:
- **Node/TypeScript**: `npx eslint .` / `npx vitest` / `npm run build`
- **Go**: `golangci-lint run` / `go test ./...` / `go build ./...`
- **Python**: `ruff check .` / `pytest` / `python -m build`

## Step 5: Architecture Interview

Fill in `docs/architecture.md` by interviewing the user:

1. "What is the overall system purpose?" -> fill `{{SYSTEM_OVERVIEW}}`
2. "What are the main components and their roles?" -> fill `{{COMPONENT_ARCHITECTURE}}`
3. "How does data flow through the system?" -> fill Data Flow section
4. "What is the deployment/infrastructure setup?" -> fill Infrastructure section
5. Fill the Technology Stack table (`{{LANG}}`, `{{FW}}`, `{{DB}}`, `{{INFRA}}`, `{{CICD}}`)

Summarize back to the user for confirmation before writing.

## Step 6: Constitution Review

Show `docs/constitution.md` and ask:
- "Do these principles match your project goals?"
- "Would you like to adjust any articles or add project-specific principles?"

If yes, help them edit the file.

## Step 7: First ADR

Create `docs/decisions/001-tech-stack.md` from the `000-template.md` template.
Record the tech stack choice as the first Architecture Decision Record.

## Step 8: PRD Creation

Read `docs/prd.md` as the base. Use `ddd-principles` skill knowledge to guide the interview:

1. "Describe the domain this project operates in" -> Domain Overview
2. "Which parts are core to your business vs supporting/generic?" -> Subdomains table
3. "What are the key terms/concepts? Do any terms mean different things in different areas?" -> Ubiquitous Language table
4. "Where do language or responsibility boundaries exist?" -> Bounded Contexts
5. For each context: "What are the main business objects? Which must be consistent together?" -> Aggregates (root entity, entities, value objects, invariants)
6. "What important things happen in the system that other parts need to know about?" -> Domain Events
7. "How do these contexts relate to each other?" -> Context Map

Write result to `docs/prd.md`. If the user wants to skip, that's fine -- PRD is recommended but not blocking.

## Step 8a: Domain Context Summary

Based on the PRD from Step 8, populate the Domain Context section in `CLAUDE.md` with a concise summary:
- Domain name
- Core bounded contexts
- Key invariant (one-liner)

If Step 8 was skipped, ask the user for a brief domain summary instead.

## Step 8b: Configure .gitignore

Based on `$TECH_STACK` from Step 2, append stack-specific patterns to `.gitignore`.

Common patterns:
- **Node/TypeScript**: `node_modules/`, `dist/`, `.next/`, `.turbo/`
- **Go**: binary output directory
- **Python**: `__pycache__/`, `*.egg-info/`, `.venv/`
- **Rust**: `target/`

Confirm with the user before writing.

## Step 9: Finalize

Print a summary:

```
Project initialized successfully!

  Name:        $PROJECT_NAME
  Stack:       $TECH_STACK
  Description: $PROJECT_DESCRIPTION

Next steps:
  1. Review CLAUDE.md and adjust project rules
  2. Review docs/constitution.md and customize principles
  3. Review docs/architecture.md and fill remaining placeholders
  4. Review docs/prd.md and refine domain boundaries
  5. Create your first feature spec with /new-spec
```
