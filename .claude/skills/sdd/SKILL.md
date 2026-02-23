---
name: sdd
description: Spec-Driven Development workflow for designing features before implementation
user-invocable: false
---

# Spec-Driven Development (SDD)

SDD is a development methodology where every feature begins with a written specification.
Specs serve as the contract between intent and implementation, ensuring alignment before code is written.

## Workflow

1. **Constitution check** -- Review `docs/constitution.md` to confirm the feature aligns with project principles.
2. **Spec drafting** -- Create a spec from `docs/specs/_templates/spec.md`. Define the problem, user stories, and acceptance criteria.
3. **Plan design** -- Create a plan from `docs/specs/_templates/plan.md`. Map out components, architecture decisions, and risks.
4. **Tasks breakdown** -- Create tasks from `docs/specs/_templates/tasks.md`. Break work into small, dependency-ordered tasks.
5. **Implementation** -- Build according to the plan. Each task maps to a commit.
6. **Verification** -- Confirm all acceptance criteria have passing tests.

## Templates

All templates live in `docs/specs/_templates/`:

- `spec.md` -- Feature specification with user stories and acceptance criteria
- `plan.md` -- Implementation plan with component breakdown and risk assessment
- `tasks.md` -- Task breakdown with dependencies and estimation

## Creating a New Spec

1. Create a directory: `docs/specs/{{FEATURE_SLUG}}/`
2. Copy templates into the directory: `spec.md`, `plan.md`, `tasks.md`
3. Fill in the spec first, get it reviewed
4. Then complete the plan and tasks

## Claude Code Integration

### Plan Mode

Use Plan Mode (Shift+Tab) when:
- Drafting specs and plans
- Discussing architecture decisions
- Reviewing acceptance criteria

### Subagents

Use subagents (Task tool) for:
- Researching existing patterns in the codebase
- Investigating dependencies
- Running parallel verification tasks

### Tasks System

Use the Tasks system (TodoWrite) for:
- Tracking implementation progress from `tasks.md`
- Managing dependencies between tasks

## Flows

### New Feature

1. Run `/new-spec` to scaffold the spec
2. Fill in problem statement and user stories
3. Define acceptance criteria with Given/When/Then
4. Create the plan with component breakdown
5. Break into tasks with dependencies
6. Implement task by task, committing atomically

### Bug Fix

1. Create a minimal spec: problem statement + reproduction steps
2. Skip the plan if the fix is isolated
3. Write a failing test from the acceptance criteria
4. Fix the bug, verify the test passes

### Refactoring

1. Create a spec: current state, desired state, motivation
2. Plan the refactoring steps to keep the system working at each step
3. Break into tasks that each leave the codebase in a working state
4. Verify no behavior changes (existing tests still pass)

## Boundaries

### Always Do

- Write a spec before starting implementation
- Include acceptance criteria in Given/When/Then format
- Create an ADR for significant architecture decisions
- Keep specs updated as requirements change

### Ask First

- Modifying existing specs that are already approved
- Changing architecture decisions documented in ADRs
- Skipping the plan step for "simple" features

### Never Do

- Start coding without at least a draft spec
- Delete or overwrite approved specs without discussion
- Ignore open questions marked with [NEEDS CLARIFICATION]
