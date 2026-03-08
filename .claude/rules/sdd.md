# Spec-Driven Development (SDD)

Every feature begins with a written spec. No code without a reviewed spec and approved plan.

## Workflow

Enter Plan Mode at step 1, exit at step 6.

1. **Research** -- Use Explore subagents to investigate the codebase before writing anything. Understand existing patterns, affected files, and dependencies.
2. **Constitution & PRD** -- Read `docs/constitution.md` and `docs/prd.md` (if it exists). Confirm alignment with project principles and domain boundaries.
3. **Spec** -- Copy `docs/specs/_templates/spec.md` to `docs/specs/{{FEATURE_SLUG}}/spec.md`. Fill in problem, user stories, acceptance criteria (Given/When/Then). Mark unknowns as `[NEEDS CLARIFICATION]`. Use AskUserQuestion to surface ambiguities -- interview the user on edge cases, tradeoffs, and scope before finalizing. Spec should be concise and domain-oriented; avoid bloat. Scope the spec to a single bounded context as defined in `docs/prd.md`.
4. **Plan** -- Copy `docs/specs/_templates/plan.md`. Define architecture decisions, component breakdown, risks. Include aggregate design and domain event flows where applicable (the `ddd-principles` rule is auto-loaded). Create an ADR in `docs/decisions/` when any of these apply: new external dependency, breaking schema change, auth/authz model change, new bounded context, context map relationship change, new infrastructure component. If stack reference docs exist (docs/stacks/), read them and fill in the Architecture Compliance section: assign every component to a layer, complete the compliance checklist, flag any reference architecture violations.
5. **Tasks** -- Copy `docs/specs/_templates/tasks.md`. Break into dependency-ordered tasks grouped by architecture layer (domain first, presentation last). Each task: one concern, owned files listed, layer assignment, layer-specific acceptance criteria.
6. **Execution mode** -- Default: team. Single only when 1 file AND 1 concern. Follow the `team-conventions` rule for team setup. Convert tasks.md into TaskCreate items.
7. **Implementation** -- One task = one atomic commit. Follow `docs/constitution.md` Article III. The `test-strategy` rule is auto-loaded for TDD guidance.
8. **Architecture Gate** -- Before verification, if stack reference docs exist (docs/stacks/), read them and check all new/modified files:
   a. Domain files have no infrastructure or interface imports
   b. Domain types have no JSON/DB tags (tags belong on interface DTOs only)
   c. Domain entities use exported fields with behavior methods (no getter ceremony)
   d. Value Objects exist where raw primitives represent domain concepts
   e. UseCase layer has Command/Query with Execute method + Input/Output structs
   f. TransactionManager used for cross-entity operations in UseCase layer
   g. Interface layer uses DTOs (domain types never in API surface)
   h. Frontend components live in feature directories (not in components/ui/ or any shared directory)
   i. No barrel exports (index.ts) -- all imports use direct file paths
   j. Query keys use connect-query auto-managed keys (no manual key factories)
   k. Data fetching uses TanStack Query (server state never in Zustand)
   l. API types generated from schema (protobuf via `buf generate`, no manual API type definitions)
   m. Mutations have onSuccess handlers that invalidate related queries
   n. No cross-feature internal imports (features import only from other features' public API files)
   o. Routes with server data define a `loader` using `createQueryOptions` + `prefetchQuery` (no loading flicker)
   p. Page components use `useSuspenseQuery` (not `useQuery`) for primary data, wrapped in `<Suspense>` at route level
   If violations found, create fix tasks before proceeding to verification.
9. **Verification** -- Run `/verify`. Additionally:
   a. Confirm each acceptance criterion has a corresponding passing test
   b. Confirm all `[NEEDS CLARIFICATION]` markers are resolved
   c. Run `git diff` to verify no out-of-scope changes
   d. Update spec status to Implemented

## Flow Variants

**Bug fix** -- Start from step 1 (Research to reproduce). Minimal spec (problem + reproduction steps). Skip plan if isolated to one module. Write failing test first, then fix.

**Refactoring** -- Spec defines current state, desired state, motivation. Each task must leave codebase in working state. Verify no behavior changes.

## Boundaries

### Always

- Research before spec, interview before finalizing
- Acceptance criteria in Given/When/Then
- Explicit execution mode decision after task breakdown
- ADR for significant architecture decisions (new dependencies, schema breaks, auth changes, new contexts)
- Update spec status as it progresses (Draft -> In Review -> Approved -> Implemented)
- Reference `docs/prd.md` for domain boundaries; scope specs to a single bounded context
- `/verify` before marking any spec as Implemented

### Ask First

- Modifying approved specs
- Changing decisions documented in ADRs
- Skipping the plan step
- Using single agent for 2+ files

### Never

- Code without at least a draft spec
- Delete approved specs without discussion
- Ignore `[NEEDS CLARIFICATION]` markers
- Teammates modifying files outside their ownership
