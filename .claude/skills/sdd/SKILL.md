---
name: sdd
description: Spec-Driven Development workflow for designing features before implementation
user-invocable: false
---

# Spec-Driven Development (SDD)

Every feature begins with a written spec. No code without a reviewed spec and approved plan.

## When to Use SDD

**Full workflow** -- New features, significant refactors, multi-file changes.
**Lightweight** (skip to step 3) -- Bug fixes with clear reproduction, isolated config changes.
**Skip entirely** -- Typo fixes, single-line changes, trivial tasks where the diff is obvious.

## Workflow

Enter Plan Mode at step 1, exit at step 6.

1. **Research** -- Use Explore subagents to investigate the codebase before writing anything. Understand existing patterns, affected files, and dependencies.
2. **Constitution** -- Read `docs/constitution.md`. Confirm alignment with project principles.
3. **Spec** -- Copy `docs/specs/_templates/spec.md` to `docs/specs/{{FEATURE_SLUG}}/spec.md`. Fill in problem, user stories, acceptance criteria (Given/When/Then). Mark unknowns as `[NEEDS CLARIFICATION]`. Use AskUserQuestion to surface ambiguities -- interview the user on edge cases, tradeoffs, and scope before finalizing. Spec should be concise and domain-oriented; avoid bloat.
4. **Plan** -- Copy `docs/specs/_templates/plan.md`. Define architecture decisions, component breakdown, risks. If the decision is significant, create an ADR in `docs/decisions/`.
5. **Tasks** -- Copy `docs/specs/_templates/tasks.md`. Break into dependency-ordered tasks. Each task: one concern, owned files listed, clear acceptance criteria.
6. **Execution mode** -- Default: team. Single only when 1 file AND 1 concern. Follow `team-conventions` skill for team setup. Convert tasks.md into TaskCreate items.
7. **Implementation** -- One task = one atomic commit. Follow `docs/constitution.md` Article III.
8. **Verification** -- Run `/verify`. All acceptance criteria pass. Update spec status to Implemented.

## Flow Variants

**Bug fix** -- Start from step 1 (Research to reproduce). Minimal spec (problem + reproduction steps). Skip plan if isolated to one module. Write failing test first, then fix.

**Refactoring** -- Spec defines current state, desired state, motivation. Each task must leave codebase in working state. Verify no behavior changes.

Both default to team unless trivially small (1 file, 1 concern).

## Boundaries

### Always

- Research before spec, interview before finalizing
- Acceptance criteria in Given/When/Then
- Explicit execution mode decision after task breakdown
- ADR for significant architecture decisions
- Update spec status as it progresses (Draft -> Approved -> Implemented)

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
