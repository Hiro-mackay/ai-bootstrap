---
name: setup
description: Project initialization wizard -- configures CLAUDE.md, architecture, PRD, and first ADR
user-invocable: true
disable-model-invocation: true
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

## Step 3a: Monorepo Personalization

> Only run this step if `$TECH_STACK` includes Go and/or React. Skip entirely for stacks that don't include either.

1. Go module path replacement:
   - Ask the user for their Go module path (e.g. `github.com/org/project`)
   - Validate: must match `github.com/{org}/{project}` format (lowercase, no spaces, no trailing slash). Reject empty strings, paths with uppercase letters, or missing segments.
   - Replace `github.com/your-org/your-project` in `backend/go.mod` and all `backend/**/*.go` files with the provided module path

2. React package.json name replacement:
   - Replace `"name": "your-project"` in `frontend/package.json` with `$PROJECT_NAME`

3. HTML title replacement:
   - Replace the `<title>` content in `frontend/src/index.html` with `$PROJECT_NAME`

4. Optional stack removal:
   - If Go-only: ask if they want to remove the `frontend/` directory
   - If React-only: ask if they want to remove the `backend/` directory
   - If a directory is removed, update Taskfile.yml to remove the corresponding include

5. Print: "Monorepo personalized. Run `task dev` to verify."

## Step 4: Apply Configuration

Replace placeholders using the Edit tool.

**CLAUDE.md:** Replace `{{PROJECT_NAME}}`, `{{TECH_STACK}}`, `{{PROJECT_DESCRIPTION}}`.

**README.md:** Replace the title with `$PROJECT_NAME`. Update the description paragraph.

## Step 4a: Configure Commands

Based on `$TECH_STACK` from Step 2, propose lint/test/build commands appropriate for the stack. Present them to the user for confirmation.

Once confirmed, replace `{{LINT_COMMAND}}`, `{{TEST_COMMAND}}`, `{{BUILD_COMMAND}}` in `CLAUDE.md` using the Edit tool.

If `buf.yaml` exists in the project root, uncomment the Proto commands in `CLAUDE.md` (remove the surrounding `<!-- ... -->` comment markers from the Proto Generate and Proto Lint lines).

Common defaults (Taskfile always present in this template):
- **Full-stack (Go + React)**: `task lint` / `task test` / `task ci`
- **Go-only**: `task go:lint` / `task go:test` / `task go:ci`
- **React-only**: `task react:lint` / `task react:test` / `task react:ci`

## Step 4b: Stack Architecture Rules

Based on `$TECH_STACK` from Step 2, detect the stack and inject architecture rules into CLAUDE.md's "Project Rules" section.

**Important:** Before appending any block, check if CLAUDE.md already contains the corresponding header (e.g., `### Go DDD Architecture` or `### React Architecture`). Skip injection if the header already exists to prevent duplication on re-runs.

### Go Detection

If `$TECH_STACK` contains "go" or "golang" (case-insensitive):
1. Read `docs/stacks/go-ddd.md`
2. Append to CLAUDE.md Project Rules:

```
### Go DDD Architecture (see docs/stacks/go-ddd.md)
- Directory: backend/cmd/ + backend/internal/{domain,usecase,infrastructure,interface}/ + backend/pkg/
- Domain layer: exported fields, no JSON/DB tags, behavior methods, repository + TransactionManager interfaces
- UseCase layer: Command/Query with Execute + Input/Output, transaction boundaries here
- Infrastructure layer: one file per concern, BaseRepository composition, AppError conversion
- Interface layer: request/response DTOs, presenter, error handler middleware
```

### React Detection

If `$TECH_STACK` contains "react", "next.js", or "nextjs" (case-insensitive):
1. Read `docs/stacks/react-bun.md`
2. Append to CLAUDE.md Project Rules:

```
### React Architecture (see docs/stacks/react-bun.md)
- Directory: frontend/src/app/ (router) + frontend/src/features/{feature}/ + frontend/src/lib/ + frontend/src/stores/
- Package-by-feature: pages in features/{feature}/pages/, components in features/{feature}/components/
- No barrel exports (index.ts) -- direct file path imports only
- Data fetching: TanStack Query mandatory, connect-query auto-managed keys from proto definitions
- API client: connect-query with generated types from protobuf via `buf generate`
- Client state: Zustand for auth/UI/ephemeral state, TanStack Query for server state
- Validation: Zod schemas in lib/validation/schemas.ts (primitives) + features/*/validation.ts (composed)
```

### Full-Stack Detection

If both Go and React/Next.js are detected, inject both rule blocks.

## Step 4c: Configure Dependabot

Based on `$TECH_STACK` from Step 2, uncomment the matching ecosystem sections in `.github/dependabot.yml`:

- **React/Node/Bun**: Uncomment the `npm` ecosystem section (directory: `/frontend`)
- **Go**: Uncomment the `gomod` ecosystem section (directory: `/backend`)
- **Python**: Uncomment the `pip` ecosystem section
- **Rust**: Uncomment the `cargo` ecosystem section

Leave non-matching sections commented out. The `github-actions` ecosystem is always active.

## Step 5: Architecture Interview

Fill in `docs/architecture.md` by interviewing the user:

1. "What is the overall system purpose?" -> fill `{{SYSTEM_OVERVIEW}}`
2. "What are the main components and their roles?" -> fill `{{COMPONENT_ARCHITECTURE}}`
3. "How does data flow through the system?" -> fill Data Flow section
4. "What is the deployment/infrastructure setup?" -> fill Infrastructure section
5. Fill the Technology Stack table (`{{LANG}}`, `{{FW}}`, `{{DB}}`, `{{INFRA}}`, `{{CICD}}`)
6. If stack reference docs exist in `docs/stacks/`:
   - Ask: "The reference architecture defines a standard directory structure. Use it as-is, or customize?"
   - If customized, create an ADR documenting the deviation
   - Reference the stack doc in the Component Architecture section

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

Read `docs/prd.md` as the base. The `ddd-principles` rule is auto-loaded. Use it to guide the interview:

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

Based on `$TECH_STACK` from Step 2, review `.gitignore` and add any missing stack-specific patterns.

**Important:** Read the existing `.gitignore` first to avoid duplicate entries. Only append patterns that are not already present.

Common patterns to check:
- **Go**: `bin/`, `tmp/`
- **React/Node**: `node_modules/`, `dist/`
- **Next.js**: `.next/`, `.turbo/`
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
  1. Run 'task dev' to start the development server
  2. Review CLAUDE.md and adjust project rules
  3. Review docs/constitution.md and customize principles
  4. Review docs/architecture.md and fill remaining placeholders
  5. Review docs/prd.md and refine domain boundaries
  6. Create your first feature spec with /new-spec
```
