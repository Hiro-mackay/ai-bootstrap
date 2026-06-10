# Git / GitHub Workflow

The flywheel an engineer runs per change. Each stage hands a clean artifact to the
next; gates are owned by `task` / lefthook, not re-implemented in the commands.

## The loop

```
gh issue create -t "<title>" -l <type> -l area:<web|api>   # work unit = issue
  → git switch -c <type>/<slug>-<issue#>                   # (or a git worktree for parallel work)
  → /impl <issue#>     research → plan (human approves) → implement to green
  → /ship              quality gate → push → PR (Closes #)
  → /triage-review      Claude (+ Codex) review → you pick fixes → apply → annotate PR
  → merge (Squash and merge)
```

`/impl` stops only at plan approval; `/ship` and merge are the human "visible to
others" moments. There is no auto-merge -- spec correctness stays a human call.

## Branch naming

`<type>/<slug>-<issue#>` -- `<type>` matches the conventional-commit type
(`feat`/`fix`/`refactor`/`chore`/`docs`/`test`/`perf`); `<slug>` is a 3-5 word
kebab description; `<issue#>` is the GitHub issue (omit if none). The issue's `type`
label and the branch prefix share one vocabulary.

## Commits & merge

- One task = one atomic commit on the branch (`<type>(<scope>): <imperative>`); each commit leaves the tree working (constitution Article III). Never `--no-verify` / `--force`.
- **Squash and merge only.** A merge collapses the branch's commits into one on `main`, so `git bisect` / `git blame` resolve to PR granularity, not per-commit. Atomicity therefore lives in the **PR** (one PR = one concern), and main's history is one working commit per PR. The branch's atomic commits still earn their keep before merge: they drive review (`/triage-review` reads the diff per concern) and keep `git rebase -i` cleanup cheap.
- Write a clear squash-commit title (`<type>(<scope>): <imperative>`, closing `#<issue>`); it is the unit `git log` / `bisect` / `blame` see on `main`.
- The repo is configured for squash only (`allow_merge_commit=false`, `allow_rebase_merge=false`, `allow_squash_merge=true`); `gh pr merge --rebase` will fail. Use `gh pr merge --squash`.

## main protection

lefthook blocks direct commits to `main` locally. If branch protection is
unavailable (private repo without the required plan), keep the discipline: every
reviewable change goes through a PR; no human direct-push to main.

## ADR

Add an ADR under `docs/decisions/` only for the `.claude/rules/sdd.md` §4 triggers
(new dependency, schema break, auth change, new bounded context, context-map change,
new infra). Day-to-day work is covered by the issue (WHAT) + the PR (HOW) + code
comments (the living link); no spec or plan documents are kept -- they rot.

## Parallel work (optional)

For several changes at once, use git worktrees so each has its own checkout and dev
stack. Run `/impl` inside the feature worktree. (The infra side -- isolating ports
and containers per worktree -- is project-specific; wire it into the Taskfile when
you need concurrent `task dev`.)
