# Stack Reference Architecture

Project-specific architecture guides for each tech stack.
During `/setup`, rules from the matching stack doc are injected into CLAUDE.md.

## Available References

- [Go DDD](go-ddd.md) -- Go + DDD layer architecture (domain/application/infrastructure/presentation)
- [React](react-bun.md) -- package-by-feature + TanStack Query + Zustand + Zod + connect-query

## Adding a New Stack

1. Create `docs/stacks/{stack}.md` following the existing format
2. Add detection logic in `.claude/commands/setup.md` Step 4b
3. Define the CLAUDE.md rule summary to be injected during setup
