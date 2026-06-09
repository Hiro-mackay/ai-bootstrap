#!/bin/sh
# Coverage gate for the domain layer -- where business rules and invariants live
# and where tests matter most. Other layers (usecase orchestration, infra, cmd)
# are covered by shipped tests + the inferential review, not a hard gate.
# Passes when there is nothing to measure yet (pristine template), so it only
# bites once real domain logic exists. Threshold via COVERAGE_THRESHOLD.
set -u

THRESHOLD=${COVERAGE_THRESHOLD:-80}
ROOT=$(CDPATH= cd "$(dirname "$0")/.." && pwd)
cd "$ROOT/backend" || exit 0

pkgs=$(go list ./internal/domain/... 2>/dev/null)
[ -n "$pkgs" ] || { echo "coverage: no domain packages yet -- skip"; exit 0; }

profile=$(mktemp)
# shellcheck disable=SC2086
if ! go test $pkgs -coverprofile="$profile" >/dev/null 2>&1; then
  echo "coverage: domain tests failed" >&2
  rm -f "$profile"; exit 1
fi

# No coverable statements yet (e.g. only declarations) -> nothing to enforce.
blocks=$(grep -v '^mode:' "$profile" 2>/dev/null | wc -l | tr -d ' ')
if [ "${blocks:-0}" -eq 0 ]; then
  echo "coverage: no coverable domain statements yet -- skip"
  rm -f "$profile"; exit 0
fi

total=$(go tool cover -func="$profile" 2>/dev/null | awk '/^total:/ {gsub("%","",$3); print $3}')
rm -f "$profile"

ti=${total%.*}
if [ "${ti:-0}" -lt "$THRESHOLD" ]; then
  echo "coverage: domain ${total}% < ${THRESHOLD}% required" >&2
  exit 1
fi
echo "coverage: domain ${total}% >= ${THRESHOLD}% OK"
