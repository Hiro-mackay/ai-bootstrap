#!/bin/sh
# Context surface (#34; see docs/context-harness.md). For a change, prints the in-code context annotations of the
# touched files PLUS the matching bounded-context block from docs/domain-definitions.md -- the product context a
# human or agent needs at change-time. Deterministic adjacency, no retrieval. Always exits 0.
# POSIX sh, zero deps.
#   context.sh [base]          surface for the diff vs base (default origin/main)
#   context.sh --path <path>   surface for a single path
set -u

if [ "${1:-}" = "--path" ]; then
  files="${2:-}"
else
  base="${1:-origin/main}"
  files=$(git diff --name-only "$base"...HEAD 2>/dev/null || true)
fi

ann='@\(context\|business\|invariant\)[[:space:]]'
strip='s#^[[:space:]]*\(//\|\*\|/\*\*\?\)[[:space:]]*##'

# Only the documented annotation carriers are surfaced, so fixtures/docs/examples that merely
# mention the tags (e.g. scripts/test/*.test.sh) are never injected as real product context.
is_carrier() {
  case "$1" in
    backend/internal/domain/*.go|backend/internal/usecase/*.go) return 0 ;;
    frontend/src/features/*.ts|frontend/src/features/*.tsx) return 0 ;;
    *) return 1 ;;
  esac
}

printf 'context surface (#34)\n'

any=0
contexts=""
oldifs=$IFS
IFS='
'
for f in $files; do
  [ -n "$f" ] || continue
  is_carrier "$f" || continue
  [ -f "$f" ] || continue
  if grep -q "$ann" "$f" 2>/dev/null; then
    printf '\n--- %s ---\n' "$f"
    grep "$ann" "$f" | sed "$strip"
    any=1
    # full @context value (may contain spaces/hyphens), trimmed, one per line
    cvals=$(grep '@context[[:space:]]' "$f" \
      | sed -n 's/^.*@context[[:space:]][[:space:]]*//p' | sed 's/[[:space:]][[:space:]]*$//')
    contexts="$contexts
$cvals"
  fi
done
IFS=$oldifs

if [ "$any" -eq 0 ]; then
  printf '(no annotated context touched)\n'
  exit 0
fi

contexts=$(printf '%s\n' "$contexts" | sed '/^$/d' | sort -u)
IFS='
'
for c in $contexts; do
  [ -n "$c" ] || continue
  block=$(awk -v c="$c" '
    $0 ~ "^### "c"$" {f=1; print; next}
    f && /^(### |## )/ {f=0}
    f {print}
  ' docs/domain-definitions.md 2>/dev/null)
  if [ -n "$block" ]; then
    printf '\n=== docs/domain-definitions.md -- %s ===\n%s\n' "$c" "$block"
  fi
done
IFS=$oldifs
exit 0
