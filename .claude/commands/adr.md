---
allowed-tools: Read, Write, Edit, Bash, Glob, Grep
---

# /adr -- Create an Architecture Decision Record

### Step 1: Gather context

Ask the user:
- **Title**: What decision is being made?
- **Context**: What is the issue or situation motivating this decision?

### Step 2: Determine the next ADR number

1. Glob `docs/decisions/[0-9]*.md` to list existing ADRs
2. Find the highest-numbered file (e.g., `003-some-decision.md` -> 3)
3. Increment by 1 and zero-pad to 3 digits (e.g., `004`)
4. If no numbered files exist, start at `001`

### Step 3: Read the template

Read `docs/decisions/000-template.md` as the base structure.

### Step 4: Gather the decision

Ask the user:
- **Decision**: What was decided and why?

### Step 5: Gather consequences

Ask the user about consequences:
- **Positive**: What becomes easier?
- **Negative**: What becomes harder or riskier?
- **Neutral**: What changes without clear positive/negative impact?

### Step 6: Gather alternatives

Ask the user:
- **Alternatives Considered**: What other options were evaluated and why were they rejected?

### Step 7: Write the ADR

1. Generate a slug from the title (lowercase, hyphens, no special characters)
2. Set the date to today
3. Set status to `Proposed`
4. Write the completed ADR to `docs/decisions/{NNN}-{slug}.md`

### Step 8: Follow-up

Ask the user:
- Does `docs/architecture.md` need updating based on this decision?
- Does `docs/prd.md` need updating based on this decision?

If yes to either, help make those updates.
