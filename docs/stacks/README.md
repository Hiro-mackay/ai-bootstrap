# Stack Reference Architecture

The **canonical** implementation patterns for each tech stack. New code should
mirror these and the nearest existing slice when implementing. Keeping new code
anchored here is what prevents per-project implementation drift.

During `/setup`, rules from the matching stack doc are injected into AGENTS.md.

## Available References

- [Go DDD](go-ddd.md) -- Go + DDD layer architecture (domain/application/infrastructure/presentation)
- [React](react-bun.md) -- package-by-feature + TanStack Query + Zustand + Zod + connect-query

## Adding a New Stack

1. Create `docs/stacks/{stack}.md` following the existing format
2. Add detection logic in `.claude/skills/setup/SKILL.md` Step 4b
3. Define the AGENTS.md rule summary to be injected during setup
