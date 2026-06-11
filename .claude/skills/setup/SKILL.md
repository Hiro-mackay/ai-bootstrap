---
name: setup
description: Personalize this template for a new project -- identity, architecture/PRD docs, domain context
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

Personalizes the template (identity + docs). This is **not** the dev-environment
bootstrap -- that is `task setup` (deps, DB, codegen, git hooks), which the user
runs separately. The stack is fixed: Go DDD backend + React/Bun frontend + buf
proto; do not ask the user to "choose a stack".

## Step 1: Identity

Ask for:
- **Project name** -- lowercase, hyphens allowed, no spaces (`$PROJECT_NAME`).
- **One-line description** (`$PROJECT_DESCRIPTION`).
- **Go module path** -- e.g. `github.com/org/project`. Validate `github.com/{org}/{project}` (lowercase, no spaces, no trailing slash); reject otherwise.

## Step 2: Scope

Ask: full-stack (default), **go-only**, or **react-only**?
- go-only: ask to remove `frontend/`; if yes, delete it, remove the `react` include from `Taskfile.yml`, drop the npm section from `.github/dependabot.yml`, and trim the Frontend line from `AGENTS.md` Tech Stack / `docs/architecture.md`.
- react-only: same, mirrored for `backend/` (remove `go` include, `gomod` dependabot section, proto if unused).
- full-stack: nothing to remove.

## Step 3: Apply identity (replace placeholders)

1. **Module path** -- replace `github.com/your-org/your-project` in `backend/go.mod`, all `backend/**/*.go`, **and `buf.gen.yaml`** (the `go_package_prefix`). Missing `buf.gen.yaml` here breaks regenerated proto -- do not skip it.
2. **package.json** -- `"name": "your-project"` -> `$PROJECT_NAME` in `frontend/package.json`.
3. **HTML title** -- `frontend/src/index.html` `<title>` -> `$PROJECT_NAME`.
4. **AGENTS.md** -- replace `{{PROJECT_NAME}}` and `{{PROJECT_DESCRIPTION}}` (Tech Stack and Commands are already concrete -- do not touch them).
5. **README.md** -- title -> `$PROJECT_NAME`; update the description paragraph.

## Step 4: Architecture doc

Fill `docs/architecture.md`:
- **Pre-fill the Technology Stack table** from the known stack: Language = Go 1.25 / TypeScript (React 19); Framework = Connect-RPC / TanStack Router+Query; API Protocol = Connect (protobuf); Database = PostgreSQL (sqlc); Infrastructure = podman compose (local) + <user's target>; CI/CD = GitHub Actions + lefthook.
- **Interview** for the narrative: System Overview, Component Architecture, Data Flow. Reference `docs/stacks/` for the layer structure.
- Leave the Observability / Error-handling / Operations tables as placeholders for the user to fill as the system matures (Article IV: architecture.md stays current). Note this in the summary.

Summarize before writing.

## Step 5: Domain Definitions (`docs/prd.md`) -- optional

This is the **domain definitions** doc (bounded contexts, ubiquitous language, invariants) --
**not** a requirements catalogue; requirements/goals stay a human judgment at change-time (#34).
The bounded-context names recorded here are what code `@context` annotations bind to (`task context`).

`docs/prd.md`; the `ddd-principles` rule is auto-loaded. Interview: domain overview,
core vs supporting subdomains, ubiquitous language, bounded contexts, aggregates
(root/entities/VOs/invariants), domain events, context map. Skipping is fine -- PRD
is recommended, not blocking.

## Step 6: Domain Context in AGENTS.md

Populate the AGENTS.md `## Domain Context` section: domain name, core bounded
contexts, one-line key invariant. If PRD was skipped, ask for a brief summary.

If a bounded context was named in Step 5, scaffold the context-harness annotation (#34) into the
seed: add `@context <Name>`/`@business`/`@invariant` to the first domain entity, and `@context`/
`@business` JSDoc to the seed feature's page (see `docs/stacks/`). The `check-context.sh` gate then
activates for that context; with no context defined it stays vacuous, so this is optional and
never blocks. Point the team at `docs/context-harness.md` for the growth path.

## Step 7: Constitution review -- optional

Show `docs/constitution.md`; ask whether the principles fit and offer to adjust or
add project-specific articles.

## Step 8: Finalize

Confirm `task setup` has been run (deps, DB, migrations, codegen, git hooks). If not,
tell the user to run it. Then print:

```
Personalized: $PROJECT_NAME

Next:
  1. task setup   (if not done) -- deps, DB, codegen, git hooks
  2. task dev     -- start the dev servers
  3. Review docs/architecture.md, docs/prd.md, docs/constitution.md
  4. First change: open a GitHub issue (WHAT + Why), then /impl <issue#>
     (mirror docs/stacks and existing slices for structure).
```
