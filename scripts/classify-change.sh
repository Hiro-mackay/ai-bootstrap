#!/bin/sh
# Change classifier for the approve model (#31). Routes a branch's diff into
#   AUTO    -- confined + mechanizable oracle + evidence-complete; auto-merge-eligible
#   CONFIRM -- human-held oracle (domain) / unconfined / missing evidence / new behavior
#   DECIDE  -- an ADR / governance trigger; a human decides and records it
# This is a CATEGORIZER, not a gate: it always exits 0 and prints a CLASS= line.
# The dominant risk is false-AUTO, so every ambiguity falls to a human (CONFIRM).
# Module-path independent, POSIX sh, zero deps. Usage: classify-change.sh [base] [type]
set -u

base="${1:-origin/main}"
type="${2:-}"
if [ -z "$type" ]; then
  branch=$(git rev-parse --abbrev-ref HEAD 2>/dev/null || echo "")
  type=$(printf '%s' "$branch" | sed -n 's#^\([a-z]*\)/.*#\1#p')
fi

files=$(git diff --name-only "$base"...HEAD 2>/dev/null || true)
has() { printf '%s\n' "$files" | grep -qE "$1"; }
nfiles=$(printf '%s\n' "$files" | grep -c . || true)

# --- ADR / governance triggers (.claude/rules/sdd.md ADR list) -> DECIDE ---
adr=""
has '(^|/)go\.(mod|sum)$'         && adr="$adr dep:go"
has '(^|/)package\.json$'         && adr="$adr dep:js"
has '\.sql$'                      && adr="$adr schema:sql"
has '(^|/)migrations?/'           && adr="$adr schema:migration"
has '^proto/'                     && adr="$adr proto"
has '(^|/)compose.*\.ya?ml$'      && adr="$adr infra:compose"
has '(^|/)Taskfile\.ya?ml$'       && adr="$adr infra:taskfile"
has '^scripts/'                   && adr="$adr infra:scripts"
has '^\.claude/'                  && adr="$adr governance:claude"
has '^docs/decisions/'            && adr="$adr governance:adr"
has '^docs/(constitution|prd|architecture|harness)\.md$' && adr="$adr governance:docs"

# --- Oracle location: domain layer is a human-held oracle ---
domain=0
has '^backend/internal/domain/' && domain=1

# --- Confinement: a single observable region, not spanning features/stacks ---
nfeat=$(printf '%s\n' "$files" | sed -n 's#^frontend/src/features/\([^/]*\)/.*#\1#p' | sort -u | grep -c . || true)
touches_be=0; has '^backend/'  && touches_be=1
touches_fe=0; has '^frontend/' && touches_fe=1
unconfined=0
[ "$nfeat" -gt 1 ] && unconfined=1
[ "$touches_be" = 1 ] && [ "$touches_fe" = 1 ] && unconfined=1

# --- Evidence: a fix must ship a regression guard to be auto-eligible ---
has_test=0
has '(_test\.go|\.test\.(ts|tsx))$' && has_test=1

# --- Decision: ordered, first match wins, conservative default CONFIRM ---
class="CONFIRM"
reason="default to a human"
if [ -n "$adr" ]; then
  class="DECIDE";  reason="ADR/governance trigger:$adr"
elif [ "$domain" = 1 ]; then
  class="CONFIRM"; reason="domain layer touched (human-held oracle)"
elif [ "$unconfined" = 1 ]; then
  class="CONFIRM"; reason="unconfined (multiple features or backend+frontend)"
else
  case "$type" in
    refactor|docs|chore|test)
      class="AUTO"; reason="$type, confined" ;;
    fix)
      if [ "$has_test" = 1 ]; then
        class="AUTO";    reason="fix, confined, regression test present"
      else
        class="CONFIRM"; reason="fix without a test (no regression guard)"
      fi ;;
    *)
      class="CONFIRM"; reason="${type:-unknown} defaults to a human (new behavior = spec correctness)" ;;
  esac
fi

printf 'change classifier (#31)\n'
printf '  base:   %s\n' "$base"
printf '  type:   %s\n' "${type:-<none>}"
printf '  files:  %s\n' "$nfiles"
printf '  reason: %s\n' "$reason"
printf 'CLASS=%s\n' "$class"
