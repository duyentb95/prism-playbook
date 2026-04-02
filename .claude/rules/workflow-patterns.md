# Workflow Patterns — Reference

> Collected patterns for specific workflows. Reference as needed.

## A/B Testing via Checkpoints

Use Claude Code checkpoints for safe experimentation:

```
1. Save checkpoint (stable state)
2. Implement Approach A
3. Test/evaluate
4. Save checkpoint
5. Rewind to step 1
6. Implement Approach B
7. Test/evaluate
8. Compare A vs B → pick winner
```

**Use cases:**
- Comparing two design approaches
- Testing different algorithms
- Safe refactoring (rewind if tests break)
- Exploring architectural options

**Limitation:** Checkpoints don't track Bash side effects (rm, mv, external processes).
Use git for anything that needs reliable undo.

## CLI Automation Flags

For CI/CD integration and scripted usage:

| Flag | Purpose | Example |
|------|---------|---------|
| `-p "query"` | Non-interactive (print mode) | `claude -p "review this diff"` |
| `--output-format json` | Machine-readable output | Pipe to jq, scripts |
| `--permission-mode plan` | Read-only analysis | Safe for CI review jobs |
| `--allowedTools "Read,Grep,Glob"` | Restrict to specific tools | Read-only agents |
| `--max-turns N` | Limit agentic loops | Prevent runaway agents |
| `--json-schema file.json` | Enforce output structure | Structured reports |

**CI/CD recipe — automated code review:**
```bash
claude -p "Run /review on the current branch" \
  --permission-mode plan \
  --output-format json \
  --max-turns 20
```

## Brand Voice Template

For projects that need consistent communication (marketing sites, docs, user-facing copy):

Create `BRAND_VOICE.md` in project root:

```markdown
# Brand Voice

## Identity
- Mission: [one sentence]
- Personality: [3-5 adjectives]

## Tone
- Default: [e.g., friendly, professional, clear]
- Error messages: [e.g., helpful, not blaming]
- Success messages: [e.g., brief, celebratory]

## Vocabulary
- Use: [preferred terms]
- Avoid: [banned terms]
- Example: "streamline" not "revolutionize", "help" not "empower"

## Writing Rules
- Active voice
- Short sentences (< 20 words)
- Concrete examples over abstract claims
- No jargon unless audience is technical
```

When `/review` detects user-facing copy changes AND `BRAND_VOICE.md` exists,
review copy against brand voice guidelines.
