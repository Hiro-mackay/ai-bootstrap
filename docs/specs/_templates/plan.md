# Plan: {{FEATURE_NAME}}

## Spec Reference

[Spec](./spec.md)

## Architecture Decisions

List any architectural decisions this feature requires.
Create ADRs in `docs/decisions/` for significant choices.

- ...

## Implementation Approach

Describe the high-level approach to implementing this feature.

## Component Breakdown

### Component 1: {{NAME}}

- **Purpose**: ...
- **Location**: ...
- **Changes**: ...

### Component 2: {{NAME}}

- **Purpose**: ...
- **Location**: ...
- **Changes**: ...

## Architecture Compliance

### Layer Assignment

| Component | Layer | Directory | Justification |
|-----------|-------|-----------|---------------|
| ... | Domain / Application / Infrastructure / Presentation | ... | ... |

> Reference: project's stack doc (docs/stacks/go-ddd.md or docs/stacks/react-bun.md)

### Compliance Checklist

#### Go DDD (delete if React-only)

- [ ] Domain entities use exported fields with behavior methods (no getter ceremony)
- [ ] No JSON/DB tags on domain types (tags on interface DTOs only)
- [ ] Domain layer has no imports from infrastructure or interface
- [ ] Value Objects for typed values (no raw primitives for domain concepts)
- [ ] UseCase layer uses Command/Query with Execute + Input/Output structs
- [ ] TransactionManager interface in domain, WithTransaction in UseCase layer
- [ ] Structured error handling via AppError (not sentinel errors only)
- [ ] DTOs for all API request/response bodies (request/ and response/ subdirectories)
- [ ] Repository interface in domain, implementation in infrastructure with BaseRepository

#### React (delete if Go-only)

- [ ] Frontend components scoped to feature directories (no feature-specific code in components/ui/)
- [ ] No barrel exports (index.ts) -- all imports use direct file paths
- [ ] Data fetching uses TanStack Query with connect-query (auto-managed keys from proto definitions)
- [ ] API types generated from schema (protobuf via `buf generate`, no manual API type definitions)
- [ ] Client state in Zustand, server state in TanStack Query (never mixed)
- [ ] Form validation uses Zod schemas composed from lib/validation/schemas.ts primitives
- [ ] Mutations invalidate related queries in onSuccess
- [ ] No cross-feature internal imports
- [ ] Routes with server data define `loader` using `createQueryOptions` + `prefetchQuery`
- [ ] Page components use `useSuspenseQuery` for primary data, wrapped in `<Suspense>` at route level

> Intentional violations require ADR.

## API Changes

Describe any API additions or modifications.

## Data Model Changes

Describe any database schema or data structure changes.

## Domain Model Changes

### Aggregate Design

Describe new or modified aggregates, their boundaries, and invariants.

### Domain Event Flow

| Event | Published By | Consumed By | Trigger |
|-------|-------------|-------------|---------|
| ...   | ...         | ...         | ...     |

## Non-Functional Requirements Strategy

Map each NFR from the spec to a concrete technical approach.

| NFR | Technical Approach |
|-----|--------------------|
| ... | ... |

## Codebase Alignment

Existing patterns identified during research and how this plan aligns with or deviates from them.

- ...

## Risk Assessment

| Risk | Impact | Likelihood | Mitigation |
|------|--------|-----------|------------|
| ...  | High/Med/Low | High/Med/Low | ... |

## Dependencies

- ...

## Out of Scope

- ...
