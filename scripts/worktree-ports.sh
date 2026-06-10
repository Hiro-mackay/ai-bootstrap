#!/bin/sh
# Per-worktree dev port allocation.
#
# Each git worktree gets a host-port "offset" assigned ONCE, at worktree prep
# time, and frozen into a static .env.worktree. `task dev` only reads it -- no
# runtime locking, no registry file, no re-exec. The set of taken offsets is the
# live worktrees themselves (git worktree list + each one's .env.worktree), so a
# removed worktree frees its offset automatically with nothing to prune.
#
# The main worktree always gets offset 0 (the default 5432/8080/3000 ports);
# linked worktrees get the smallest free offset >= 1 that no other worktree
# claims and whose ports are not already listening.
#
# Subcommands:
#   ensure <dir>   prepare <dir>: copy .env from .env.example, allocate ports
#   alloc  <dir>   write <dir>/.env.worktree once (no-op if it exists)
#   add <branch> [path]   create a worktree (for those without a `gwa` alias) and prep it
#
# Portable POSIX sh; works on macOS (BSD) and Linux (GNU).
set -u

# Offset-0 base ports. Spacing between services (3000/5432/8080) stays larger
# than MAX_OFFSET, so a shared offset never makes two services collide.
BASE_PG=5432
BASE_API=8080
BASE_WEB=3000
MAX_OFFSET=63

# Set WORKTREE_SKIP_PORT_CHECK=1 to skip the lsof port-busy probe (used by tests).
SKIP_PORT_CHECK=${WORKTREE_SKIP_PORT_CHECK:-0}

die() { echo "worktree-ports: $*" >&2; exit 1; }

abspath() { (cd "$1" 2>/dev/null && pwd -P); }

# read_env_val <file> <key> -- echo the value of KEY=... (last wins), or empty.
read_env_val() {
  [ -f "$1" ] || return 0
  sed -n "s/^$2=//p" "$1" | tail -n 1
}

# is_main_worktree <dir> -- true when <dir> is the primary checkout (git-dir
# equals the common git-dir), which always owns offset 0.
is_main_worktree() {
  _gd=$(cd "$1" && git rev-parse --absolute-git-dir 2>/dev/null) || return 1
  _cd=$(cd "$1" && cd "$(git rev-parse --git-common-dir 2>/dev/null)" 2>/dev/null && pwd -P) || return 1
  [ "$_gd" = "$_cd" ]
}

# have_port_tool -- true when some TCP-listener probe is available.
have_port_tool() {
  command -v lsof >/dev/null 2>&1 || command -v ss >/dev/null 2>&1 || command -v nc >/dev/null 2>&1
}

# port_busy <port> -- true when something is already LISTENing on the TCP port.
# Best-effort: lsof -> ss -> nc; returns "free" when no probe tool exists (the
# worktree scan still prevents worktree-vs-worktree collisions).
port_busy() {
  [ "$SKIP_PORT_CHECK" = "1" ] && return 1
  if command -v lsof >/dev/null 2>&1; then
    lsof -nP -iTCP:"$1" -sTCP:LISTEN >/dev/null 2>&1
  elif command -v ss >/dev/null 2>&1; then
    ss -ltn 2>/dev/null | grep -q "[.:]$1[[:space:]]"
  elif command -v nc >/dev/null 2>&1; then
    nc -z 127.0.0.1 "$1" >/dev/null 2>&1
  else
    return 1
  fi
}

ports_free_for_offset() {
  for _base in "$BASE_PG" "$BASE_API" "$BASE_WEB"; do
    port_busy $((_base + $1)) && return 1
  done
  return 0
}

# used_offsets <target-dir> -- offsets (one per line) claimed by every OTHER
# live worktree (read from each one's .env.worktree).
used_offsets() {
  _target=$1
  git -C "$_target" worktree list --porcelain 2>/dev/null \
    | sed -n 's/^worktree //p' \
    | while IFS= read -r _wt; do
        [ "$(abspath "$_wt")" = "$_target" ] && continue
        _off=$(read_env_val "$_wt/.env.worktree" WORKTREE_OFFSET)
        [ -n "$_off" ] && echo "$_off"
      done
}

list_has() {
  for _x in $2; do [ "$_x" = "$1" ] && return 0; done
  return 1
}

# pick_offset <target-dir> -- smallest free offset >= 1.
pick_offset() {
  if [ "$SKIP_PORT_CHECK" != "1" ] && ! have_port_tool; then
    echo "worktree-ports: no lsof/ss/nc -- skipping port-busy check (worktree scan still prevents collisions)" >&2
  fi
  _used=$(used_offsets "$1" | tr '\n' ' ')
  _off=1
  while [ "$_off" -le "$MAX_OFFSET" ]; do
    if ! list_has "$_off" "$_used" && ports_free_for_offset "$_off"; then
      echo "$_off"; return 0
    fi
    _off=$((_off + 1))
  done
  die "no free port offset under $MAX_OFFSET -- remove an unused worktree"
}

# sanitize <s> -- lowercase, keep [a-z0-9_-], strip leading/trailing non-alnum so
# the result is empty or starts/ends with an alnum (valid as a podman name part).
sanitize() {
  printf '%s' "$1" | tr '[:upper:]' '[:lower:]' | tr -c 'a-z0-9_-' '-' \
    | sed 's/^[^a-z0-9]*//; s/[^a-z0-9]*$//'
}

