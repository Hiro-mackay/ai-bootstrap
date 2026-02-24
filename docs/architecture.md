# Architecture

> This is the single source of truth for the current system design.
> For past decisions and rationale, see [ADRs](decisions/).

## System Overview

{{SYSTEM_OVERVIEW}}

## Component Architecture

{{COMPONENT_ARCHITECTURE}}

<!--
Example:
- **Frontend** -- React SPA served from CDN
- **API** -- REST API on Node.js/Express
- **Database** -- PostgreSQL with Prisma ORM
- **Queue** -- Redis-backed job queue
-->

## Data Flow

{{DATA_FLOW}}

<!--
Describe how data moves through the system.
Include key request/response flows and async processes.
-->

## Technology Stack

| Layer         | Technology | Notes |
|---------------|-----------|-------|
| Language      | {{LANG}}  |       |
| Framework     | {{FW}}    |       |
| Database      | {{DB}}    |       |
| Infrastructure| {{INFRA}} |       |
| CI/CD         | {{CICD}}  |       |

## Security Architecture

{{SECURITY_ARCHITECTURE}}

<!--
- Authentication method (JWT, session, OAuth)
- Authorization model (RBAC, ABAC, policy-based)
- Data encryption strategy (at rest, in transit)
- API security (rate limiting, CORS, input validation)
-->

## Cross-Cutting Concerns

### Logging

| Attribute | Value |
|-----------|-------|
| Format    | {{LOG_FORMAT}} |
| Levels    | {{LOG_LEVELS}} |
| Correlation ID | {{CORRELATION_ID_STRATEGY}} |

<!--
Example:
- Format: structured JSON
- Levels: DEBUG, INFO, WARN, ERROR
- Correlation ID: propagated via request header X-Request-ID
-->

### Monitoring

| Aspect | Configuration |
|--------|--------------|
| Metrics | {{METRICS_TOOL}} |
| Health checks | {{HEALTH_CHECK_ENDPOINTS}} |
| Alerting | {{ALERTING_STRATEGY}} |

<!--
Example:
- Metrics: Prometheus + Grafana dashboards
- Health checks: /healthz (liveness), /readyz (readiness)
- Alerting: PagerDuty for P1, Slack for P2+
-->

### Error Handling Strategy

| Boundary | Strategy |
|----------|----------|
| API boundary | {{API_ERROR_STRATEGY}} |
| Service boundary | {{SERVICE_ERROR_STRATEGY}} |
| Infrastructure | {{INFRA_ERROR_STRATEGY}} |

<!--
Example:
- API boundary: translate domain errors to HTTP status codes, never leak internals
- Service boundary: wrap with context, propagate error chain
- Infrastructure: retry with exponential backoff, circuit breaker after 3 failures
-->

### Incident Response

| Item | Location |
|------|----------|
| Runbooks | {{RUNBOOK_PATH}} |
| Postmortem template | {{POSTMORTEM_PATH}} |
| Escalation policy | {{ESCALATION_POLICY}} |

<!--
Example:
- Runbooks: docs/runbooks/
- Postmortem template: docs/runbooks/postmortem-template.md
- Escalation policy: on-call -> team lead -> engineering manager
-->

## Integration Points

{{INTEGRATION_POINTS}}

<!--
List external services and how the system interfaces with them.
Note which integrations require an Anti-Corruption Layer.

| External Service | Purpose | Integration Method | ACL Required |
|-----------------|---------|-------------------|-------------|
-->

## Infrastructure

{{INFRASTRUCTURE}}

<!--
Describe deployment topology, hosting, and infrastructure components.
-->
