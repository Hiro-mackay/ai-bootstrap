#!/bin/sh
# Tests for scripts/context.sh -- the change-time context surface (#34).
set -u

SCRIPT=$(CDPATH= cd "$(dirname "$0")/.." && pwd)/context.sh

fail=0
check() { # check <label> <expected-substring|!absent> <output>
  if [ "$2" = "!annotated" ]; then
    case "$3" in *"no annotated context touched"*) echo "ok   - $1" ;; *) echo "FAIL - $1" >&2; fail=1 ;; esac
  else
    case "$3" in *"$2"*) echo "ok   - $1" ;; *) echo "FAIL - $1: missing '$2'" >&2; fail=1 ;; esac
  fi
}

tmp=$(mktemp -d)
trap 'rm -rf "$tmp"' EXIT
cd "$tmp" || exit 1
git init -q .
git config user.email t@t.t
git config user.name t

mkdir -p docs backend/internal/domain/entity
cat > docs/domain-definitions.md <<'EOF'
# Domain Definitions

## Bounded Contexts

### Storage

**Responsibility**: owns files and folders.

#### Aggregates
- Invariants: File MUST be in Uploading status to be Activated.

### Billing

**Responsibility**: charges customers.

## Context Map
EOF
cat > backend/internal/domain/entity/file.go <<'EOF'
package entity

// @context Storage
// @business Lets a user store and retrieve files.
// @invariant File MUST be in Uploading status to be Activated.
type File struct{ ID string }
EOF
printf 'README\n' > README.md
git add -A
git commit -qm base
git tag base

# --- touching the annotated entity surfaces its @business and the domain-definitions Storage block ---
printf '// touched\n' >> backend/internal/domain/entity/file.go
git add -A; git commit -qm c
out=$(sh "$SCRIPT" base 2>/dev/null)
check "surfaces @business" "Lets a user store and retrieve files." "$out"
check "surfaces domain-definitions context block" "owns files and folders." "$out"
check "does not pull an untouched context" "Storage" "$out"  # Storage present...
case "$out" in *"charges customers"*) echo "FAIL - leaked Billing block" >&2; fail=1 ;; *) echo "ok   - no untouched-context leak" ;; esac
git reset -q --hard base; git clean -qfd

# --- touching a non-annotated file surfaces nothing ---
printf 'x\n' >> README.md
git add -A; git commit -qm c
check "no annotation -> notice" "!annotated" "$(sh "$SCRIPT" base 2>/dev/null)"
git reset -q --hard base; git clean -qfd

# --- --path mode ---
check "--path surfaces annotations" "@business Lets a user store" \
  "$(sh "$SCRIPT" --path backend/internal/domain/entity/file.go 2>/dev/null)"

# --- a non-carrier file with annotation tokens is NOT surfaced (F3) ---
mkdir -p scripts/test
cat > scripts/test/fixture.test.sh <<'EOF'
# @context Storage
# @business fixture string, not real product context
EOF
git add -A; git commit -qm c
check "fixture file not surfaced" "!annotated" "$(sh "$SCRIPT" base 2>/dev/null)"
check "--path on fixture not surfaced" "!annotated" \
  "$(sh "$SCRIPT" --path scripts/test/fixture.test.sh 2>/dev/null)"
git reset -q --hard base; git clean -qfd

[ "$fail" -eq 0 ] && echo "context: all tests passed"
exit "$fail"
