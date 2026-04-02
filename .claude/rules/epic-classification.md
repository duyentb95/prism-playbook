# Epic Classification

> Not all work is the same. Classify before planning.

## Two Types

| Type | Signal | Design Phase? | Planning Entry |
|------|--------|---------------|----------------|
| **User-Oriented** | UI changes, new features, user-facing flows | **Required** — mockup + design approval before sprint | /plan → /design-consultation → /ceo-review → /eng-review |
| **Technical** | Refactoring, infra, performance, migrations, CI/CD | **Skip** — straight to sprint planning | /plan → /eng-review |

## Detection Rules

**User-Oriented if ANY of:**
- Creates or modifies UI components
- Changes user-visible behavior
- Adds a new page, form, or flow
- Modifies copy, labels, or notifications
- Involves responsive design or accessibility

**Technical if ALL of:**
- No user-visible changes
- Backend/infra/tooling only
- Performance optimization
- Database migration without UI impact
- CI/CD pipeline changes

## Gate Enforcement

### User-Oriented Epic
```
/plan → /design-consultation (or /design-shotgun) → design approval
     → /ceo-review → /eng-review → implement → /review → /ship
```

Design approval gate: user must see and approve mockup/wireframe before implementation begins.
Without design approval, implementation is BLOCKED.

### Technical Epic
```
/plan → /eng-review → implement → /review → /ship
```

No design phase. CEO review optional (skip if pure infra).

## How to Apply

When `/plan` starts, classify the epic:

```
Epic Classification: [USER-ORIENTED / TECHNICAL]
Reason: [1 sentence explaining why]
```

If uncertain, default to **User-Oriented** (safer — extra design review never hurts).
