# Spec: {{FEATURE_NAME}}

## Status

Draft | In Review | Approved | Implemented

## Bounded Context

{{BOUNDED_CONTEXT}} (as defined in `docs/prd.md`)

## Overview

{{BRIEF_DESCRIPTION}}

## Problem Statement

What problem does this solve? Why is it needed now?

## User Stories

### Story 1: {{STORY_TITLE}}

As a {{ROLE}}, I want to {{ACTION}}, so that {{BENEFIT}}.

#### Acceptance Criteria

- **Given** {{PRECONDITION}}
  **When** {{ACTION}}
  **Then** {{EXPECTED_RESULT}}

- **Given** {{PRECONDITION}}
  **When** {{ACTION}}
  **Then** {{EXPECTED_RESULT}}

## Functional Requirements

- [ ] FR-1: ...
- [ ] FR-2: ...

## Non-Functional Requirements

- [ ] NFR-1: Performance -- ...
- [ ] NFR-2: Security -- ...
- [ ] NFR-3: Accessibility -- ...

## Boundaries

### Always Do

- ...

### Ask First

- ...

### Never Do

- ...

## Technical Constraints

- ...

<!--
Constraints on how the feature must be implemented.
Examples: "Use SSE instead of WebSocket", "All external calls via ACL",
"Optimistic locking required for this aggregate"
-->

## Domain Impact

### Affected Aggregates

- {{AGGREGATE}}: {{WHAT_CHANGES}}

### Domain Events

- Published: {{EVENT}} (triggered by {{CONDITION}})
- Consumed: {{EVENT}} (from {{SOURCE_CONTEXT}})

### Ubiquitous Language Additions

| Term | Definition | Context |
|------|------------|---------|

## Open Questions

- [NEEDS CLARIFICATION] ...
- [NEEDS CLARIFICATION] ...
