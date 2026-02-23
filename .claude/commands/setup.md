---
allowed-tools:
  - Read
  - Write
  - Edit
  - Bash
  - Glob
  - Grep
---

# Project Setup Wizard

You are initializing a new project from the AI-Native Development Bootstrap template.
Guide the user through each step interactively.

## Step 1: Project Name

Ask the user for their project name.

- Validate: lowercase, hyphens allowed, no spaces or special characters
- Store as `$PROJECT_NAME`

## Step 2: Tech Stack

Ask the user to describe their tech stack. Examples:
- "Next.js + TypeScript + Prisma + PostgreSQL"
- "Python + FastAPI + SQLAlchemy + PostgreSQL"
- "Go + Chi + GORM + PostgreSQL"
- "Rust + Axum + SQLx + PostgreSQL"
- Or any other combination

Store as `$TECH_STACK`

## Step 3: Description

Ask the user for a one-line project description.

Store as `$PROJECT_DESCRIPTION`

## Step 4: Apply Configuration

Replace placeholders across the project:

1. **CLAUDE.md**: Replace `{{PROJECT_NAME}}` with `$PROJECT_NAME`
2. **CLAUDE.md**: Replace `{{TECH_STACK}}` with `$TECH_STACK`
3. **CLAUDE.md**: Replace `{{PROJECT_DESCRIPTION}}` with `$PROJECT_DESCRIPTION`
4. **docs/architecture.md**: Replace `{{PROJECT_NAME}}` with `$PROJECT_NAME`
5. **docs/architecture.md**: Replace `{{TECH_STACK}}` with `$TECH_STACK`
6. **README.md**: Replace `{{PROJECT_NAME}}` with `$PROJECT_NAME`
7. **README.md**: Replace `{{PROJECT_DESCRIPTION}}` with `$PROJECT_DESCRIPTION`

Use the Edit tool to perform each replacement.

## Step 5: Constitution Review

Show the user the current contents of `docs/constitution.md` and ask:
- "Do these principles match your project goals?"
- "Would you like to adjust any articles or add project-specific principles?"

If yes, help them edit `docs/constitution.md` with their changes.

## Step 6: Architecture Setup

Based on the chosen tech stack, update `docs/architecture.md`:
- Fill in appropriate layer descriptions for the chosen stack
- Add relevant technology-specific sections
- Set up ADR template with the first decision (tech stack choice)

## Step 7: Finalize

Print a summary:

```
Project initialized successfully!

  Name:        $PROJECT_NAME
  Stack:       $TECH_STACK
  Description: $PROJECT_DESCRIPTION

Next steps:
  1. Review CLAUDE.md and adjust AI coding guidelines
  2. Review docs/constitution.md and customize project principles
  3. Review docs/architecture.md and add system details
  4. Start building!
```
