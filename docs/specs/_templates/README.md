# SDD Templates Guide

## Overview

Spec-Driven Development (SDD) uses three documents to take a feature from idea to implementation.
Each document answers a different question and operates at a different level of abstraction.

```
spec.md  --  WHY + WHAT (why build it, what to build)
  |
  v
plan.md  --  HOW (how to build it)
  |
  v
tasks.md --  WHO + WHEN (who builds what, in what order)
```

## Document Roles

| Document | Abstraction | Core Question | Key Contents |
|----------|-------------|---------------|-------------|
| **spec.md** | High (domain) | "What problem are we solving?" | Problem statement, user stories, acceptance criteria (Given/When/Then), domain impact |
| **plan.md** | Medium (design) | "How do we implement it?" | Architecture decisions, component breakdown, API/DB changes, risk assessment |
| **tasks.md** | Low (execution) | "Who does what, in what order?" | Phased task list, file ownership, dependencies between tasks |

In short: **spec = contract, plan = blueprint, tasks = work orders**.

## How They Connect

- **plan.md** references spec.md and translates each requirement into concrete components
- **tasks.md** references both spec.md and plan.md, then decomposes components into atomic tasks
- Each downstream document must trace back to the one above it -- no orphan work

## Reviewing Each Document

### spec.md -- The Gate

Review the spec first. If the spec is wrong, everything downstream is wasted effort.

- **Problem clarity** -- Is the problem well-defined? Is the "why now?" convincing?
- **Acceptance criteria** -- Are all criteria in Given/When/Then format and testable?
- **Completeness** -- Are there unresolved `[NEEDS CLARIFICATION]` markers?
- **Scope** -- Is the spec scoped to a single bounded context (per `docs/prd.md`)?
- **Boundaries** -- Are the Always/Ask First/Never rules realistic and enforceable?
- **Domain impact** -- Are affected aggregates and domain events explicitly listed?

### plan.md -- Spec Alignment

The plan must demonstrate that every spec requirement has a technical home.

- **Requirement coverage** -- Does every FR and NFR from the spec map to a component?
- **NFR strategy** -- Does the NFR Strategy table cover all spec NFRs with concrete approaches?
- **Risk honesty** -- Are risks realistic? Are mitigations actionable, not hand-wavy?
- **Codebase alignment** -- Does the plan follow existing patterns, or explicitly justify deviations?
- **ADR triggers** -- Are there decisions that need an ADR (new dependency, schema break, auth change)?
- **Domain model** -- Are aggregate boundaries and domain event flows well-defined?

### tasks.md -- Plan Alignment

Tasks must fully decompose the plan into executable units.

- **Plan coverage** -- Is every plan component represented in at least one task?
- **Dependency correctness** -- Are `Depends on` references accurate? No circular dependencies?
- **TDD compliance** -- Does Phase 2 (Core Implementation) list tests before implementation files?
- **Atomicity** -- Can each task result in one atomic commit that leaves the codebase working?
- **File ownership** -- Are owned files listed per task with no overlaps (prevents merge conflicts in teams)?
- **Phase ordering** -- Setup -> Core -> Wiring -> Integration -> Docs -- does the progression make sense?

## Review Checklist (Quick Reference)

```
Spec:
  [ ] Problem is clear and justified
  [ ] All acceptance criteria are Given/When/Then
  [ ] No unresolved [NEEDS CLARIFICATION]
  [ ] Scoped to one bounded context
  [ ] Domain impact section is filled in

Spec -> Plan traceability:
  [ ] Every FR/NFR has a corresponding component or strategy
  [ ] Architecture decisions are documented (ADR if needed)
  [ ] Risks identified with mitigations

Plan -> Tasks traceability:
  [ ] Every component maps to at least one task
  [ ] Dependencies are correct and acyclic
  [ ] Each task is one concern, one commit
  [ ] File ownership is explicit and non-overlapping
```

## Lifecycle

Spec status progresses through: **Draft -> In Review -> Approved -> Implemented**

- Spec must be **Approved** before implementation begins
- Plan and tasks are filled in between Draft and Approved
- After all tasks pass and `/verify` succeeds, status moves to **Implemented**
