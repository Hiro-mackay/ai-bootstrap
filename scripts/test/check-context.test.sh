#!/bin/sh
# Tests for scripts/check-context.sh -- the context-harness gate (#34).
# Completeness: Go domain/usecase anchors must carry @context + @business.
# Binding: every code @context must match a context defined in docs/domain-definitions.md.
# Vacuous: a placeholder-only domain-definitions.md with no domain code passes (start-anytime).
set -u

SCRIPT=$(CDPATH= cd "$(dirname "$0")/.." && pwd)/check-context.sh

fail=0
check() { # check <label> <expected exit: pass|fail> <actual exit code>
  _want=0
  [ "$2" = "fail" ] && _want=1
  if { [ "$2" = "pass" ] && [ "$3" -eq 0 ]; } || { [ "$2" = "fail" ] && [ "$3" -ne 0 ]; }; then
    echo "ok   - $1"
  else
    echo "FAIL - $1: expected $2 (exit $_want) got exit $3" >&2
    fail=1
  fi
}

tmp=$(mktemp -d) || { echo "mktemp -d failed" >&2; exit 1; }
trap 'rm -rf "${tmp}"' EXIT

# scaffold a minimal repo tree; $1 = bounded-context heading line for domain-definitions.md
scaffold() { # scaffold <context-heading>
  rm -rf "${tmp:?}/docs" "${tmp:?}/backend" "${tmp:?}/.git"
  mkdir -p "$tmp/docs" "$tmp/backend/internal/domain/entity" \
           "$tmp/backend/internal/usecase/storage/command"
  git -C "$tmp" init -q
  git -C "$tmp" config user.email "test@test" && git -C "$tmp" config user.name "test"
  cat > "$tmp/docs/domain-definitions.md" <<EOF
# Domain Definitions

## Bounded Contexts

$1

## Context Map
EOF
}

run() { ( cd "$tmp" && sh "$SCRIPT" >/dev/null 2>&1; echo $? ); }

# --- vacuous: placeholder context, no domain code -> pass ---
scaffold '### {{CONTEXT_NAME}}'
check "placeholder domain-definitions + no code -> pass" pass "$(run)"

# --- defined context + fully annotated entity -> pass ---
scaffold '### Storage'
cat > "$tmp/backend/internal/domain/entity/file.go" <<'EOF'
package entity

// @context Storage
// @business Lets a user store and retrieve files.
type File struct{ ID string }
EOF
check "annotated entity, context defined -> pass" pass "$(run)"

# --- entity missing annotations -> fail (completeness) ---
scaffold '### Storage'
printf 'package entity\n\ntype File struct{ ID string }\n' \
  > "$tmp/backend/internal/domain/entity/file.go"
check "unannotated entity -> fail (completeness)" fail "$(run)"

# --- @context not defined in domain-definitions.md -> fail (binding) ---
scaffold '### Storage'
cat > "$tmp/backend/internal/domain/entity/file.go" <<'EOF'
package entity

// @context Billing
// @business Charges the customer.
type File struct{ ID string }
EOF
check "undefined @context -> fail (binding)" fail "$(run)"

# --- usecase command anchor is checked too ---
scaffold '### Storage'
cat > "$tmp/backend/internal/usecase/storage/command/create_file.go" <<'EOF'
package command

type CreateFileCommand struct{}
EOF
check "unannotated usecase command -> fail (completeness)" fail "$(run)"

# --- _test.go is not an anchor ---
scaffold '### Storage'
printf 'package entity\n\ntype File struct{ ID string }\n' \
  > "$tmp/backend/internal/domain/entity/file_test.go"
check "_test.go is exempt -> pass" pass "$(run)"

# --- multi-word context name binds correctly (F1) ---
scaffold '### File Storage'
cat > "$tmp/backend/internal/domain/entity/file.go" <<'EOF'
package entity

// @context File Storage
// @business Stores files.
type File struct{ ID string }
EOF
check "multi-word @context, defined -> pass" pass "$(run)"

# --- @context with an extra token beyond a defined prefix must NOT pass (F1 drift) ---
scaffold '### Storage'
cat > "$tmp/backend/internal/domain/entity/file.go" <<'EOF'
package entity

