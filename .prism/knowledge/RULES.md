# Project Rules

## Skill Writing Rules
- **Every SKILL.md must have**: version in frontmatter, Preamble bash block, AskUserQuestion Format section, step-by-step workflow — Source: gstack pattern analysis (2026-03-17)
- **AskUserQuestion 4-part structure**: Re-ground → Simplify → Recommend → Options — Source: gstack universal pattern
- **Preamble detects branch + state**: `_BRANCH`, `_PRISM`, `_HAS_PLAN`, etc. — Source: gstack preamble pattern
- **allowed-tools as YAML list**: Not comma-separated string — Source: gstack frontmatter format
- **Assume user AFK for 20 min**: Questions must be self-contained, no jargon, concrete examples — Source: gstack AskUserQuestion spec

## Documentation Rules
- **Bilingual**: English primary, Vietnamese parallel — Source: open-source best practice
- **README must have**: Install (1 command), Quick Start, Why, Structure, Commands — Source: framework README v1
- **All URLs point to**: github.com/duyentb95/prism-framework — Source: repo setup (2026-03-17)

## Token Optimization Rules
- **Never pre-load gstack SKILL.md** — lazy load only when command invoked
- **One gstack SKILL.md at a time** — drop old before loading new
- **Peak budget: ~22K tokens** — Layer 0 (4.2K) + Layer 1 (1K) + Layer 2 (15K) + Layer 3 (2K)
- **Preamble runs once per session** — skip on subsequent gstack commands

## Architecture Rules
- **Zero runtime dependencies for core** — only bash + markdown
- **gstack is vendored, not forked** — update via submodule
- **Skills work both globally and vendored** — discover via project root first, then ~/.claude/

## Data Format Rules
- **JSONL for AI-consumed data** — learnings, session logs, action history, audit trails. One JSON object per line, append-only, AI parses with `json.loads(line)` — Source: agstack + gstack pattern analysis (2026-04-02)
- **Markdown for human-consumed data** — CLAUDE.md, MASTER_PLAN, CONTEXT_HUB, knowledge files, gate status. Readable in IDE/GitHub, human-editable — Source: PRISM convention
- **Dual output for reports** — Markdown for humans + JSON for trend analysis/CI gates — Source: TECH_DECISIONS (2026-03-17)

## Cross-Project Upgrade Rules
- **Merge, not replace** — When upgrading PRISM across projects, merge new content into existing files. Never overwrite project-specific customizations — Source: bot/data upgrade session (2026-04-02)
- **Additive for rules/hooks** — New rules and hooks are always safe to copy (no conflict risk). Keep project-specific rules intact — Source: bot/data upgrade session (2026-04-02)
- **Diff before overwriting skills** — Compare file sizes first. If target is LARGER, it has project customizations — skip or surgical merge only — Source: bot/data upgrade session (2026-04-02)
- **Rename on conflict, don't merge** — If a PRISM command name conflicts with a business command, rename the business one (e.g., `/investigate` → `/investigate-wallet`) — Source: bot/data naming conflict (2026-04-02)
