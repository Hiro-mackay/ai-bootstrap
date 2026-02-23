# Project Constitution

This constitution defines the non-negotiable principles for this project.
Every decision, review, and implementation must align with these articles.

Articles are ordered by priority. Customize to match your team's standards,
but think carefully before removing -- these exist because violations are costly.

---

## Part 1: Development Process

### Article I: Specs Before Implementation

No feature work begins without a written spec.
Use the SDD workflow (`/new-spec`) to create specs from templates.
Specs live in `docs/specs/` and must be reviewed before implementation starts.

- A spec defines the problem, user stories, and acceptance criteria
- Implementation without a spec is rework waiting to happen
- Bug fixes require at minimum: problem statement + reproduction steps

### Article II: Tests Are Executable Specs

Every acceptance criterion must have a corresponding test.
Tests are the proof that a spec has been fulfilled, not an afterthought.

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

---

## Part 2: Architecture

### Article IV: Architecture.md Is the Single Source of Truth

`docs/architecture.md` describes the current system design.
All structural decisions are reflected there. It is always up to date.

- Past decisions and rationale are recorded as ADRs in `docs/decisions/`
- If the code disagrees with architecture.md, one of them must be fixed immediately
- Significant architectural changes require an ADR before implementation

### Article V: Dependencies Point Inward

Domain/core logic must never depend on infrastructure, frameworks, or external services.

- Interfaces are defined in the domain layer; implementations live in infrastructure
- External dependencies are wrapped behind abstractions at the boundary
- This ensures the core is testable, portable, and framework-independent

### Article VI: Explicit Over Implicit

Favor explicitness in all design choices. Hidden behavior creates hidden bugs.

- Pass dependencies explicitly (injection), not through global state
- Propagate context explicitly for tracing, cancellation, and timeouts
- Make data flow visible -- avoid magic values, implicit conversions, and side effects
- Comments explain "why", not "what" -- code should be readable on its own

---

## Part 3: Security

### Article VII: No Hardcoded Secrets

Secrets, API keys, and credentials must never appear in source code or commit history.

- Use environment variables or a secret management tool
- `.env` files are gitignored; use `.env.example` to document required variables
- Pre-commit hooks detect accidental secret commits
- If a secret is committed, rotate it immediately -- do not just delete it

### Article VIII: Defense in Depth

Security is layered, not optional. No single layer is sufficient alone.

- Input validation at system boundaries (user input, external APIs)
- Authentication and authorization enforced at the application layer
- Data encrypted in transit (TLS) and at rest where required
- Audit logging for security-relevant actions (who, what, when, from where)
- Never log secrets or personally identifiable information

---

## Part 4: Code Quality

### Article IX: Maximize Type Safety

Use the language's type system to its fullest extent.
Types are documentation that the compiler enforces.

- Avoid `any`, `interface{}`, `Object`, or equivalent escape hatches
- Prefer explicit type annotations over inference at public boundaries
- Use union types, enums, or sum types to make invalid states unrepresentable
- Type errors are bugs caught for free -- do not suppress them

### Article X: Errors Are Never Silent

Every error must be handled explicitly. Silent failures are the most expensive bugs.

- Never discard errors with `_`, empty `catch`, or equivalent
- Wrap errors with context so the origin is traceable
- Fail fast -- surface errors early rather than propagating corrupted state
- Use structured error types, not raw strings, for programmatic handling

### Article XI: Files Under 300 Lines

No source file should exceed 300 lines.

- Large files signal a need to decompose into smaller, focused modules
- This keeps code navigable for both humans and AI assistants
- If a file approaches the limit, split by responsibility before it grows further
