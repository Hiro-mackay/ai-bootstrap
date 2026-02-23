# Project Constitution

This constitution defines the non-negotiable rules for this project.
Customize these articles to match your team's standards.

---

## Article I: Specs Before Implementation

No feature work begins without a written spec.
Use the SDD workflow (`/new-spec`) to create specs from templates.
Specs live in `docs/specs/` and must be reviewed before implementation starts.

## Article II: Tests Validate Specs

Every acceptance criterion in a spec must have a corresponding test.
Tests are the executable proof that the spec has been fulfilled.
A feature is not complete until all spec-defined tests pass.

## Article III: Architecture.md Is the Single Source of Truth

`docs/architecture.md` describes the current system design.
All structural decisions are reflected there.
Past decisions and their rationale are recorded as ADRs in `docs/decisions/`.

## Article IV: No Hardcoded Secrets

Secrets, API keys, and credentials must never appear in source code.
Use environment variables or secret management tools.
`.env` files are gitignored; use `.env.example` for documentation.

## Article V: Files Under 300 Lines

No source file should exceed 300 lines.
Large files are a signal to decompose into smaller, focused modules.
This keeps code readable for both humans and AI assistants.
