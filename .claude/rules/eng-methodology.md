# Engineering Methodology

> Principles for working with AI-assisted development (Claude Code).

## Completeness Principle — "Boil the Lake"

With Claude Code, the marginal cost of completeness is near-zero.

**Rule:** If Option A is complete (100% coverage, all edge cases, full tests) and Option B
is a shortcut (80% coverage, happy path only), **always choose Option A**.

- The delta between 80 and 150 lines of code is meaningless with CC
- Test coverage is the cheapest lake to boil — skipping tests defers work, it doesn't save it
- "We'll add that later" = "We'll forget about that later"

**Exception:** Prototypes and spikes are explicitly incomplete. Label them as such.

## Effort Compression Quotes

When presenting options to the user, **always show both human and CC effort estimates**:

```
Option A: Full implementation with tests
  Human: ~2 weeks  |  CC: ~1 hour  |  Completeness: 10/10

Option B: MVP, happy path only
  Human: ~3 days   |  CC: ~30 min  |  Completeness: 6/10
```

This helps the user understand:
- The real cost of shortcuts (CC makes "doing it right" nearly free)
- When the shortcut is genuinely justified (prototype, throwaway code)
- The ~100x compression ratio on boilerplate tasks

## AskUserQuestion Enhancement

When asking users to choose between approaches, include:

1. **Re-ground** (1-2 sentences of context)
2. **Simplify** (explain like you would to a smart 16-year-old)
3. **Recommend** with one-line reason
4. **Completeness score** (1-10 for each option)
5. **Effort estimates** (human vs CC for each option)

## Cognitive Patterns

Mental models for making engineering decisions:

| # | Pattern | Meaning |
|---|---------|---------|
| 1 | State diagnosis first | Understand the current state before proposing changes |
| 2 | Blast radius instinct | How many things break if this goes wrong? |
| 3 | Boring by default | Choose the boring, proven technology unless there's a compelling reason not to |
| 4 | Incremental over revolutionary | Strangler fig pattern > big bang rewrite |
| 5 | Systems over heroes | Design for tired humans at 3am, not peak performance |
| 6 | Reversibility preference | Feature flags > hard migrations. Easy to undo > hard to undo |
| 7 | Error budgets over uptime | 99.9% SLO = 0.1% budget to ship fast |
| 8 | Measure before optimize | Profile first, gut feelings are usually wrong about bottlenecks |
| 9 | Contract boundaries | Define interfaces between modules, not just within them |
| 10 | Fail loud, recover quiet | Errors should be visible, recovery should be automatic |