// @context Storage Archive
// @business Archives files.
type File struct{ ID string }
EOF
check "@context 'Storage Archive' vs '### Storage' -> fail (no prefix match)" fail "$(run)"

# --- staleness surface: staged file with unchanged @business -> warns ---
scaffold '### Storage'
cat > "$tmp/backend/internal/domain/entity/file.go" <<'EOF'
package entity
// @context Storage
// @business Lets a user store and retrieve files.
type File struct{ ID string }
EOF
(cd "$tmp" && git add -A && git commit -qm init)
printf '// changed logic\n' >> "$tmp/backend/internal/domain/entity/file.go"
(cd "$tmp" && git add backend/internal/domain/entity/file.go)
stale_out=$( (cd "$tmp" && sh "$SCRIPT") 2>&1 )
case "$stale_out" in
  *"annotation content not updated"*) echo "ok   - staleness: warns when @business unchanged" ;;
  *) echo "FAIL - staleness: missing warning for unchanged @business" >&2; fail=1 ;;
esac

# --- staleness surface: updating @business surfaces unchanged @invariant in same file ---
scaffold '### Storage'
cat > "$tmp/backend/internal/domain/entity/file.go" <<'EOF'
package entity
// @context Storage
// @business Lets a user store and retrieve files.
// @invariant File MUST have an owner.
type File struct{ ID string }
EOF
(cd "$tmp" && git add -A && git commit -qm init)
cat > "$tmp/backend/internal/domain/entity/file.go" <<'EOF'
package entity
// @context Storage
// @business Updated description.
// @invariant File MUST have an owner.
type File struct{ ID string }
EOF
(cd "$tmp" && git add backend/internal/domain/entity/file.go)
stale_out=$( (cd "$tmp" && sh "$SCRIPT") 2>&1 )
case "$stale_out" in
  *"@invariant"*"updated in diff"*) echo "ok   - staleness: warns @invariant even when @business updated" ;;
  *) echo "FAIL - staleness: missed stale @invariant when @business changed" >&2; fail=1 ;;
esac

# --- staleness surface: two @invariant lines, one updated -> warns for unchanged one ---
scaffold '### Storage'
cat > "$tmp/backend/internal/domain/entity/file.go" <<'EOF'
package entity
// @context Storage
// @business Lets a user store and retrieve files.
// @invariant File MUST have an owner.
// @invariant File MUST NOT exceed 100MB.
type File struct{ ID string }
EOF
(cd "$tmp" && git add -A && git commit -qm init)
cat > "$tmp/backend/internal/domain/entity/file.go" <<'EOF'
package entity
// @context Storage
// @business Lets a user store and retrieve files.
// @invariant File MUST have a registered owner.
// @invariant File MUST NOT exceed 100MB.
type File struct{ ID string }
EOF
(cd "$tmp" && git add backend/internal/domain/entity/file.go)
stale_out=$( (cd "$tmp" && sh "$SCRIPT") 2>&1 )
case "$stale_out" in
  *"@invariant"*) echo "ok   - staleness: warns unchanged @invariant when other @invariant updated" ;;
  *) echo "FAIL - staleness: missed unchanged @invariant in multi-invariant file" >&2; fail=1 ;;
esac

# --- staleness surface: both annotations updated -> no warning ---
scaffold '### Storage'
cat > "$tmp/backend/internal/domain/entity/file.go" <<'EOF'
package entity
// @context Storage
// @business Original.
// @invariant File MUST have an owner.
type File struct{ ID string }
EOF
(cd "$tmp" && git add -A && git commit -qm init)
cat > "$tmp/backend/internal/domain/entity/file.go" <<'EOF'
package entity
// @context Storage
// @business Updated.
// @invariant File MUST have an updated owner.
type File struct{ ID string }
EOF
(cd "$tmp" && git add backend/internal/domain/entity/file.go)
stale_out=$( (cd "$tmp" && sh "$SCRIPT") 2>&1 )
case "$stale_out" in
  *"annotation content not updated"*) echo "FAIL - staleness: false warning when both annotations updated" >&2; fail=1 ;;
  *) echo "ok   - staleness: no warning when both annotations updated" ;;
esac

[ "$fail" -eq 0 ] && echo "check-context: all tests passed"
exit "$fail"
