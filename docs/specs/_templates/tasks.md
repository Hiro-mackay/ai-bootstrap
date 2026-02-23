# Tasks: {{FEATURE_NAME}}

## References

- [Spec](../{{FEATURE_SLUG}}/spec.md)
- [Plan](../{{FEATURE_SLUG}}/plan.md)

## Task Breakdown

### Phase 1: Setup

- [ ] Task 1.1: ...
- [ ] Task 1.2: ...

### Phase 2: Core Implementation

- [ ] Task 2.1: ...
  - Depends on: 1.1
- [ ] Task 2.2: ...
  - Depends on: 1.2

### Phase 3: Integration

- [ ] Task 3.1: ...
  - Depends on: 2.1, 2.2

### Phase 4: Testing

- [ ] Task 4.1: Write unit tests
  - Depends on: 2.1, 2.2
- [ ] Task 4.2: Write integration tests
  - Depends on: 3.1

### Phase 5: Documentation

- [ ] Task 5.1: Update architecture.md if needed
- [ ] Task 5.2: Update README if needed

## Estimation Guidance

| Size  | Description                  | Typical Duration |
|-------|------------------------------|-----------------|
| S     | Single file, isolated change | < 1 hour        |
| M     | 2-3 files, minor integration | 1-4 hours       |
| L     | Multiple files, new patterns | 4-8 hours       |
| XL    | Cross-cutting, new systems   | 1-3 days        |
