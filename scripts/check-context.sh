#!/bin/sh
# Context-harness gate (#34, ADR-001). Enforces the in-code context annotations against the
# domain definitions in docs/prd.md. The anti-rot mechanism: annotations are declaration-local
# (move with the code) AND a missing/stale one fails the commit.
#   completeness -- each Go domain/usecase ANCHOR carries @context + @business
#   binding      -- every code @context value matches a context defined in docs/prd.md
# Vacuous by design: a placeholder-only prd with no domain code passes (start-anytime).
# POSIX sh, zero deps. Exit 1 on any violation. Run from the repo root.
set -u

fail=0
report() { # $1 = message, $2 = violations (empty = ok)
  if [ -n "$2" ]; then
    printf '\n[CONTEXT] %s\n%s\n' "$1" "$2"
    fail=1
  fi
}

# --- defined bounded contexts: ### headings under "## Bounded Contexts" in prd.md (drop placeholders) ---
defined=""
if [ -f docs/prd.md ]; then
  defined=$(sed -n '/^## Bounded Contexts/,/^## /p' docs/prd.md \
    | grep '^### ' | sed 's/^### *//' | sed 's/[[:space:]]*$//' | grep -v '{{' || true)
fi

# --- anchors: aggregate-root entities + usecase commands/queries (exclude tests) ---
anchors=$(
  { find backend/internal/domain/entity -maxdepth 1 -name '*.go' 2>/dev/null
    find backend/internal/usecase -type f -name '*.go' 2>/dev/null | grep -E '/(command|query)/'
  } | grep -v '_test\.go$' || true
)

# --- completeness: each anchor must carry @context and @business ---
missing=""
oldifs=$IFS
IFS='
'
for f in $anchors; do
  [ -n "$f" ] || continue
  if ! grep -q '@context[[:space:]]' "$f" || ! grep -q '@business[[:space:]]' "$f"; then
    missing="$missing$f (needs @context + @business)
"
  fi
done
IFS=$oldifs
report "anchors missing @context/@business (aggregate-root entity / usecase command|query)" "$missing"

# --- binding: every code @context value must be a defined context ---
used=$(grep -rhoE '@context[[:space:]]+[A-Za-z][A-Za-z0-9_]*' backend --include='*.go' 2>/dev/null \
  | sed 's/@context[[:space:]]*//' | sort -u || true)
unbound=""
IFS='
'
for v in $used; do
  [ -n "$v" ] || continue
  if ! printf '%s\n' "$defined" | grep -qxF "$v"; then
    unbound="$unbound@context $v -- not a bounded context in docs/prd.md
"
  fi
done
IFS=$oldifs
report "@context not defined in docs/prd.md (typo or stale context)" "$unbound"

if [ "$fail" -ne 0 ]; then
  printf '\nContext-harness checks FAILED.\n' >&2
  exit 1
fi
echo "Context-harness checks passed."
