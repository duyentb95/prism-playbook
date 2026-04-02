# Maintainability Specialist Review Checklist

Scope: Always-on (every review)
Output: JSON objects, one finding per line. Schema:
{"severity":"INFORMATIONAL","confidence":N,"path":"file","line":N,"category":"maintainability","summary":"...","fix":"...","fingerprint":"path:line:maintainability","specialist":"maintainability"}
If no findings: output `NO FINDINGS` and nothing else.

---

## Clean Code Thresholds

Flag as INFORMATIONAL when exceeded:

| Metric | Ideal | Acceptable | Flag |
|--------|-------|-----------|------|
| Function length | < 20 lines | < 50 lines | > 50 lines |
| Parameters | 0-2 | 3 | > 3 (suggest options object) |
| Nesting depth | 1-2 levels | 3 levels | > 3 (suggest early return/extract) |
| File length | < 200 lines | < 400 lines | > 400 (suggest splitting) |
| Duplicate blocks | 0 | 2 occurrences | 3+ (suggest extract helper) |

**Readability principle:** Code is read 10x more than written. Optimize for the reader.
- Names should reveal intent (no abbreviations unless universally understood)
- Functions should do one thing (Single Responsibility)
- No comments needed if names are clear enough

---

## Categories

### Dead Code & Unused Imports
- Variables assigned but never read in the changed files
- Functions/methods defined but never called (check with Grep across the repo)
- Imports/requires that are no longer referenced after the change
- Commented-out code blocks (either remove or explain why they exist)

### Magic Numbers & String Coupling
- Bare numeric literals used in logic (thresholds, limits, retry counts) — should be named constants
- Error message strings used as query filters or conditionals elsewhere
- Hardcoded URLs, ports, or hostnames that should be config
- Duplicated literal values across multiple files

### Stale Comments & Docstrings
- Comments that describe old behavior after the code was changed in this diff
- TODO/FIXME comments that reference completed work
- Docstrings with parameter lists that don't match the current function signature
- ASCII diagrams in comments that no longer match the code flow

### DRY Violations
- Similar code blocks (3+ lines) appearing multiple times within the diff
- Copy-paste patterns where a shared helper would be cleaner
- Configuration or setup logic duplicated across test files
- Repeated conditional chains that could be a lookup table or map

### Conditional Side Effects
- Code paths that branch on a condition but forget a side effect on one branch
- Log messages that claim an action happened but the action was conditionally skipped
- State transitions where one branch updates related records but the other doesn't
- Event emissions that only fire on the happy path, missing error/edge paths

### Module Boundary Violations
- Reaching into another module's internal implementation (accessing private-by-convention methods)
- Direct database queries in controllers/views that should go through a service/model
- Tight coupling between components that should communicate through interfaces
