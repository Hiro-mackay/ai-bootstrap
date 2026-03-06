# Tasks: {{FEATURE_NAME}}

## References

- [Spec](./spec.md)
- [Plan](./plan.md)

## Task Breakdown

### Phase 1: Setup

- [ ] Task 1.1: ...
  - Layer: N/A
  - Files: ...
  - Acceptance: ...

### Phase 2: Domain Layer (TDD -- write failing test first)

- [ ] Task 2.1: ...
  - Layer: Domain
  - Test: ...
  - Files: ...
  - Acceptance: behavior methods, invariants enforced, no infra imports
  - Depends on: 1.1

### Phase 3: Application Layer

- [ ] Task 3.1: ...
  - Layer: Application
  - Test: ...
  - Files: ...
  - Acceptance: orchestration only, Command/Query structs, DTOs for queries
  - Depends on: 2.1

### Phase 4: Infrastructure Layer

- [ ] Task 4.1: ...
  - Layer: Infrastructure
  - Test: ...
  - Files: ...
  - Acceptance: single concern per file, implements domain interface
  - Depends on: 2.1

<!-- Phases 3 and 4 can run in parallel (both depend on 2.1, not on each other) -->

### Phase 5: Presentation Layer

- [ ] Task 5.1: ...
  - Layer: Presentation
  - Test: ...
  - Files: ...
  - Acceptance: DTOs for all I/O, no domain types in API surface, feature-scoped components
  - Depends on: 3.1, 4.1

### Phase 6: Integration & E2E Tests

- [ ] Task 6.1: Write integration tests
  - Files: ...
  - Depends on: 5.1
- [ ] Task 6.2: Write E2E tests (if applicable)
  - Files: ...
  - Depends on: 5.1

### Phase 7: Documentation

- [ ] Task 7.1: Update architecture.md if needed
  - Files: ...
- [ ] Task 7.2: Update README if needed
  - Files: ...
