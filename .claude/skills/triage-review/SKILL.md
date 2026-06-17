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

## 1. Resolve the PR and surface its context

If `$ARGUMENTS` is numeric, use it. Otherwise `gh pr view --json number,title,headRefName,url`.

Run `task context` (the change-time context surface, #34). For each touched bounded context it
prints `@business`/`@invariant` + the `docs/domain-definitions.md` block -- the **assumption the change must
respect**. Use it as a lens in the reviews below: does the diff break a recorded invariant, or
contradict the context's stated purpose? (Requirement correctness itself stays the human call in
§4 -- the surface informs it, it does not replace it.)

## 2. Independent reviews (one message, concurrent)

Spawn all three reviewers in a single message: A and C as Agent calls, B as a background Bash call. Do not synthesize until all three return.

### Reviewer A -- code-reviewer agent (always)

Runs the project's full review criteria: bugs, resilience, quality, over-engineering.

```
Agent({ subagent_type: "code-reviewer",
  description: "code-reviewer of PR #<n>",
  prompt: "Review the current branch diff against your standard criteria (review-local). \
Context: <one-paragraph PR brief>. Already-rejected findings (do NOT re-flag): <list>. \
findings-only -- do NOT implement fixes. \
Normalize each finding to: file:line, severity (blocker/major/minor/nit), recommendation." })
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
- **If not found**, skip Reviewer B and note in the report that this was a single-provider (Claude + security) review. Do not fail.

### Reviewer C -- security-reviewer agent (always)

Deep security audit: secrets, input validation, auth/authz, query construction, error leakage, outdated deps.

```
Agent({ subagent_type: "security-reviewer",
  description: "security-reviewer of PR #<n>",
  prompt: "Audit the current branch diff for security vulnerabilities. \
Context: <one-paragraph PR brief>. Already-rejected findings (do NOT re-flag): <list>. \
findings-only -- do NOT implement fixes. \
If nothing found, respond 'Clean' with the list of checks performed." })
```

## 3. Synthesize (no judgment)

Merge all three reviewers' outputs into one table; assign a **fix-priority** P0-P3 based on impact
(what breaks if ignored) and immediacy (does it bite this PR).

Add an **annotation-freshness lens** before merging: for each modified file that
carries `@business`/`@invariant`, check whether those annotation lines changed
proportionally to the logic change. If domain behavior appears to have shifted but
the annotation is identical to `origin/main`, flag it as a finding (P1 if an
invariant is affected, P2 otherwise). Use `task context -- --path <file>` to surface
the current annotation alongside the `domain-definitions.md` block. `severity` describes
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
