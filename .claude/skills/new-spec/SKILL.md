---
name: new-spec
description: Create a new feature spec using the SDD workflow
user-invocable: true
disable-model-invocation: true
argument-hint: "[feature name]"
allowed-tools:
  - Read
  - Write
  - Edit
  - Glob
  - Grep
  - Bash
---

# New Spec

Create a new feature spec using the SDD workflow.

## Steps

1. **Feature name**: Use `$ARGUMENTS` as the feature name if provided. Otherwise, ask the user for a feature name and brief description.

2. Research the codebase with Explore subagents: find existing patterns, affected files, related code. Summarize findings before proceeding.

3. **PRD Check** -- Check if `docs/prd.md` exists. If not, suggest creating one with `/setup`. Do not block -- continue either way.

4. **Scope Guard** -- If `docs/prd.md` exists, read it and display the list of bounded contexts with their aggregates and domain events. Ask the user which bounded context this feature belongs to. If it spans multiple contexts, suggest splitting into separate specs. Store the chosen context.

5. Convert the feature name to a slug (lowercase, hyphens, no special characters).

6. Create the spec directory: `docs/specs/{{FEATURE_SLUG}}/`

7. Copy templates into the directory:
   - Read `docs/specs/_templates/spec.md` and write to `docs/specs/{{FEATURE_SLUG}}/spec.md`
   - Read `docs/specs/_templates/plan.md` and write to `docs/specs/{{FEATURE_SLUG}}/plan.md`
   - Read `docs/specs/_templates/tasks.md` and write to `docs/specs/{{FEATURE_SLUG}}/tasks.md`

8. Replace `{{FEATURE_NAME}}`, `{{FEATURE_SLUG}}`, and `{{BOUNDED_CONTEXT}}` (use chosen context or "N/A" if no PRD) in all files.

9. Interview the user to fill in the spec. Use AskUserQuestion to surface ambiguities:
   - Problem Statement: what problem, why now?
   - User Stories with acceptance criteria (Given/When/Then)
   - Domain Impact: which aggregates are affected, what domain events are published/consumed
   - Ubiquitous Language: any new terms to add to `docs/prd.md`
   - Edge cases and tradeoffs the user may not have considered
   - Functional and Non-Functional Requirements
   - Boundaries (Always / Ask First / Never)
   - Mark anything unresolved as [NEEDS CLARIFICATION]

10. **ADR Trigger** -- Check if any ADR criteria from the SDD rule apply. If so, suggest running `/adr`.

11. **Scope Audit** -- Read the chosen bounded context from `docs/prd.md`. Verify that all entities, value objects, and domain events referenced in the spec are listed under that context. Flag any references to concepts belonging to other contexts and suggest splitting the spec or updating the PRD.

12. **PRD Feedback** -- If new terms were identified in Domain Impact (Step 9), write them back to the Ubiquitous Language table in `docs/prd.md`. If new domain events were identified, add them to the relevant bounded context in `docs/prd.md`.

13. After the spec is filled in, ask if the user wants to proceed to the plan.
