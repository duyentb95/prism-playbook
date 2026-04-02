# Phase-Based Refactoring — Risk Tiers

> Not all refactoring is equal. Classify by risk before starting.

## Three Phases

### Phase A: Quick Wins (Low Risk)
Can be done as part of any task. No separate review needed.

- Rename variables/functions for clarity
- Extract duplicate code into shared helper
- Remove dead code (unused imports, unreachable branches)
- Fix inconsistent formatting/naming
- Replace magic numbers with named constants
- Remove stale comments/TODOs

**Blast radius:** Single file. No behavior change.
**Auto-fixable in /review:** Yes.

### Phase B: Structural (Medium Risk)
Requires its own task brief. Review recommended.

- Extract method/function from large function (>50 lines → smaller units)
- Introduce parameter objects (>3 params → single options object)
- Flatten nested conditionals (>3 levels deep)
- Replace conditional with polymorphism
- Move function to a more appropriate module
- Consolidate duplicate logic across files

**Blast radius:** Multiple files in same module. Behavior preserved.
**Needs /review before merge:** Yes.

### Phase C: Architectural (High Risk)
Requires plan + review gate. User approval mandatory.

- Extract new module/service from existing code
- Change data flow between modules
- Replace inheritance hierarchy with composition
- Introduce new abstraction layer
- Migrate to different library/pattern
- Split monolith module into separate concerns

**Blast radius:** Cross-module. May change interfaces.
**Needs /plan + /eng-review + /review:** Yes.

## Decision Flow

```
Refactoring request
  ↓
"Does it change behavior?"
  YES → Not refactoring. It's a feature/fix. Use standard flow.
  NO ↓
"How many files?"
  1 file → Phase A (do it inline)
  2-5 files, same module → Phase B (own task)
  5+ files or cross-module → Phase C (plan first)
```

## Clean Code Thresholds

Reference numbers for when refactoring is warranted:

| Metric | Ideal | Acceptable | Refactor |
|--------|-------|-----------|----------|
| Function length | < 20 lines | < 50 lines | > 50 lines |
| Parameters | 0-2 | 3 | > 3 |
| Nesting depth | 1-2 levels | 3 levels | > 3 levels |
| Cyclomatic complexity | 1-5 | 6-10 | > 10 |
| File length | < 200 lines | < 400 lines | > 400 lines |
| Duplicate blocks | 0 | 1 (2 occurrences) | 3+ occurrences |

## Integration with /review

When `/review` or `/paranoid-review` finds maintainability issues:
- Phase A issues → AUTO-FIX inline
- Phase B issues → Flag as INFORMATIONAL with "Refactor opportunity (Phase B)"
- Phase C issues → Flag as NEEDS-TASK with suggested task brief
