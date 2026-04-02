# Gate Status

> Flow: Plan → CEO Review → Eng Review → [Implement] → Review → Ship
> Each gate must pass before the next phase begins.
> /gsd bypasses all gates for tasks < 15 min.

## Feature: (none)
**Branch:** —
**Started:** —
**Mode:** Standard | Hero

## Gates

- [ ] plan-approved — /plan completed, user said GO
- [ ] ceo-locked — /ceo-review completed
- [ ] eng-locked — /eng-review completed
- [ ] review-passed — /review completed
- [ ] dod-passed — Definition of Done met (see below)
- [ ] shipped — /ship completed

## Definition of Done

> "Implemented" (AI pass) ≠ "Done" (human sign-off).
> ALL categories must pass before marking dod-passed.

| # | Category | Check | Status |
|---|----------|-------|--------|
| 1 | **Code Quality** | Zero lint/type errors, build passes, no warnings | [ ] |
| 2 | **Runtime Stability** | App starts cleanly, no crash on happy path | [ ] |
| 3 | **Testing** | Unit tests pass, regression test for bugs, edge cases covered | [ ] |
| 4 | **Review** | /review or /paranoid-review passed | [ ] |
| 5 | **Documentation** | README/CLAUDE.md/CHANGELOG updated if needed | [ ] |
| 6 | **Design Alignment** | UI matches mockup/spec (if frontend) | [ ] |
| 7 | **Human Sign-Off** | User confirmed in browser/terminal — not just AI check | [ ] |
| 8 | **Deploy Ready** | /ship succeeds, no blocked dependencies | [ ] |

### Task Lifecycle

```
Todo → In Progress → Implemented (AI pass) → Refining → Done (human sign-off)
```

- **Implemented**: AI checks pass (build, lint, tests). NOT done yet.
- **Refining**: Human reviewing, testing in browser, requesting adjustments.
- **Done**: Human explicitly signs off. Only then does it count toward velocity.

## GSD Log

<!-- /gsd bypasses append here -->
