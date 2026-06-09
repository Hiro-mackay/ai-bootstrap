# UI Primitives Catalog

Text index of installed shadcn/ui primitives in `components/primitives/`. **Read
this before writing or editing UI** (see `.claude/rules/use-primitives.md`). LLMs
can't browse a visual component catalog, so this file is the discovery path -- keep
it current.

Install a primitive: `task react:shadcn -- <name>` (e.g. `task react:shadcn -- button`).
After installing, add a row below.

## Installed

_None yet._ Run `task react:shadcn -- <name>` to add the first one.

| Primitive | Import | Notes |
|---|---|---|
| <!-- button --> | <!-- @/components/primitives/button --> | <!-- variants: default/outline/ghost; sizes: sm/default/lg --> |

## Categories to reach for (shadcn)

- **Forms**: button, input, textarea, checkbox, radio-group, select, switch, label, form
- **Overlays**: dialog, sheet, popover, tooltip, dropdown-menu, alert-dialog
- **Display**: card, badge, avatar, table, separator, skeleton
- **Feedback**: alert, sonner (toast), progress
- **Navigation**: tabs, breadcrumb, navigation-menu
