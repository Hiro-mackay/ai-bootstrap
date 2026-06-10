#!/bin/sh
# Tests for scripts/classify-change.sh -- the approve-model classifier (#31).
# Each case builds a diff of a known shape and asserts its CLASS. The classifier
# defaults to a human (CONFIRM); only confined + mechanizable + evidence-complete
# changes reach AUTO; ADR/governance triggers force DECIDE.
set -u

SCRIPT=$(CDPATH= cd "$(dirname "$0")/.." && pwd)/classify-change.sh

fail=0
check() { # check <label> <expected> <actual>
  if [ "$2" = "$3" ]; then
    echo "ok   - $1"
  else
    echo "FAIL - $1: expected '$2' got '$3'" >&2
    fail=1
  fi
}

tmp=$(mktemp -d)
trap 'rm -rf "$tmp"' EXIT
cd "$tmp" || exit 1
git init -q .
git config user.email t@t.t
git config user.name t
echo seed > seed.txt
git add -A
git commit -qm base
git tag base

# class_of <type> <file>... : stage the files, commit, classify against `base`
class_of() {
  _type=$1
  shift
  for f in "$@"; do
    mkdir -p "$(dirname "$f")"
    echo x > "$f"
  done
  git add -A >/dev/null 2>&1
  git commit -qm c >/dev/null 2>&1
  sh "$SCRIPT" base "$_type" 2>/dev/null | sed -n 's/^CLASS=//p'
  git reset -q --hard base
  git clean -qfd
}

# --- AUTO: confined + mechanizable + evidence-complete ---
check "refactor, single feature -> AUTO" AUTO \
  "$(class_of refactor frontend/src/features/todo/list.tsx)"
check "fix with a test -> AUTO" AUTO \
  "$(class_of fix frontend/src/features/todo/api.ts frontend/src/features/todo/api.test.ts)"
check "docs (non-governance) -> AUTO" AUTO \
  "$(class_of docs docs/stacks/react.md)"
check "chore, confined -> AUTO" AUTO \
  "$(class_of chore frontend/src/features/todo/util.ts)"

# --- CONFIRM: human-held oracle / unconfined / missing evidence / new behavior ---
check "fix without a test -> CONFIRM" CONFIRM \
  "$(class_of fix frontend/src/features/todo/api.ts)"
check "feat -> CONFIRM (new behavior = spec correctness)" CONFIRM \
  "$(class_of feat frontend/src/features/todo/create.tsx)"
check "domain layer touched -> CONFIRM" CONFIRM \
  "$(class_of refactor backend/internal/domain/order.go)"
check "two features -> CONFIRM (unconfined)" CONFIRM \
  "$(class_of refactor frontend/src/features/a/x.tsx frontend/src/features/b/y.tsx)"
check "backend + frontend -> CONFIRM (unconfined)" CONFIRM \
  "$(class_of refactor backend/internal/usecase/x.go frontend/src/features/a/x.tsx)"

# --- DECIDE: ADR / governance triggers ---
check "go.mod (new dep) -> DECIDE" DECIDE \
  "$(class_of fix backend/go.mod backend/go.sum)"
check "proto schema -> DECIDE" DECIDE \
  "$(class_of feat proto/todo/v1/todo.proto)"
check "Taskfile (infra) -> DECIDE" DECIDE \
  "$(class_of chore Taskfile.yml)"
check "scripts (harness infra) -> DECIDE" DECIDE \
  "$(class_of refactor scripts/foo.sh)"
check ".claude governance -> DECIDE" DECIDE \
  "$(class_of docs .claude/rules/sdd.md)"
check "sql schema -> DECIDE" DECIDE \
  "$(class_of fix backend/internal/infrastructure/query.sql)"

[ "$fail" -eq 0 ] && echo "classify-change: all tests passed"
exit "$fail"
