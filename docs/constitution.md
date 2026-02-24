# Project Constitution

This constitution defines the non-negotiable principles for this project.
Every decision, review, and implementation must align with these articles.

Articles are ordered by priority. Customize to match your team's standards,
but think carefully before removing -- these exist because violations are costly.

## Part 1: Development Process

### Article I: Specs Before Implementation

No feature work begins without a written spec.
Specs are created from templates in `docs/specs/` and must be reviewed before implementation starts.

- A spec defines the problem, user stories, and acceptance criteria
- Implementation without a spec is rework waiting to happen
- Bug fixes require at minimum: problem statement + reproduction steps
- Specs are scoped to a single bounded context as defined in `docs/prd.md` -- cross-context changes go through the context map

### Article II: Tests Are Executable Specs

Every acceptance criterion must have a corresponding test.

- Write the test before or alongside the implementation (TDD/Red-Green-Refactor)
- A feature is not complete until all spec-defined tests pass
- Tests describe behavior in Given/When/Then structure
- Each test is independent -- no shared mutable state, no execution order dependency

### Article III: Atomic Commits, Conventional Format

Every commit is a self-contained, meaningful unit of change.

- Format: `type(scope): description` (feat, fix, refactor, test, docs, chore)
- Each commit leaves the codebase in a working state
- One concern per commit -- do not mix feature code with refactoring
- Breaking changes declared in commit footer

## Part 2: Architecture

### Article IV: Architecture.md Is the Single Source of Truth

`docs/architecture.md` describes the current system design.
All structural decisions are reflected there. It is always up to date.

- Past decisions and rationale are recorded as ADRs in `docs/decisions/`
- If the code disagrees with architecture.md, one of them must be fixed immediately
- Significant architectural changes require an ADR before implementation
- Product boundaries and domain models are defined in `docs/prd.md`

### Article V: Dependencies Point Inward

Domain/core logic must never depend on infrastructure, frameworks, or external services.

- Interfaces are defined in the domain layer; implementations live in infrastructure
- External dependencies are wrapped behind abstractions at the boundary

### Article VI: Aggregate Design Discipline

Aggregates are the consistency boundary of the domain model.

- One aggregate = one transaction boundary
- Reference other aggregates by ID only
- Keep aggregates small; enforce invariants in the aggregate root
- Domain events: past tense, published after state change succeeds
- Eventual consistency is default; strong consistency requires ADR

### Article VII: Explicit Over Implicit

Hidden behavior creates hidden bugs. Favor explicitness in all design choices.

- Pass dependencies explicitly (injection), not through global state
- Propagate context explicitly for tracing, cancellation, and timeouts
- Make data flow visible -- avoid magic values, implicit conversions, and side effects

## Part 3: Security

### Article VIII: No Hardcoded Secrets

Secrets, API keys, and credentials must never appear in source code or commit history.

- Use environment variables or a secret management tool
- `.env` files are gitignored; use `.env.example` to document required variables
- Pre-commit hooks detect accidental secret commits
- If a secret is committed, rotate it immediately -- do not just delete it

### Article IX: Defense in Depth

Security is layered. No single defense is sufficient alone.

- Input validation at system boundaries (user input, external APIs)
- Authentication and authorization enforced at the application layer
- Data encrypted in transit (TLS) and at rest where required
- Audit logging for security-relevant actions (who, what, when, from where)
- Never log secrets or personally identifiable information

## Part 4: Code Quality

### Article X: Maximize Type Safety

The type system is documentation that the compiler enforces.

- Avoid `any`, `interface{}`, `Object`, or equivalent escape hatches
- Prefer explicit type annotations over inference at public boundaries
- Use union types, enums, or sum types to make invalid states unrepresentable

### Article XI: Errors Are Never Silent

Every error must be handled explicitly.

- Never discard errors with `_`, empty `catch`, or equivalent
- Wrap errors with context so the origin is traceable
- Fail fast -- surface errors early rather than propagating corrupted state
- Use structured error types, not raw strings, for programmatic handling

### Article XII: Dependency Discipline

New external dependencies require justification.

- Evaluate maintenance status, license, and security posture before adoption
- Prefer standard library solutions when adequate
- Document the reason for each non-trivial dependency in the plan
- Keep dependencies up to date -- known vulnerabilities are treated as bugs

### Article XIII: Files Under 300 Lines

No source file should exceed 300 lines.
Large files signal insufficient decomposition and hinder both human review and automated analysis.
