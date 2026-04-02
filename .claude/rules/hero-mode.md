# Hero Mode — Parallel Agent Execution

> Multiple agents, one branch, strict ownership lanes.

## When to Use

- Sprint has 3+ independent tasks across different areas (frontend, backend, infra, etc.)
- Tasks have clear file ownership boundaries
- Speed matters more than sequential review gates

## How It Works

```
Standard Mode:  Agent A → Agent B → Agent C  (sequential)
Hero Mode:      Agent A ─┐
                Agent B ─┼─ same branch, parallel  ─→ merge + review
                Agent C ─┘
```

## File Ownership Protocol

Each sub-agent MUST declare an `owns:` section in its task brief:

```markdown
## Ownership
owns:
  - src/api/**
  - prisma/migrations/**
  - shared/types/**
does-not-touch:
  - src/frontend/**
  - src/workers/**
```

### Rules

1. **Lane discipline is absolute.** An agent MUST NOT modify files outside its `owns:` paths. Read is OK; Edit/Write is NOT.

2. **Shared files require claims.** If two agents need the same file:
   - Add it to `.prism/CLAIMS.md` with agent name + expiry
   - First claim wins; second agent must wait or negotiate via Master-Agent
   - Claims expire when the agent's task status becomes DONE

3. **Conflict prevention over conflict resolution.** The goal is zero merge conflicts, not good merge conflict resolution.

## Claims Registry (.prism/CLAIMS.md)

```markdown
# File Claims

| File | Claimed By | Expires | Reason |
|------|-----------|---------|--------|
| shared/types/api.ts | TASK_001_api | On DONE | Adding new endpoint types |
| prisma/schema.prisma | TASK_001_api | On DONE | New migration |
```

### Claim Rules

- Claims are first-come-first-served
- Master-Agent resolves conflicts
- Claims auto-expire when task status → DONE
- Check CLAIMS.md BEFORE starting any task in Hero Mode

## Master-Agent Responsibilities in Hero Mode

1. **Decompose** tasks with non-overlapping file ownership
2. **Write CLAIMS.md** for any shared files before dispatching
3. **Launch agents in parallel** (single message, multiple Agent tool calls)
4. **Review all handovers** before merging to sprint branch
5. **Run integration check** after all agents complete

## Sub-Agent Additions for Hero Mode

Sub-agents in Hero Mode follow all standard sub-agent rules, PLUS:

- Read `owns:` from task brief → enforce as hard boundary
- Check `.prism/CLAIMS.md` before modifying any file not in `owns:`
- If you need a file outside your lane → Status: BLOCKED, explain in handover
- Include ownership compliance in checkpoint:
  ```
  ⏸️ CHECKPOINT — TASK_NNN @ [N] files changed
  Ownership: [CLEAN ✅ | VIOLATION ⚠️ — list files]
  ```

## Spawn Order (when dependencies exist)

If agents have dependencies (e.g., frontend needs API types):

```
Phase 1: Agent-API (creates types, schema)     ← runs first
Phase 2: Agent-Frontend (consumes API types)    ← runs after Phase 1
Phase 3: Agent-Workers (mirrors type defs)      ← runs after Phase 1
```

Declare dependencies in task briefs:
```markdown
## Dependencies
blocked-by: TASK_001_api (needs shared/types/api.ts)
```

Master-Agent dispatches Phase 1 first, then Phase 2+3 in parallel after Phase 1 completes.
