---
allowed-tools: Read, Write, Edit, Glob, Grep, Bash
---

# New Spec

Create a new feature spec using the SDD workflow.

## Steps

1. Ask the user for a feature name and brief description.

2. Research the codebase with Explore subagents: find existing patterns, affected files, related code. Summarize findings before proceeding.

3. Convert the feature name to a slug (lowercase, hyphens, no special characters).

4. Create the spec directory: `docs/specs/{{FEATURE_SLUG}}/`

5. Copy templates into the directory:
   - Read `docs/specs/_templates/spec.md` and write to `docs/specs/{{FEATURE_SLUG}}/spec.md`
   - Read `docs/specs/_templates/plan.md` and write to `docs/specs/{{FEATURE_SLUG}}/plan.md`
   - Read `docs/specs/_templates/tasks.md` and write to `docs/specs/{{FEATURE_SLUG}}/tasks.md`

6. Replace `{{FEATURE_NAME}}` with the actual feature name in all three files.
   Replace `{{FEATURE_SLUG}}` with the actual slug in plan.md and tasks.md.

7. Interview the user to fill in the spec. Use AskUserQuestion to surface ambiguities:
   - Problem Statement: what problem, why now?
   - User Stories with acceptance criteria (Given/When/Then)
   - Edge cases and tradeoffs the user may not have considered
   - Functional and Non-Functional Requirements
   - Boundaries (Always / Ask First / Never)
   - Mark anything unresolved as [NEEDS CLARIFICATION]

8. After the spec is filled in, ask if the user wants to proceed to the plan.
