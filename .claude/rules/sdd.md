# Spec-Driven Development (SDD)

Every change begins with intent, but **the spec lives in the issue, plan mode,
tests, and code -- never in spec document files.** Documents rot the moment they
are written and drift from the implementation. Code and tests are the single
source of truth.

- **WHAT (+ Why)** lives in the GitHub issue.
- **HOW** is realized in the PR (code + atomic commits).
- The **link between them** lives in the codebase as living information: tests
  (acceptance criteria), and comments where the *why* is non-obvious.

The `/impl <issue#>` command runs this workflow end to end; `/ship` and
`/triage-review` deliver and review it. This rule defines the process they follow.

## Workflow (inside plan mode, steps 1-5)

1. **Research** -- Explore subagents investigate the codebase before writing anything: existing patterns, affected files, dependencies, tests touching the area.
2. **Constitution & domain definitions** -- Read `docs/constitution.md` and `docs/domain-definitions.md`; confirm alignment with principles and domain boundaries.
3. **Spec (in plan mode, not a file)** -- Define problem, user stories, acceptance criteria (Given/When/Then) from the issue. Use AskUserQuestion for genuine ambiguity. Scope to a single bounded context. **No spec files** -- acceptance criteria become test descriptions.
4. **Plan (in plan mode, not a file)** -- Architecture decisions, component breakdown, affected files, risks. Read `docs/stacks/*` and verify layer compliance; mirror the canonical patterns and the nearest existing slice rather than inventing structure. Create an ADR in `docs/decisions/` only when a §-criteria below applies. The plan is implementation guidance, not an artifact to preserve.
5. **Tasks** -- Decompose into dependency-ordered tasks (domain first, presentation last; one concern each). Track with `TaskCreate`. Exit plan mode for human approval.

## Implementation (step 6)

One task = one atomic commit (constitution Article III). Acceptance criteria are
written as **tests, not documents** (the `test-strategy` rule covers TDD). Run
scoped checks (`task check`, `task go:test` / `task react:test`) before each commit.

When a modified file carries `@context`/`@business`/`@invariant` annotations, run
`task context -- --path <file>` and verify annotation content still holds; update
before committing. (`check-context.sh` surfaces unchanged annotations on staged files
as a reminder; it cannot verify content accuracy automatically.)

## ADR triggers

Create an ADR (`docs/decisions/`, from `000-template.md`) only for: new external
dependency, breaking schema change, auth/authz change, new bounded context,
context-map relationship change, new infrastructure component. Everyday work needs
no ADR -- the issue + PR + code comments carry the rest.

## Architecture Gate (step 7)

Before verification, check all new/modified files against `docs/stacks/*`:

   a. Domain files have no infrastructure or interface imports
   b. Domain types have no JSON/DB tags (tags belong on interface DTOs only)
   c. Domain entities use exported fields with behavior methods (no getter ceremony)
   d. Value Objects exist where raw primitives represent domain concepts
   e. UseCase layer has Command/Query with Execute method + Input/Output structs
   f. TransactionManager used for cross-entity operations in UseCase layer
   g. Interface layer uses DTOs (domain types never in API surface)
   h. Frontend components live in feature directories. Shared placement under `components/primitives/` (shadcn) or `components/layout/` (app shell) is allowed only when the component meets the promotion criteria in `.claude/rules/use-primitives.md` (no feature-internal imports, props-externalized, used in >= 2 places, no domain vocabulary). Reuse/extend an existing primitive before writing a new component
   i. No barrel exports (index.ts) -- all imports use direct file paths
   j. No manual `queryKey` arrays -- use `createQueryOptions` or connect-query hooks
   k. Data fetching uses TanStack Query (server state never in Zustand)
   l. API types generated from schema (protobuf via `buf generate`, no manual API types)
   m. Mutations have onSuccess handlers that invalidate related queries
   n. No cross-feature internal imports (features import only via other features' public API)
   o. Routes with server data define a `loader` using `createQueryOptions` + `prefetchQuery`
   p. Page components use `useSuspenseQuery` (not `useQuery`) for primary data, wrapped in `<Suspense>`

   **Enforcement / ownership** (do not self-report what tooling already owns):
   - **Automated** -- gates a, b, i, j, k, n + file size + escape hatches are enforced by `task arch` (`scripts/check-architecture.sh`) and domain coverage by `task coverage`, run locally on pre-commit/pre-push and in the `/impl`,`/ship` loop. A violation blocks the commit/push (CI itself is build-only -- see `docs/harness.md`).
   - **Review** -- the semantic gates c, d, e, f, g, h, l, m, o, p are judged by `/triage-review` (Claude + Codex). Self-check them in plan mode too.

   Any violation -> create a fix task -> loop back to implementation.

## Verification (step 8)

- `task check` and the scoped `task go:test` / `task react:test`.
- `git diff origin/main...HEAD` -- no out-of-scope changes.
- Each acceptance criterion maps to a passing test or a verified observable.

## Flow variants

- **Bug fix** -- Start from Research (reproduce). Skip the plan step if isolated to one module. Write the failing test first, then fix.
- **Refactoring** -- Define current state, desired state, motivation in plan mode. Each task leaves the codebase working. Verify no behavior change.

## Boundaries

**Always**: research before defining the spec; acceptance criteria as tests, not documents; ADR for the triggers above; scope to a single bounded context.
**Ask first**: changing an ADR-documented decision; skipping the plan step.
**Never**: write per-feature spec/plan/tasks document files (they rot); ignore unresolved ambiguity; leave an acceptance criterion without a test.
