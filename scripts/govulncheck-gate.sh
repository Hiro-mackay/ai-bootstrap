#!/bin/sh
# Vulnerability gate. Fails on a reachable (called) vulnerability in a
# DEPENDENCY -- that is actionable: update the module. Reachable vulnerabilities
# in the Go standard library are reported but NOT blocking: they track Go patch
# releases (not your code), so blocking PRs on them turns CI red on a schedule
# the author cannot control. The scheduled security-audit.yml is the deep monitor.
# Requires go + jq. Run from anywhere.
set -u

command -v go >/dev/null 2>&1 || { echo "govulncheck-gate: go not found" >&2; exit 1; }
command -v jq >/dev/null 2>&1 || { echo "govulncheck-gate: jq not found" >&2; exit 1; }

ROOT=$(CDPATH= cd "$(dirname "$0")/.." && pwd)
cd "$ROOT/backend" || { echo "govulncheck-gate: backend/ not found" >&2; exit 1; }

go install golang.org/x/vuln/cmd/govulncheck@latest ||
  { echo "govulncheck-gate: failed to install govulncheck" >&2; exit 1; }

out=$(mktemp)
err=$(mktemp)
# -json exits 0 even when vulnerabilities are found, so a non-zero exit is a real
# tooling/package-load error -- fail loudly rather than report a false green.
if ! govulncheck -json ./... >"$out" 2>"$err"; then
  echo "govulncheck-gate: scan failed (not a vulnerability result):" >&2
  cat "$err" >&2
  rm -f "$out" "$err"
  exit 1
fi
rm -f "$err"

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
