#!/bin/sh
# Context surface (#34, ADR-001). For a change, prints the in-code context annotations of the
# touched files PLUS the matching bounded-context block from docs/prd.md -- the product context a
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

printf 'context surface (#34)\n'

any=0
contexts=""
oldifs=$IFS
IFS='
'
for f in $files; do
  [ -n "$f" ] || continue
  [ -f "$f" ] || continue
  if grep -q "$ann" "$f" 2>/dev/null; then
    printf '\n--- %s ---\n' "$f"
    grep "$ann" "$f" | sed "$strip"
    any=1
    for v in $(grep -oE '@context[[:space:]]+[A-Za-z][A-Za-z0-9_]*' "$f" | sed 's/@context[[:space:]]*//'); do
      case " $contexts " in *" $v "*) ;; *) contexts="$contexts $v" ;; esac
    done
  fi
done
IFS=$oldifs

if [ "$any" -eq 0 ]; then
  printf '(no annotated context touched)\n'
  exit 0
fi

for c in $contexts; do
  block=$(awk -v c="$c" '
    $0 ~ "^### "c"$" {f=1; print; next}
    f && /^(### |## )/ {f=0}
    f {print}
  ' docs/prd.md 2>/dev/null)
  if [ -n "$block" ]; then
    printf '\n=== docs/prd.md -- %s ===\n%s\n' "$c" "$block"
  fi
done
exit 0
