# Domain Definitions

This document defines the **domain** -- bounded contexts, ubiquitous language, aggregates, and
invariants. It is the "what and where" counterpart to `docs/architecture.md` (the "how").

**Definitions only.** Product requirements, goals, and feature-why are NOT recorded here -- they
stay a human judgment at change-time (the spec-correctness gate; see #34). What lives here is the
stable domain vocabulary that code annotations (`@context` / `@invariant`, see `docs/stacks/`) bind
to and `task context` surfaces.

## Domain Overview

{{DOMAIN_OVERVIEW}}

## Subdomains

| Subdomain | Type | Bounded Context | Notes |
|-----------|------|-----------------|-------|
<!--
Classification guide:
- Core: competitive advantage, build in-house, highest investment
- Supporting: necessary but not differentiating, build or buy
- Generic: commodity, prefer off-the-shelf (auth, payments, email)
-->
| {{SUBDOMAIN}} | Core / Supporting / Generic | {{CONTEXT}} | {{NOTES}} |
| {{SUBDOMAIN}} | Core / Supporting / Generic | {{CONTEXT}} | {{NOTES}} |

## Ubiquitous Language

| Term | Definition | Context |
|------|------------|---------|
| {{TERM}} | {{DEFINITION}} | {{BOUNDED_CONTEXT}} |
| {{TERM}} | {{DEFINITION}} | {{BOUNDED_CONTEXT}} |
| {{TERM}} | {{DEFINITION}} | {{BOUNDED_CONTEXT}} |

<!--
Lifecycle rules:
- New terms: add with definition and owning context before using in specs or code
- Scope: a term's meaning is authoritative only within its bounded context
- Deprecation: mark as [DEPRECATED] with replacement term; remove after migration
-->

## Bounded Contexts

### {{CONTEXT_NAME}}

**Responsibility**: {{WHAT_THIS_CONTEXT_OWNS}}

#### Aggregates

**{{AGGREGATE_ROOT}}**
- Root Entity: {{AGGREGATE_ROOT}}
- Entities: {{ENTITY_1}}, {{ENTITY_2}}
- Value Objects: {{VO_1}}, {{VO_2}}
- Invariants: {{INVARIANT}}
<!-- Invariant format: Subject MUST/MUST NOT condition. Example: "Order MUST have at least one line item" -->
- Domain Events: {{EVENT_1}}, {{EVENT_2}}

### {{CONTEXT_NAME}}

**Responsibility**: {{WHAT_THIS_CONTEXT_OWNS}}

#### Aggregates

**{{AGGREGATE_ROOT}}**
- Root Entity: {{AGGREGATE_ROOT}}
- Entities: {{ENTITY_1}}, {{ENTITY_2}}
- Value Objects: {{VO_1}}, {{VO_2}}
- Invariants: {{INVARIANT}}
<!-- Invariant format: Subject MUST/MUST NOT condition. Example: "Order MUST have at least one line item" -->
- Domain Events: {{EVENT_1}}, {{EVENT_2}}

## Context Map

| Upstream | Downstream | Relationship | Downstream Pattern |
|----------|------------|-------------|-------------------|
| {{CONTEXT_A}} | {{CONTEXT_B}} | {{TYPE}} | {{PATTERN}} |
| {{CONTEXT_A}} | {{CONTEXT_B}} | {{TYPE}} | {{PATTERN}} |

Relationship types: Partnership, Shared Kernel, Customer-Supplier, Conformist, Separate Ways.
Upstream patterns: Open Host Service (public API), Published Language (shared schema).
Downstream patterns: Conformist (accept as-is), Anti-Corruption Layer (translate at boundary).

## Domain Events

<!--
Naming convention: {BoundedContext}.{Aggregate}{PastTenseVerb}
Examples: Orders.OrderPlaced, Shipping.ShipmentDispatched

Minimal event schema:
- eventId: unique identifier
- eventType: the event name
- aggregateId: source aggregate ID
- occurredAt: ISO 8601 timestamp
- payload: event-specific data
-->

| Event | Aggregate | Published When | Consumed By |
|-------|-----------|---------------|-------------|
| {{CONTEXT}}.{{AGGREGATE}}{{PAST_TENSE_VERB}} | {{AGGREGATE}} | {{TRIGGER}} | {{CONSUMER}} |
