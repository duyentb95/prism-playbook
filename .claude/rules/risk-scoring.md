# Risk Scoring Framework

> Four-dimension risk analysis for tool calls and code changes.

## Four Dimensions

Every significant action is scored across 4 dimensions:

### 1. Base Risk (tool inherent danger)

| Tool/Action | Score |
|-------------|-------|
| Read, Grep, Glob | 0 (read-only) |
| Edit (< 10 lines) | 1 |
| Write (new file) | 2 |
| Edit (> 50 lines) | 3 |
| Bash (safe: git status, ls) | 1 |
| Bash (builds: npm install, cargo build) | 2 |
| Bash (destructive: rm, git push) | 5 |

### 2. File Sensitivity

| File Pattern | Score |
|-------------|-------|
| .md, .txt, docs/ | 0 |
| Source code (.ts, .py, .rs) | 1 |
| Config (.json, .yaml, .toml) | 2 |
| Schema/migration (prisma, sql) | 3 |
| Auth/security (auth.*, middleware.*) | 4 |
| Secrets (.env, *.key, *.pem, credentials) | 5 |

### 3. Blast Radius

| Scope | Score |
|-------|-------|
| 1 file | 0 |
| 2-3 files, same module | 1 |
| 4-10 files, same module | 2 |
| 10+ files or cross-module | 3 |
| Shared types/interfaces used by many modules | 4 |
| Global config or entry point | 5 |

### 4. Irreversibility

| Reversibility | Score |
|--------------|-------|
| Easily undone (git checkout, revert edit) | 0 |
| Undoable with effort (git revert, rollback) | 1 |
| Hard to undo (published package, sent email) | 3 |
| Irreversible (data deletion, force push to shared branch) | 5 |

## Composite Score

```
Risk = max(Base, Sensitivity) + Blast + Irreversibility
```

| Score | Action |
|-------|--------|
| 0-3 | **ALLOW** — proceed silently |
| 4-6 | **REVIEW** — mention risk in output, proceed |
| 7-9 | **CONFIRM** — AskUserQuestion before proceeding |
| 10+ | **BLOCK** — refuse without explicit user override |

## Hybrid Assessment — Fallback Chain

Don't compute full risk scores for everything. Use pattern-first with fallback:

```
1. PATTERN MATCH (instant)
   Known risky patterns → immediate score
   e.g., "rm -rf" = 10, ".env write" = 8, "auth file edit" = 7

2. HISTORICAL MATCH (fast)
   Check .prism/knowledge/GOTCHAS.md — has this pattern burned us before?
   If match → boost score by +2, cite the gotcha

3. HEURISTIC SCORE (standard)
   Compute 4-dimension score (base × sensitivity × blast × irreversibility)
   This is the default path for novel situations

4. CONTEXTUAL FALLBACK (slow)
   If heuristic score is 4-6 (ambiguous zone) — read surrounding code for context
   e.g., "DELETE without WHERE" in a migration file = 3 (intentional), in app code = 9 (bug)
```

**Rule:** Most operations hit step 1 or 3. Steps 2 and 4 only fire for edge cases. Don't over-analyze low-risk operations.

## When to Apply

- Before refactoring that touches >5 files
- Before modifying auth/security code
- Before destructive bash commands (already handled by /careful, this adds scoring)
- Before writing to config/schema files
- In /review and /paranoid-review findings (severity calibration)

## Integration with Existing Skills

- **code-review**: Use sensitivity score to prioritize findings (auth files get more scrutiny)
- **ship**: Calculate aggregate risk for the entire PR before pushing
- **investigate**: Use irreversibility score when proposing fixes (prefer reversible approaches)
- **safety/careful**: Use composite score alongside destructive pattern matching
