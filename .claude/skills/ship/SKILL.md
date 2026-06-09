---
name: ship
description: Run local quality gates, push the current branch, and open a PR linked to the issue
user-invocable: true
disable-model-invocation: true
allowed-tools:
  - Bash
  - Read
  - Skill
  - Agent
---

# /ship

Push the current branch and open a PR. Quality gates first; visible-to-others
actions last.

## 1. Pre-flight

- Current branch is not `main`. If it is, stop.
- No uncommitted changes (`git status --porcelain`). If dirty, list the files and ask whether to commit or stash before shipping.

## 2. Quality gate (stop on first failure)

Run sequentially:

1. `task format` -- auto-fix formatting.
2. `task check` -- proto lint + lint + type-check + architecture fitness.
3. Tests scoped to the diff (`git diff origin/main...HEAD --name-only`):
   - `task go:test` if any `backend/` files changed.
   - `task react:test` if any `frontend/` files changed.
   - both if both changed; skip if only `docs/`, `.github/`, `.claude/`, or top-level config changed.
4. `task coverage` -- domain coverage gate.

On any failure: surface it, stop. Do not push. The user fixes locally and re-runs `/ship`.

## 3. Sanity diff review

- `git diff origin/main...HEAD --stat`
- `git log origin/main..HEAD --oneline`

Verify: conventional commit format (`<type>(<scope>): <imperative>`), no accidental
files (`.env`, secrets, large binaries, generated code that should be ignored), no
commits outside the branch `<type>` scope. If anything is off, stop and surface it.

## 4. Push

`git push -u origin "$(git branch --show-current)"`.

## 5. Open PR

Extract the issue number from the branch name (last `-NN` of `<type>/<slug>-<NN>`).
Read `.github/PULL_REQUEST_TEMPLATE.md` and fill it:

- Reference the issue: `Closes #<NN>`.
- **Summary**: 1-2 sentences from the issue + commit log.
- **Changes**: bullets from `git log origin/main..HEAD --oneline`.
- **Testing**: what actually ran (`task check`, `task go:test` / `task react:test`).
- Tick only checklist items that are true.

```
gh pr create \
  --title "<conventional title mirroring the lead commit>" \
  --body "$(cat <<'EOF'
<filled template>
EOF
)"
```

If the `commit-commands:commit-push-pr` plugin skill is available and there are
still pending uncommitted changes after step 1, prefer it over manual steps 4-5 --
it owns the project's commit + push + PR style.

## 6. Hand-off

Print the PR URL, then:

> Ready for `/triage-review`.

Do not auto-run `/triage-review`.
