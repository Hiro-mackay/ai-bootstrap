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

Replace placeholders using the Edit tool.

**CLAUDE.md:**
1. Replace `{{PROJECT_NAME}}` with `$PROJECT_NAME`
2. Replace `{{TECH_STACK}}` with `$TECH_STACK`
3. Replace `{{PROJECT_DESCRIPTION}}` with `$PROJECT_DESCRIPTION`

**README.md:**
4. Replace the title "AI-Native Development Bootstrap" with `$PROJECT_NAME`
5. Update the description paragraph to match the project

**docs/architecture.md:**
6. Replace `{{SYSTEM_OVERVIEW}}` with a brief system description based on the tech stack
7. Replace `{{COMPONENT_ARCHITECTURE}}` with initial component list based on the stack
8. Fill in the Technology Stack table (`{{LANG}}`, `{{FW}}`, `{{DB}}`, `{{INFRA}}`, `{{CICD}}`)

## Step 5: Constitution Review

Show the user the current contents of `docs/constitution.md` and ask:
- "Do these principles match your project goals?"
- "Would you like to adjust any articles or add project-specific principles?"

If yes, help them edit `docs/constitution.md` with their changes.

## Step 6: First ADR

Create `docs/decisions/001-tech-stack.md` from the `000-template.md` template.
Record the tech stack choice as the first Architecture Decision Record.

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