# project_name <dir> -- a podman-valid COMPOSE_PROJECT_NAME that is non-empty,
# starts with an alnum, and is unique per worktree (distinct absolute paths never
# collide, even if their basenames sanitize to the same string). cksum is the
# POSIX CRC, identical on macOS and Linux.
project_name() {
  _slug=$(sanitize "$(basename "$1")")
  _hash=$(printf '%s' "$1" | cksum | cut -d' ' -f1)
  printf '%s' "${_slug:+${_slug}-}wt${_hash}"
}

write_env_worktree() {
  _dir=$1; _off=$2
  _pg=$((BASE_PG + _off)); _api=$((BASE_API + _off)); _web=$((BASE_WEB + _off))
  _src="$_dir/.env"; [ -f "$_src" ] || _src="$_dir/.env.example"
  _user=$(read_env_val "$_src" POSTGRES_USER); _user=${_user:-postgres}
  _pass=$(read_env_val "$_src" POSTGRES_PASSWORD); _pass=${_pass:-postgres}
  _db=$(read_env_val "$_src" POSTGRES_DB); _db=${_db:-app_dev}
  _proj=$(project_name "$_dir")

  cat > "$_dir/.env.worktree" <<EOF
# Generated by scripts/worktree-ports.sh -- isolated dev ports for this worktree.
# Frozen at prep time and reused on every restart (same worktree == same ports).
# Regenerate by deleting this file and running \`task worktree:init\`.
WORKTREE_OFFSET=$_off
COMPOSE_PROJECT_NAME=$_proj
POSTGRES_PORT=$_pg
APP_PORT=$_api
BUN_PORT=$_web
DATABASE_URL=postgres://$_user:$_pass@localhost:$_pg/$_db?sslmode=disable
ALLOWED_ORIGINS=http://localhost:$_web
BUN_PUBLIC_API_BASE_URL=http://localhost:$_api
EOF
}

announce_offset() {
  echo "worktree-ports: offset $1 -> pg $((BASE_PG + $1)) / api $((BASE_API + $1)) / web $((BASE_WEB + $1))"
}

# Prep is human-paced, but two `task worktree:init`/`worktree:add` runs can still
# overlap and scan before either writes its .env.worktree. A short mkdir lock in
# the shared git-common-dir serializes the scan->write for linked worktrees so
# they cannot land on the same offset. (Main/offset 0 is deterministic; no lock.)
acquire_lock() {
  _tries=0
  until mkdir "$1" 2>/dev/null; do
    _tries=$((_tries + 1))
    [ "$_tries" -ge 30 ] && die "could not acquire lock $1 after 30s (remove it if a prior run crashed)"
    sleep 1
  done
}

cmd_alloc() {
  _dir=$(abspath "${1:-.}") || die "no such dir: ${1:-.}"
  if [ -f "$_dir/.env.worktree" ]; then
    echo "worktree-ports: keep existing .env.worktree (offset $(read_env_val "$_dir/.env.worktree" WORKTREE_OFFSET))"
    return 0
  fi
  if is_main_worktree "$_dir"; then
    write_env_worktree "$_dir" 0
    announce_offset 0
    return 0
  fi

  _common=$(cd "$_dir" && cd "$(git rev-parse --git-common-dir 2>/dev/null)" 2>/dev/null && pwd -P) \
    || die "not inside a git worktree: $_dir"
  _lock="$_common/worktree-ports.lock"
  acquire_lock "$_lock"
  trap 'rmdir "$_lock" 2>/dev/null' EXIT INT TERM
  # Re-check under the lock: a racing run may have just written it.
  if [ ! -f "$_dir/.env.worktree" ]; then
    _off=$(pick_offset "$_dir") || exit 1
    write_env_worktree "$_dir" "$_off"
    announce_offset "$_off"
  fi
  rmdir "$_lock" 2>/dev/null
  trap - EXIT INT TERM
}

cmd_ensure() {
  _dir=$(abspath "${1:-.}") || die "no such dir: ${1:-.}"
  [ -f "$_dir/.env" ] || cp "$_dir/.env.example" "$_dir/.env" 2>/dev/null || true
  cmd_alloc "$_dir"
}

cmd_add() {
  _branch=${1:-}; _path=${2:-}
  [ -n "$_branch" ] || die "usage: worktree-ports.sh add <branch> [path]"
  if [ -z "$_path" ]; then
    _root=$(git rev-parse --show-toplevel) || die "not a git repo"
    _path="$(dirname "$_root")/$(basename "$_root")_$(sanitize "$_branch")"
  fi
  if git show-ref --verify --quiet "refs/heads/$_branch"; then
    git worktree add "$_path" "$_branch" || exit 1
  else
    git worktree add -b "$_branch" "$_path" || exit 1
  fi
  cmd_ensure "$_path"
  echo "worktree ready: $_path"
  echo "next: cd $_path && task worktree:init && task dev"
}

case "${1:-}" in
  ensure) shift; cmd_ensure "$@" ;;
  alloc)  shift; cmd_alloc "$@" ;;
  add)    shift; cmd_add "$@" ;;
  *) die "usage: worktree-ports.sh {ensure|alloc|add} ..." ;;
esac
