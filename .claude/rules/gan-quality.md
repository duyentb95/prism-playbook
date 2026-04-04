# GAN Quality Framework

> Generative Adversarial quality loop. Three agents in deliberate tension.

## The Pattern

```
USER BRIEF
    ↓
PLANNER (ambitious)
    ↓ expanded spec with 10+ features, evaluation criteria
GENERATOR (craftsman)
    ↓ faithful implementation
EVALUATOR (ruthless)
    ↓ rubric scoring, reject if < threshold
    ↓ (loop back to Generator if rejected, max 3 iterations)
OUTPUT
```

## When to Use

- Design-heavy features (UI, design systems, landing pages)
- Creative output (copy, branding, documentation with voice)
- Architecture proposals (challenge mediocrity)
- Any task where "good enough" is not good enough

**Not for:** Bug fixes, config changes, mechanical refactoring.

## Planner Role — Deliberate Ambition

The Planner's job is to EXPAND a brief prompt into a comprehensive spec:
- Turn "make a landing page" into 12-16 specific features
- Add design directives (color palette, typography, motion)
- Define weighted evaluation criteria
- Set the quality bar high — better to over-spec and cut than under-spec and accept mediocrity

**Philosophy:** With CC, the cost of ambition is near-zero. A comprehensive spec costs the same tokens as a lazy one.

## Evaluator Role — Rubric Scoring

Score on 4 dimensions (weighted):

| Dimension | Weight | What it measures |
|-----------|--------|-----------------|
| Design quality | 0.30 | Visual craft, spacing, hierarchy, intentionality |
| Originality | 0.20 | Distinctiveness vs generic templates |
| Technical craft | 0.30 | Code quality, accessibility, performance |
| Functionality | 0.20 | Does it work? Edge cases handled? |

**Threshold:** Score < 7.0 → reject, loop back with specific feedback.
**Max iterations:** 3. After 3 attempts, ship with concerns noted.

## AI Slop Anti-Patterns

The Evaluator MUST flag these. They indicate lazy, generic output:

### Visual Slop (auto-reject if found)
- Generic gradient backgrounds (blue-to-purple, the "AI default")
- Excessive rounded corners (>12px everywhere)
- Stock hero sections ("Welcome to Our Platform" + generic illustration)
- Unmodified Material UI / Shadcn defaults (use them, but customize)
- Placeholder images ("lorem picsum" in production)
- Generic card grid layouts (3 cards in a row with icons)
- Decorative animations not triggered by user actions

### Content Slop (auto-reject if found)
- "Revolutionize your workflow" or similar buzzword headlines
- "Seamlessly integrate" without explaining what integrates with what
- "Cutting-edge technology" without naming the technology
- Generic testimonials from fictional users
- Empty states that just say "No data" instead of having personality

### Code Slop (flag as INFORMATIONAL)
- `console.log` left in production code
- Generic error messages ("Something went wrong")
- CSS `!important` overrides
- Inline styles for things that should be design tokens
- `any` type in TypeScript without justification

## Integration with PRISM

- **/ceo-review**: Use Planner mindset in SCOPE EXPANSION mode
- **/code-review**: Use Evaluator rubric in Design Review (Step 4.5)
- **/paranoid-review**: Add AI Slop check to INFORMATIONAL pass
- **/design-review**: Use full GAN loop for design-heavy changes
- **Sub-agents**: Planner = task brief writer, Generator = sub-agent, Evaluator = /review
