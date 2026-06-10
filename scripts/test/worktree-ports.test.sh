#!/bin/sh
# Tests for scripts/worktree-ports.sh offset allocation:
#   - main worktree gets offset 0
#   - linked worktrees get the smallest free offset >= 1 (no collision)
#   - a removed worktree frees its offset for reuse (no manual prune)
# Port-busy probing is disabled so the test is deterministic on any machine.
set -u

SCRIPT=$(CDPATH= cd "$(dirname "$0")/.." && pwd)/worktree-ports.sh
export WORKTREE_SKIP_PORT_CHECK=1

fail=0
check() { # check <label> <expected> <actual>
  if [ "$2" = "$3" ]; then
    echo "ok   - $1"
  else
    echo "FAIL - $1: expected '$2' got '$3'" >&2
    fail=1
  fi
}

offset_of() { sed -n 's/^WORKTREE_OFFSET=//p' "$1/.env.worktree"; }

tmp=$(mktemp -d)
trap 'rm -rf "$tmp"' EXIT
main="$tmp/main"

git init -q "$main"
git -C "$main" config user.email t@t.t
git -C "$main" config user.name t
printf 'POSTGRES_USER=postgres\nPOSTGRES_PASSWORD=postgres\nPOSTGRES_DB=app_dev\n' > "$main/.env.example"
git -C "$main" add -A
git -C "$main" commit -qm init

# main worktree -> offset 0
sh "$SCRIPT" alloc "$main" >/dev/null
check "main gets offset 0" 0 "$(offset_of "$main")"

# first linked worktree -> offset 1
git -C "$main" worktree add -q "$tmp/a" -b a
sh "$SCRIPT" alloc "$tmp/a" >/dev/null
check "first linked gets offset 1" 1 "$(offset_of "$tmp/a")"

# second linked worktree -> offset 2
git -C "$main" worktree add -q "$tmp/b" -b b
sh "$SCRIPT" alloc "$tmp/b" >/dev/null
check "second linked gets offset 2" 2 "$(offset_of "$tmp/b")"

# alloc is idempotent -- re-running keeps the same offset
sh "$SCRIPT" alloc "$tmp/b" >/dev/null
check "alloc is idempotent" 2 "$(offset_of "$tmp/b")"

# remove offset-1 worktree, add a new one -> offset 1 is reused.
# --force because the generated .env/.env.worktree are untracked (gitignored).
git -C "$main" worktree remove --force "$tmp/a"
git -C "$main" worktree add -q "$tmp/c" -b c
sh "$SCRIPT" alloc "$tmp/c" >/dev/null
check "freed offset is reused" 1 "$(offset_of "$tmp/c")"

# composite values are derived from the offset
check "DATABASE_URL uses worktree port" \
  "DATABASE_URL=postgres://postgres:postgres@localhost:5434/app_dev?sslmode=disable" \
  "$(sed -n 's/^\(DATABASE_URL=.*\)/\1/p' "$tmp/b/.env.worktree")"

proj_of() { sed -n 's/^COMPOSE_PROJECT_NAME=//p' "$1/.env.worktree"; }

# same leaf basename in different parents -> distinct, valid project names
mkdir -p "$tmp/p1" "$tmp/p2"
git -C "$main" worktree add -q "$tmp/p1/dup" -b dup1
git -C "$main" worktree add -q "$tmp/p2/dup" -b dup2
sh "$SCRIPT" alloc "$tmp/p1/dup" >/dev/null
sh "$SCRIPT" alloc "$tmp/p2/dup" >/dev/null
p1=$(proj_of "$tmp/p1/dup"); p2=$(proj_of "$tmp/p2/dup")
check "same-basename worktrees get distinct project names" \
  "differ" "$([ "$p1" != "$p2" ] && echo differ || echo same)"
check "project name is non-empty" \
  "nonempty" "$([ -n "$p1" ] && echo nonempty || echo empty)"
check "project name starts with alnum" \
  "yes" "$(printf '%s' "$p1" | grep -q '^[a-z0-9]' && echo yes || echo no)"

[ "$fail" -eq 0 ] && echo "worktree-ports: all tests passed"
exit "$fail"
