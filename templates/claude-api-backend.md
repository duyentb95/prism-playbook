# CLAUDE.md — PRISM Playbook (API Backend)

## How to Work

1. **ASK before doing** — Don't jump to code. Ask: "What's the data model? Who consumes this API?"
2. **Design before build** — Present schema, endpoints, error handling. Wait for approval.
3. **Plan before execute** — Break into micro-tasks (2-10 min each). Type GO to start.
4. **Small tasks → just do it** — Bug fixes, config changes: no planning needed (GSD mode).

## Project Context

**What**: [e.g., REST API for mobile app / GraphQL gateway / Internal microservice]
**Why**: [Why does it exist? What does it enable?]
**Who**: [Who consumes it — frontend team? mobile app? third-party developers?]
**Stack**: [e.g., Node.js + Express / Python + FastAPI / Go + Chi / Rust + Axum]
**Database**: [e.g., PostgreSQL / MongoDB / SQLite / Redis]
**Auth**: [e.g., JWT / OAuth2 / API keys / Session-based]
**Testing**: [e.g., Jest + Supertest / pytest / go test]
**Deploy**: [e.g., Docker + K8s / Railway / AWS Lambda]

## API Standards

### Data & Schema
- Validate all input at the boundary (request body, query params, path params)
- Use database transactions for multi-step mutations
- Migrations must be reversible (or explicitly documented as not)
- Money: integer cents or Decimal — never floating point
- Dates: UTC everywhere, timezone conversion only at display layer

### Error Handling
- External API calls: set timeouts, implement retry with backoff
- Never swallow errors silently — log with context
- Partial failures: if step 3 fails, roll back steps 1-2
- Return structured error responses: `{ error: string, code: string, details?: object }`

### Security
- No raw SQL with string interpolation — use parameterized queries
- Rate limiting on auth endpoints
- No secrets in code — use environment variables
- Auth middleware on every protected route
- No sensitive data in logs (passwords, tokens, PII)

### Performance
- No N+1 queries — use JOINs or batch loading
- Paginate all list endpoints (no unbounded queries)
- Connection pools bounded (no leak on error path)
- Index frequently queried columns

## Knowledge

- Read `.prism/knowledge/` before starting — patterns and traps from previous sessions.
- After learning something new, append to:
  - `RULES.md` — API patterns, naming conventions, error formats
  - `GOTCHAS.md` — database quirks, auth edge cases, deployment issues
  - `TECH_DECISIONS.md` — why we chose DB X, why this auth strategy

## Session Handoff

If conversation gets long: write state to `.prism/STAGING.md`, start fresh session.
