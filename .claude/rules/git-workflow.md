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
  → merge (Rebase and merge)
```

`/impl` stops only at plan approval; `/ship` and merge are the human "visible to
others" moments. There is no auto-merge -- spec correctness stays a human call.

## Branch naming

`<type>/<slug>-<issue#>` -- `<type>` matches the conventional-commit type
(`feat`/`fix`/`refactor`/`chore`/`docs`/`test`/`perf`); `<slug>` is a 3-5 word
kebab description; `<issue#>` is the GitHub issue (omit if none). The issue's `type`
label and the branch prefix share one vocabulary.

## Commits & merge

- One task = one atomic commit (`<type>(<scope>): <imperative>`); each commit leaves the tree working (constitution Article III). Never `--no-verify` / `--force`.
- **Rebase and merge only.** Squash collapses N atomic commits into one and destroys the "every commit works / one concern per commit" guarantee, dropping `git bisect` / `git blame` resolution to PR granularity. The cost -- cleaning branch history (`git rebase -i` to fold WIP/fixup before merge) -- is work Article III already requires.
- Configure the repo to disable squash/merge-commit so only rebase is possible.

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
stack. Create the worktree however you like, then run `task worktree:init` once in it
and `task dev` -- ports and containers are isolated per worktree automatically. Run
`/impl` inside the feature worktree. See `.claude/rules/multi-worktree-dev.md`.
