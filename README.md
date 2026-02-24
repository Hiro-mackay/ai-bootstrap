# AI-Native Development Bootstrap

A GitHub template repository for teams adopting AI-native development practices.
Provides project structure, Spec-Driven Development (SDD) workflow, and Claude Code integration out of the box.

## What This Template Provides

- **CLAUDE.md** -- AI assistant configuration scoped to your project
- **Constitution** -- Non-negotiable project rules (specs before code, no secrets, etc.)
- **PRD template** -- Domain boundaries, ubiquitous language, and bounded contexts
- **Architecture doc** -- Single source of truth for system design
- **SDD workflow** -- Templates for specs, plans, and task breakdowns
- **SDD skill** -- Auto-loaded Claude skill encoding the full SDD workflow
- **ADR template** -- Architecture Decision Records for tracking decisions
- **Claude commands** -- `/new-spec` for feature specs, `/adr` for architecture decisions, `/setup` for project initialization

## Quick Start

1. Click **"Use this template"** on GitHub to create your repo
2. Clone your new repo
3. Run `/setup` in Claude Code to configure project name, stack, architecture, and PRD
4. Review `docs/constitution.md`: customize rules for your team
5. Start building: run `/new-spec` in Claude Code to create your first feature spec

## Project Structure

```
.
├── CLAUDE.md                        # AI assistant project config
├── .gitignore                       # Tech-agnostic ignore patterns
├── docs/
│   ├── constitution.md              # Project rules and principles
│   ├── architecture.md              # System design (source of truth)
│   ├── prd.md                       # PRD (domain boundaries)
│   ├── decisions/
│   │   └── 000-template.md          # ADR template
│   └── specs/
│       └── _templates/
│           ├── spec.md              # Feature spec template
│           ├── plan.md              # Implementation plan template
│           └── tasks.md             # Task breakdown template
├── .claude/
│   ├── skills/
│   │   └── sdd/
│   │       └── SKILL.md             # SDD workflow knowledge
│   └── commands/
│       ├── new-spec.md              # /new-spec command
│       ├── adr.md                   # /adr command
│       └── setup.md                 # /setup command
└── .github/                         # GitHub config (PR templates, CI)
```

## How to Customize

### 1. Project Identity

Edit `CLAUDE.md` to set your project name, tech stack, and overview.
Add project-specific rules in the "Project Rules" section.

### 2. Constitution

Review `docs/constitution.md`. The articles are starting points.
Add, modify, or remove articles to match your team's standards.

### 3. Architecture

Fill in `docs/architecture.md` with your system design.
Keep it current -- this is the single source of truth.

### 4. SDD Templates

The spec/plan/tasks templates in `docs/specs/_templates/` work for most projects.
Customize them if your workflow needs additional sections.

## Spec-Driven Development

SDD ensures every feature starts with a written specification:

1. **Spec** -- Define the problem, user stories, and acceptance criteria
2. **Plan** -- Map out components, architecture decisions, and risks
3. **Tasks** -- Break work into small, dependency-ordered tasks
4. **Implement** -- Build task by task, committing atomically
5. **Verify** -- Confirm all acceptance criteria pass

Run `/new-spec` in Claude Code to start this workflow.

## Links

- [Constitution](docs/constitution.md)
- [Architecture](docs/architecture.md)
- [PRD](docs/prd.md)
- [ADR Template](docs/decisions/000-template.md)
- [Spec Template](docs/specs/_templates/spec.md)
