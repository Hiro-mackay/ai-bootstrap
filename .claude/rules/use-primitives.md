# Check primitives before writing UI

## Rule

Before adding a new UI component under `apps`/`frontend/src/`, or editing an
existing one, **always**:

1. **Read `frontend/src/components/primitives/INDEX.md`** -- the text catalog of installed primitives.
2. If a matching primitive exists, import it: `import { Button } from '@/components/primitives/button'`.
3. Express the need with an existing variant/size/state first (most cases end here).
4. If close but insufficient, **extend the primitive** (add a variant) rather than writing a new component in `features/`.
5. If the primitive is missing, **install it**: `task react:shadcn -- <name>`. Do not hand-roll a primitive that shadcn provides.
6. Only when it is a genuinely new, domain-specific concept, write a feature component under `features/<feature>/components/`. State the reason in one line in plan mode.

## Why

- LLMs cannot browse a visual catalog (Storybook/Ladle). A **text index + this rule** is the only reliable discovery path -- without it the agent reinvents components it can't see.
- The same concept implemented twice (a primitive vs a feature one-off) drifts visually: a later change updates one and not the other.
- shadcn/ui primitives already pass the project's styling conventions; ad-hoc components don't.

## How to apply

- **Trigger**: adding or editing any `.tsx` that returns JSX under `frontend/src/`.
- **First action**: `Read frontend/src/components/primitives/INDEX.md`; in plan mode, record whether an existing primitive covers the need before asking anything.
- **After installing a primitive**: add a one-line entry to `INDEX.md` (this is what keeps the catalog usable).

## Promotion (feature component -> shared primitive)

Promote a `features/` component into `components/primitives/` only when all hold: no
feature-internal imports, behavior is props-externalized, it is used in >= 2 places,
and its props carry no domain vocabulary. On promotion, add it to `INDEX.md`. This
is the gate-h condition in `.claude/rules/sdd.md`.
