---
name: triage-review
description: Review the current PR locally with Claude (and Codex if available), synthesize a prioritized report, let the user pick what to apply
user-invocable: true
disable-model-invocation: true
argument-hint: "[<pr#>]"
allowed-tools:
  - Bash
  - Read
  - Edit
  - Write
  - Agent
  - Skill
  - TaskCreate
  - TaskUpdate
  - AskUserQuestion
---

# /triage-review

Local, cross-provider review of the current PR -- this is the on-machine
equivalent of a CI review bot (no CI minutes, no API-key-gated workflow). Get one
or two independent reviews, synthesize into a single prioritized report, and let
**the user** decide what to act on. The assistant does not adjudicate which
findings are correct.

## 1. Resolve the PR

If `$ARGUMENTS` is numeric, use it. Otherwise `gh pr view --json number,title,headRefName,url`.

## 2. Independent reviews (one message, concurrent)

### Reviewer A -- Claude `/review` (always)

```
Agent({ subagent_type: "general-purpose",
  description: "Claude /review of PR #<n>",
  prompt: "Invoke the local /review skill (Skill tool, skill=\"review\") against the PR diff. \
Context: <one-paragraph PR brief>. Already-rejected findings (do NOT re-flag): <list>. \
Return: file:line, severity (blocker/major/minor/nit), recommendation. Do NOT implement fixes." })
```

### Reviewer B -- Codex adversarial review (if the openai-codex plugin is installed)

Detect: `find ~/.claude/plugins -name codex-companion.mjs 2>/dev/null | head -1`.
- **If found**, run it in the background as a skeptical second opinion:
  ```
  Bash({ run_in_background: true,
    command: 'node "<companion-path>" adversarial-review --wait --base origin/main --scope branch "<same PR context + already-rejected list>"',
    description: "Codex adversarial-review of PR #<n>" })
  ```
  Wait for the completion notification; read its output file (the `# Codex Adversarial Review` block).
- **If not found**, skip Reviewer B and note in the report that this was a single-provider (Claude-only) review. Do not fail.

Run A and B in a single message so they execute concurrently; do not synthesize until both return.

## 3. Synthesize (no judgment)

Merge both outputs into one table; assign a **fix-priority** P0-P3 based on impact
(what breaks if ignored) and immediacy (does it bite this PR). `severity` describes
the issue; `fix-priority` is how strongly to act now -- they can diverge.

| Label | Meaning |
|---|---|
| P0 | must-fix this PR (breakage, security, data loss) |
| P1 | strongly recommended this PR (latent regression, missing guard) |
| P2 | nice-to-have (refactor, naming) |
| P3 | note only (nit, taste) |

```
| # | Finding (file:line, summary) | Source(s) | Severity | Fix-priority | Recommendation |
```

Print the full table before asking. Do not mark adopt/reject or filter "false positives" -- that is the user's call.

## 4. User decides

`AskUserQuestion` with `multiSelect: true`, options grouped by priority (P0/P1 first).
Honor free-text ("P0 only, rest as issues", "defer all", etc.). If only P3 remain,
ask once whether to act on any.

## 5. Apply the selection

For each chosen finding: `TaskCreate` (in_progress) -> Edit/Write the fix -> scoped
checks (`task check` + `task go:test`/`task react:test`) -> one atomic commit
(`fix:` behavioral, `refactor:` cleanup, `docs:` doc-only; never `--amend` published
commits or `--force`) -> `TaskUpdate` completed. Checks fail mid-fix -> new task -> loop.

## 6. Push & annotate

After all selected fixes land and `task check` is green: `git push`, then record the
audit trail on the PR:

```
gh pr comment <#> --body "## /triage-review pass <N>
### Applied
- <finding> (commit <sha>)
### Deferred (user choice)
- <finding>
"
```

## 7. Loop or close

Another pass -> back to §2 on the new diff. Otherwise:

> Triage complete. {N} applied, {M} deferred. Ready for merge.
