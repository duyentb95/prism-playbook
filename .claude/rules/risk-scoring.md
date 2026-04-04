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
