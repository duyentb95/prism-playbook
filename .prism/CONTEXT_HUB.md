# CONTEXT HUB — Shared Project Context

> Single Source of Truth for all agents.
> Master-Agent updates. Sub-agents read only.

## WHY — Why this project exists

PRISM is an open-source AI Team Playbook for Claude Code.
It provides conventions, templates, and pre-built skills that make Claude Code
work like a professional AI team — structured planning, parallel execution,
knowledge persistence, and cognitive mode switching (via gstack integration).

Goal: help anyone using Claude Code get 2-3x more output with better quality,
less token waste, and no context loss between sessions.

## WHO — Who receives the output

- **Primary**: Anyone using Claude Code — needs a plug-and-play playbook
- **Secondary**: Teams sharing AI context via git — needs `.prism/` to be portable
- **Community**: Open-source users — needs clear docs, easy setup, professional quality

## STANDARDS — Output standards

### Code Standards
- Language: Bash (setup script), Markdown (SKILL.md files, docs)
- Style: gstack-compatible SKILL.md format (frontmatter + Preamble + AskUserQuestion + Steps)
- Testing: Manual QA via Claude Code sessions
- Naming: kebab-case for directories, UPPER_SNAKE for .prism/ files

### Document Standards
- Language: Bilingual — English primary, Vietnamese parallel where helpful
- Format: GitHub-flavored Markdown
- All docs must match actual code/behavior (no stale docs)

### Quality Gates
- Every SKILL.md has: version, Preamble, AskUserQuestion Format, step-by-step workflow
- README and GETTING-STARTED match current feature set
- Knowledge files updated after every significant change

## TECH STACK

- **Core**: Pure Markdown + Bash (zero dependencies)
- **Skills**: Claude Code SKILL.md format (frontmatter YAML + Markdown body)
- **Integration**: gstack (Garry Tan / YC) as git submodule in vendor/
- **Browser**: gstack browse binary (requires Bun runtime)
- **Hosting**: GitHub — github.com/duyentb95/prism-playbook

## KEY CONSTRAINTS

- Zero runtime dependencies for core PRISM (no npm, no pip, just bash + markdown)
- gstack is vendored, not forked — update via `git submodule update`
- Skills must work both globally (~/.claude/skills/) and vendored (.claude/skills/)
- Token budget: peak ~22K tokens at any moment (lazy loading architecture)
- All .prism/ files are git-committable (no secrets, no binary, no temp data)

---
*Last updated: 2026-03-17*
*Updated by: Master-Agent*
