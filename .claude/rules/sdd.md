# Spec-Driven Development (SDD)

Every feature begins with a written spec. No code without a reviewed spec and approved plan.

## Workflow

Enter Plan Mode at step 1, exit at step 6.

1. **Research** -- Use Explore subagents to investigate the codebase before writing anything. Understand existing patterns, affected files, and dependencies.
2. **Constitution & PRD** -- Read `docs/constitution.md` and `docs/prd.md` (if it exists). Confirm alignment with project principles and domain boundaries.
3. **Spec** -- Copy `docs/specs/_templates/spec.md` to `docs/specs/{{FEATURE_SLUG}}/spec.md`. Fill in problem, user stories, acceptance criteria (Given/When/Then). Mark unknowns as `[NEEDS CLARIFICATION]`. Use AskUserQuestion to surface ambiguities -- interview the user on edge cases, tradeoffs, and scope before finalizing. Spec should be concise and domain-oriented; avoid bloat. Scope the spec to a single bounded context as defined in `docs/prd.md`.
4. **Plan** -- Copy `docs/specs/_templates/plan.md`. Define architecture decisions, component breakdown, risks. Include aggregate design and domain event flows where applicable (the `ddd-principles` rule is auto-loaded). Create an ADR in `docs/decisions/` when any of these apply: new external dependency, breaking schema change, auth/authz model change, new bounded context, context map relationship change, new infrastructure component.
5. **Tasks** -- Copy `docs/specs/_templates/tasks.md`. Break into dependency-ordered tasks. Each task: one concern, owned files listed, clear acceptance criteria.
6. **Execution mode** -- Default: team. Single only when 1 file AND 1 concern. Follow the `team-conventions` rule for team setup. Convert tasks.md into TaskCreate items.
7. **Implementation** -- One task = one atomic commit. Follow `docs/constitution.md` Article III. The `test-strategy` rule is auto-loaded for TDD guidance.
8. **Verification** -- Run `/verify`. Additionally:
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
