# Multi-worktree parallel dev

Run `task dev` in several git worktrees at once without host-port clashes. Each
worktree owns three host ports (postgres / api / web) plus its own podman project,
assigned **once** at worktree-prep time and frozen -- never recomputed at `task dev`.

## Canonical flow

Worktree creation stays your call (a `gwa` alias, `git worktree add`, whatever).
The repo owns exactly one prep step:

```
gwa some-branch-name      # or: git worktree add ../app_some-branch -b some-branch
cd <new-worktree>
task worktree:init        # allocate isolated ports + full setup (idempotent)
task dev                  # runs on this worktree's ports
```

`task worktree:init` is a safe re-run -- it keeps the ports it already assigned.
`task setup` does the same thing (init is its alias). No `gwa`? `task worktree:add
-- <branch> [path]` creates the worktree and preps it in one shot.

Tear down with `task worktree:remove -- <path>` (uses `--force`: the generated
`.env*` are untracked, so plain `git worktree remove` refuses). The freed ports
return to the pool automatically -- there is nothing to prune.

## How ports are assigned

- **Base ports (offset 0, the main checkout):** postgres `5432`, api `8080`, web `3000`.
- A worktree's **offset** shifts all three by the same amount; `.env.worktree` holds
  `WORKTREE_OFFSET`, `COMPOSE_PROJECT_NAME`, the three ports, and the values derived
  from them (`DATABASE_URL`, `ALLOWED_ORIGINS`, `BUN_PUBLIC_API_BASE_URL`).
- The **main checkout always gets offset 0**; linked worktrees get the smallest free
  offset `>= 1`. "Free" = no other live worktree claims it (`scripts/worktree-ports.sh`
  reads every worktree's `.env.worktree` via `git worktree list`) and its ports are
  not already listening (`lsof`, best-effort).
- `.env` carries only port-independent config (credentials, log level). Ports live
  **only** in `.env.worktree`, and `dotenv: ['.env', '.env.worktree']` lets the latter win.

The set of taken offsets is the live worktrees themselves, so there is **no registry
file, no lock, no GC**. A removed worktree frees its offset by ceasing to exist.

## Why no runtime allocation / re-exec

Allocating at prep time (not at every `task dev`) is the whole point. Because the
ports are written before `task dev` runs, `task dev` only reads dotenv -- no runtime
locking, no registry I/O, no re-exec of `task` into an env-stripped child. The one
process boundary that matters (`task setup` re-invokes `task` as a fresh process after
writing `.env.worktree`) is handled inside `task worktree:init`, not in the hot path.

## OAuth (when auth is added)

This template has no OAuth yet. When it gains one, use a **Desktop-type OAuth client
with a loopback redirect** (`http://127.0.0.1:<ephemeral>`), not a fixed callback port.
Google treats loopback redirects as port-independent, so adding worktrees never needs
a Cloud Console re-registration. A reverse-proxy + custom `*.localhost` hostname does
the opposite (per-hostname registration) and is why it was rejected -- see issue #23.

## Portability

`scripts/worktree-ports.sh` is POSIX sh and avoids GNU-only flags, so allocation
behaves the same on macOS (BSD userland) and Linux. `task worktree:test` exercises
the offset selection (collision avoidance + reuse after removal).
