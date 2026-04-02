# Reuse-First Methodology

> SEARCH FIRST, WRITE LATER.
> Before creating anything new, verify existing code doesn't already solve the problem.

## The Rule

Before writing a new component, hook, utility, service, or helper:

1. **Check the Reuse Map** in CLAUDE.md (if the project has one)
2. **Grep the codebase** for similar patterns
3. **Only create new code** if nothing reusable exists

## Reuse Map Template

Projects should maintain a Reuse Map in their CLAUDE.md. Template:

```markdown
## Reuse Map

### Frontend
- `@/components/ui/*` — Shared UI components (buttons, dialogs, inputs)
- `@/hooks/use-*` — Custom hooks (check before writing a new one)
- `@/lib/api-client.ts` — HTTP client (don't create a second one)
- `@/lib/utils.ts` — Common utilities

### Backend
- `src/common/base-*.ts` — Base classes for CRUD services/controllers
- `src/common/decorators/*` — Custom decorators
- `src/common/filters/*` — Exception filters
- `src/common/interceptors/*` — Response interceptors

### Shared
- `shared/types/*` — Cross-stack type definitions
- `shared/constants/*` — Shared constants and enums
```

## When /init-prism Sets Up a Project

The Reuse Map starts empty. As the project grows, append entries when:
- A reusable component is created
- A utility is extracted
- A shared pattern emerges

## Anti-Patterns

- Creating `utils2.ts` because you didn't check `utils.ts`
- Writing a custom fetch wrapper when api-client already exists
- Adding a new date formatting function when one exists in utils
- Duplicating types that are already in shared/
