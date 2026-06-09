---
name: impl
description: Pull a GitHub issue, run the SDD plan-mode flow, implement to green, ready for /ship
user-invocable: true
disable-model-invocation: true
argument-hint: "<issue#>"
allowed-tools:
  - Bash
  - Read
  - Edit
  - Write
  - Agent
  - EnterPlanMode
  - ExitPlanMode
  - AskUserQuestion
  - TaskCreate
  - TaskUpdate
  - Glob
  - Grep
  - Skill
---

# /impl

End-to-end issue-to-implementation flow for `$ARGUMENTS`. The issue is the context
package. Stops only at plan approval; pushing belongs to `/ship`.

## 1. Branch gate (safety)

Run `git branch --show-current`. If it is `main`, STOP: implementation happens on a
feature branch (lefthook blocks commits to main anyway). Instruct the user to create
one: `git switch -c <type>/<slug>-<issue#>` (or, if working in parallel, a git
worktree). Do not implement on main.

## 2. Read the issue

`gh issue view $ARGUMENTS --json number,title,body,labels,milestone`.
Extract: title, body (summary / acceptance criteria / dependencies), `type` label
(`feat`/`fix`/`refactor`/`chore`/`docs`/`test`/`perf`) and `area:*` label.

## 3. Research

Spawn 1-3 Explore agents in parallel for codebase reconnaissance based on the issue:
files by path, symbols by name, existing patterns/slices the change must mirror,
tests touching the area. Read `docs/constitution.md` and the relevant
`docs/stacks/*.md`; confirm domain boundaries against `docs/prd.md`.

## 4. Plan mode

`EnterPlanMode`. Inside:

1. Articulate the spec from the issue (problem / user stories / acceptance criteria as Given/When/Then).
2. Use `AskUserQuestion` only for design forks that change scope or layering (max 2-3). Routine choices: assume and proceed.
3. Decide architecture, list affected files, identify risks. Mirror the canonical patterns in `docs/stacks/*` and the nearest existing slice -- do not invent layer structure.
4. Verify layer compliance against `docs/stacks/*` and the `.claude/rules/sdd.md` architecture gate.
5. Decompose into dependency-ordered tasks (`TaskCreate`): domain first, presentation last; one concern per task; one task = one atomic commit.
6. If any ADR trigger in `.claude/rules/sdd.md` applies, draft an ADR under `docs/decisions/`.
7. Call `ExitPlanMode` for approval -- **the only mandatory human stop**. The plan lives in plan mode and the tasks; do not write a plan document (specs/plans rot -- see `.claude/rules/sdd.md`).

## 5. Implementation

After approval, for each task in order:

1. `TaskCreate` the active task (`in_progress` now, `completed` the moment it lands).
2. Implement with Edit / Write, mirroring `docs/stacks/*` and existing slices.
3. Run scoped checks before committing: `task check`, plus `task go:test` (if `backend/` changed) and/or `task react:test` (if `frontend/` changed).
4. One atomic commit per task: `<type>(<scope>): <imperative>`. Never `--no-verify` / `--force`.
5. Do NOT push or open a PR -- that is `/ship`.

If a task balloons, re-plan in plan mode: update the tasks, surface the divergence, continue. Never abandon the plan silently.

## 6. Architecture & coverage gate

After all tasks land, against `git diff origin/main...HEAD`:
- `task arch` (deterministic gates) and re-read the `.claude/rules/sdd.md` architecture gate c-p (semantic gates) against the diff.
- `task coverage` (domain coverage threshold).
Any violation -> create a fix task -> loop back to step 5.

## 7. Verification

- `task check` and the scoped `task go:test` / `task react:test`.
- `git diff origin/main...HEAD --stat` -- confirm no out-of-scope changes.
- Each acceptance criterion maps to a passing test or a verified observable.

Any failure -> new task -> loop to step 5.

## 8. Hand-off

Print issue number/title, current branch, commit count
(`git rev-list --count origin/main..HEAD`), one-line summary. Then:

> Ready for `/ship`.

Do not auto-invoke `/ship` -- pushing is the user's call.
