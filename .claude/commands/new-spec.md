---
allowed-tools: Read, Write, Glob, Bash
---

# New Spec

Create a new feature spec using the SDD workflow.

## Steps

1. Ask the user for a feature name and brief description.

2. Convert the feature name to a slug (lowercase, hyphens, no special characters).

3. Create the spec directory: `docs/specs/{{FEATURE_SLUG}}/`

4. Copy templates into the directory:
   - Read `docs/specs/_templates/spec.md` and write to `docs/specs/{{FEATURE_SLUG}}/spec.md`
   - Read `docs/specs/_templates/plan.md` and write to `docs/specs/{{FEATURE_SLUG}}/plan.md`
   - Read `docs/specs/_templates/tasks.md` and write to `docs/specs/{{FEATURE_SLUG}}/tasks.md`

5. Replace `{{FEATURE_NAME}}` with the actual feature name in all three files.
   Replace `{{FEATURE_SLUG}}` with the actual slug in plan.md and tasks.md.

6. Guide the user through filling in the spec:
   - Start with the Problem Statement
   - Then User Stories with acceptance criteria
   - Then Functional and Non-Functional Requirements
   - Then Boundaries
   - Mark anything unclear as [NEEDS CLARIFICATION]

7. After the spec is filled in, ask if the user wants to proceed to the plan.
