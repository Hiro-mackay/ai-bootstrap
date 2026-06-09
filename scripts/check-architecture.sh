#!/bin/sh
# Architecture fitness tests -- computational sensors for the rules in
# docs/constitution.md and .claude/rules/sdd.md that generic linters do NOT catch.
# Module-path independent (matches import path suffixes), POSIX sh, zero deps.
# Exit 1 on any violation. Run from the repo root.
set -u

fail=0
report() { # $1 = message, $2 = violations (empty = ok)
  if [ -n "$2" ]; then
    printf '\n[ARCH] %s\n%s\n' "$1" "$2"
    fail=1
  fi
}

go_imports() { # $1 = dir, $2 = forbidden-layer regex
  [ -d "$1" ] || return 0
  grep -rEn "\"[^\"]*/internal/($2)" "$1" --include='*.go' 2>/dev/null \
    | grep -v '_test.go:' || true
}

# --- Go layering: dependencies point inward (constitution Article V) ---
report "domain must not import infrastructure/interface/usecase/gen" \
  "$(go_imports backend/internal/domain 'infrastructure|interface|usecase|gen')"
report "usecase must not import infrastructure/interface/gen" \
  "$(go_imports backend/internal/usecase 'infrastructure|interface|gen')"
report "interface must not import infrastructure (wire in cmd/ instead)" \
  "$(go_imports backend/internal/interface 'infrastructure')"
report "infrastructure must not import interface/usecase" \
  "$(go_imports backend/internal/infrastructure 'interface|usecase')"

# --- Frontend: no barrel files (sdd.md gate i) ---
# routes/ legitimately uses index.tsx for file-based routing (the "/" route).
report "barrel files are banned (use direct file path imports)" \
  "$(find frontend/src -type f \( -name 'index.ts' -o -name 'index.tsx' \) 2>/dev/null \
      | grep -v '/gen/' | grep -v '/routes/' || true)"

# --- Frontend: no cross-feature internal imports (sdd.md gate n) ---
crossfeat="$(grep -rEn "from ['\"]@/features/" frontend/src/features --include='*.ts' --include='*.tsx' 2>/dev/null \
  | while IFS= read -r line; do
      file=$(printf '%s' "$line" | cut -d: -f1)
      own=$(printf '%s' "$file" | sed -E 's#.*/features/([^/]+)/.*#\1#')
      imp=$(printf '%s' "$line" | sed -E "s#.*from ['\"]@/features/([^/'\"]+).*#\1#")
      [ "$own" != "$imp" ] && printf '%s -> @/features/%s\n' "$file" "$imp"
    done || true)"
report "features must not import another feature's internals (share via lib/)" "$crossfeat"

# --- File size (constitution Article XIII: under 300 lines) ---
toolong="$(find backend frontend/src -type f \
    \( -name '*.go' -o -name '*.ts' -o -name '*.tsx' \) \
    ! -path '*/gen/*' ! -path '*/sqlcgen/*' \
    ! -name '*_pb.*' ! -name '*.gen.ts' 2>/dev/null \
  | while IFS= read -r f; do
      n=$(wc -l < "$f" | tr -d ' ')
      [ "$n" -gt 300 ] && printf '%s (%s lines)\n' "$f" "$n"
    done || true)"
report "source files must stay under 300 lines" "$toolong"

# --- Domain purity: no serialization tags in domain types (sdd.md gate b) ---
report "domain types must not carry json/db/gorm struct tags (DTOs live in the interface layer)" \
  "$(grep -rEn '(json|db|gorm):"' backend/internal/domain --include='*.go' 2>/dev/null | grep -v '_test.go:' || true)"

# --- Frontend: no manual queryKey ARRAY (sdd.md gate j) ---
# Bans hand-built key arrays (`queryKey: ['todos', id]`); allows the documented
# `queryKey: createConnectQueryKey(...)` invalidation and createQueryOptions usage.
report "manual queryKey arrays are banned (use createQueryOptions / createConnectQueryKey)" \
  "$(grep -rEn 'queryKey:[[:space:]]*\[' frontend/src --include='*.ts' --include='*.tsx' 2>/dev/null | grep -v '/gen/' || true)"

# --- Frontend: server state must not live in Zustand stores (sdd.md gate k) ---
report "stores/ must not hold server state (server state belongs in TanStack Query)" \
  "$(grep -rEn '(useQuery|useSuspenseQuery|createQueryOptions|useTransport|fetch\(|axios)' frontend/src/stores --include='*.ts' --include='*.tsx' 2>/dev/null || true)"

# --- Escape hatches: no lint suppression in frontend source (Go side: nolintlint) ---
report "no lint-suppression directives (biome-ignore / @ts-ignore / @ts-nocheck / eslint-disable)" \
  "$(grep -rEn 'biome-ignore|@ts-ignore|@ts-nocheck|eslint-disable' frontend/src --include='*.ts' --include='*.tsx' 2>/dev/null | grep -vE '/gen/|\.gen\.ts' || true)"

# --- Escape hatches: no TODO/FIXME left in frontend source (Go side: godox) ---
report "no TODO/FIXME in frontend source (track it in a spec or issue instead)" \
  "$(grep -rEn 'TODO|FIXME' frontend/src --include='*.ts' --include='*.tsx' 2>/dev/null | grep -vE '/gen/|\.gen\.ts' || true)"

if [ "$fail" -ne 0 ]; then
  printf '\nArchitecture fitness tests FAILED.\n' >&2
  exit 1
fi
echo "Architecture fitness tests passed."
