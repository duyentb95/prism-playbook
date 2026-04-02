# Skill Progressive Disclosure — 3-Layer Loading

> Context window is a shared resource. Load exactly what's needed, when needed.

## The 3 Layers

| Layer | Content | When Loaded | Budget |
|-------|---------|-------------|--------|
| **Layer 1: Metadata** | SKILL.md frontmatter (name, description, model, tools) | At startup / skill list | ~100 tokens |
| **Layer 2: SKILL.md body** | Overview, workflow steps, quick reference | When skill is activated | < 500 lines |
| **Layer 3: Reference files** | Checklists, specialists, examples, edge cases | On-demand during execution | Unlimited |

## Rules

1. **Never load Layer 3 at startup.** Reference files (checklists, specialist guides) are loaded
   only when the skill's workflow reaches the step that needs them.

2. **One SKILL.md at a time.** When switching from `/investigate` to `/review`, the previous
   skill's body is no longer needed. Don't carry both.

3. **Sub-agents inherit only what they need.** A sub-agent's prompt should include:
   - The task brief (always)
   - DICTIONARY.md (always)
   - Specific reference files listed in the brief (selective)
   - NOT the full SKILL.md of the parent skill

4. **Frontmatter is the index.** When deciding which skill to activate, read frontmatter only.
   Don't load the full SKILL.md just to check if it's relevant.

## Skill File Structure Convention

```
.claude/skills/my-skill/
├── SKILL.md              # Layer 2: Main workflow (< 500 lines)
├── checklist.md          # Layer 3: Detailed checklist (loaded by Step N)
├── specialists/          # Layer 3: Sub-checklists (loaded conditionally)
│   ├── security.md
│   └── performance.md
└── bin/                  # Hook scripts (loaded by harness, not context)
    └── check-something.sh
```

## Token Budget Guidelines

| Artifact | Target | Max |
|----------|--------|-----|
| CLAUDE.md | < 100 lines | 150 lines |
| SKILL.md body | < 300 lines | 500 lines |
| Checklist file | < 100 lines | 200 lines |
| Task brief | < 50 lines | 80 lines |
| Sub-agent prompt | < 200 lines | 300 lines |
