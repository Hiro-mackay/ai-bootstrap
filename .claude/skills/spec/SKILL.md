---
name: spec
description: Turn a rough idea into a well-formed GitHub issue (the context package) ready for /impl
user-invocable: true
disable-model-invocation: true
argument-hint: "<rough idea / topic>"
allowed-tools:
  - Bash
  - Read
  - Agent
  - Glob
  - Grep
  - AskUserQuestion
  - Skill
---

# /spec

Transform a rough idea into a well-formed GitHub issue — the context package that
`/impl` consumes. Stops at issue creation (human-approved); branch setup and
implementation are the human's next move.

Write and Edit are intentionally absent from allowed-tools: the only output of this
skill is a GitHub issue. No spec documents, no plan files — those rot (`.claude/rules/sdd.md`).

## 0. Intake

Work from `$ARGUMENTS`. If it is empty, ask the user what they want to build before
proceeding.

## 1. Research

Spawn 1-3 Explore agents in parallel to gather raw material for the issue body:

- The nearest existing slice that this change would mirror or extend (patterns, file paths)
- Files and symbols the change is likely to touch (by area: `backend/`, `frontend/`, `proto/`, etc.)
- Existing tests covering the affected area
- Related ADRs in `docs/decisions/` and open issues that overlap

Also run:

```sh
gh issue list --state open --limit 50
```

to check for duplicate or closely related issues before drafting a new one.

Steps 1 and 2 can run in parallel — spawn the Explore agents while reading the
alignment docs.

## 2. Alignment

Read `docs/constitution.md` and `docs/domain-definitions.md`.

Determine which bounded context owns this change and confirm the idea does not
contradict any recorded invariant. If it does, surface the conflict to the user before
going further.

Do **not** read `docs/stacks/*` here. How the change is implemented is `/impl`'s
concern. This step is WHAT + Why only.

## 3. Classify

Pick the `type` label and `area:*` label(s):

| type | when |
|---|---|
| `feat` | new capability visible to users |
| `fix` | wrong behavior corrected |
| `refactor` | structure changed, behavior preserved |
| `chore` | tooling, deps, build, housekeeping |
| `docs` | documentation only |
| `test` | tests only |
| `perf` | measurable performance improvement |

`area:*` options: `area:api`, `area:web`, `area:infra`, `area:docs`, `area:proto`.
Multiple area labels are fine when the change is genuinely cross-cutting.

The `type` label determines the branch prefix (`git-workflow.md`). Pick carefully —
it shapes the PR title, the commit type, and the branch name.

Select the issue template that matches:

- `feat` → `feature_request.yml` fields: Problem Statement, Design Reference (optional), Proposed Solution, Acceptance Criteria, Suggested Branch, Dependencies
- `fix` → `bug_report.yml` fields: Description, Steps to Reproduce, Expected / Actual Behavior
- `refactor` / `chore` / `docs` / `test` / `perf` → no dedicated template; write the body
  directly with these sections: **Summary** (why the change is needed), **Acceptance Criteria**
  (checklist that defines "done"), **Suggested Branch**, **Dependencies**

## 4. Clarify

Use `AskUserQuestion` only for genuine forks that materially change scope or which
bounded context owns the work (max 2-3 questions per turn). Routine choices: assume
and state the assumption in the draft. Do not ask about things research can answer.

Clarify **before** drafting — unresolved forks produce the wrong draft.

## 5. Decomposition check

Assess whether the idea fits in one issue or should become several.

Split only when **both** conditions hold:

1. Each resulting issue is **completely independent** — it can be merged without the other(s) landing first.
2. Each resulting issue is a **semantically complete, implementable unit** on its own.

If the idea spans multiple bounded contexts but the pieces have a strong dependency
(they only make sense together), keep it as **one issue**. Domain boundaries alone
are not a reason to split.

When splitting is warranted, draft all issues and show the user the proposed set with
the dependency links (`Dependencies:` section pointing to each other) before creating
any of them.

## 6. Draft the issue body

Fill the chosen template's fields. Standards that apply regardless of template:

### WHAT vs HOW boundary

The issue captures **what to build and why**. HOW is decided in `/impl` plan mode.

**Do NOT write in the issue body:**

- Domain class names, aggregate names, entity names (e.g. `DocumentShare`, `WorkspaceMember`)
- Function names, method names, application-layer use case names
- DB schema or migration details
- Specific framework or library API names
- Layer structure details (e.g. "Application 層に XXX を実装する")

If you find yourself writing any of the above, replace it with the user-visible behavior it produces.

### Design Reference

When the input references design artifacts (wireframes, ADRs, sketches, etc.),
add a **Design Reference** section to the issue body immediately before Proposed Solution:

```
## Design Reference

- docs/sketches/workspace-home.html
- ADR-016
```

List file paths or issue/ADR numbers only. No description — the artifacts speak for themselves.

### Other required standards

**Acceptance Criteria** — write every criterion as a testable statement, leaning
toward Given/When/Then form. These become test descriptions in `/impl`. Vague criteria
("it works", "looks good") are not acceptable.

**Suggested Branch** — `<type>/<theme-slug>` (omit the issue number; it is appended
after creation). Follow the naming rules in `.claude/rules/git-workflow.md`.

**Dependencies** — list prior issues that must merge first and related ADRs by number.

**ADR flag** — if the change triggers an ADR (new external dependency, breaking schema
change, auth/authz change, new bounded context, context-map relationship change, new
infrastructure component — per `.claude/rules/sdd.md`), add a note in the body:

> Note: this change requires an ADR. `/impl` will draft it in plan mode.

Do **not** write the ADR here. That belongs in `/impl` plan mode.

## 7. Confirm (human moment)

Present the complete draft to the user:

- Issue title
- Labels (`type` + `area:*`)
- Suggested branch name
- Full issue body (formatted, not a wall of text)
- If multiple issues: the full set with dependency links

Ask for approval. Incorporate any edits the user requests before moving to step 8.

Do not create the issue until the user explicitly approves. Issues are durable shared
artifacts — the same moment discipline as `/ship` before pushing.

## 8. Create

After approval, run:

```sh
gh issue create \
  -t "<title>" \
  -l "<type>" -l "<area:*>" \
  --body "<approved body>"
```

For multiple issues, create them in dependency order (dependencies first) and
cross-link them via the `Dependencies:` field using the assigned issue numbers.

Note: GitHub issue template YAML files are for the web UI. The CLI takes raw body
text; fill the template sections manually.

## 9. Hand-off

Print:

- Issue number(s) and URL(s)
- If multiple issues: the dependency chain

Then print the next commands for the user to run:

```
git switch -c <type>/<slug>-<NN>
```

followed by (on that branch):

```
/impl <NN>
```

For parallel work across multiple branches, use a git worktree instead
(`git worktree add`, then `task worktree:init`). See `.claude/rules/multi-worktree-dev.md`.

Do **not** auto-invoke `/impl`. Starting implementation is the user's call.
