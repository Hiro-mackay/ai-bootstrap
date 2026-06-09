#!/bin/sh
# Vulnerability gate. Fails on a reachable (called) vulnerability in a
# DEPENDENCY -- that is actionable: update the module. Reachable vulnerabilities
# in the Go standard library are reported but NOT blocking: they track Go patch
# releases (not your code), so blocking PRs on them turns CI red on a schedule
# the author cannot control. The scheduled security-audit.yml is the deep monitor.
# Requires go + jq. Run from anywhere.
set -u

ROOT=$(CDPATH= cd "$(dirname "$0")/.." && pwd)
cd "$ROOT/backend" || exit 0

go install golang.org/x/vuln/cmd/govulncheck@latest

out=$(mktemp)
govulncheck -json ./... >"$out" 2>/dev/null || true

# Trace[0] is the vulnerable symbol; its module is "stdlib" for standard-library
# vulnerabilities and the dependency module path otherwise.
sel='.[] | objects | select(has("finding")) | .finding | select(.trace[0].function != null)'
deps=$(jq -s "[ $sel | select(.trace[0].module != \"stdlib\") | .osv ] | unique" "$out")
depn=$(printf '%s' "$deps" | jq 'length')
stdn=$(jq -s "[ $sel | select(.trace[0].module == \"stdlib\") | .osv ] | unique | length" "$out")

echo "Reachable vulnerabilities -- dependencies: ${depn:-0}, stdlib (informational): ${stdn:-0}"
rm -f "$out"

if [ "${depn:-0}" -gt 0 ]; then
  echo "Blocking: reachable vulnerability in a dependency:"
  printf '%s\n' "$deps"
  echo "Run 'govulncheck ./...' in backend/ and update the affected module."
  exit 1
fi
