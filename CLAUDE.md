# CLAUDE.md -- PRISM Playbook

> Plan -> Review -> Implement -> Ship -> Monitor

## This Project

This is the **prism-playbook** repository -- the source code for the PRISM framework itself.
Stack: Markdown (SKILL.md files, docs, templates, commands).
Repo: github.com/duyentb95/prism-playbook

## Core Rules

1. **ASK before doing** -- don't jump to code. Ask: "What are you trying to achieve?"
2. **Design before build** -- present approach section by section. Wait for approval.
3. **Plan before execute** -- break complex tasks into micro-tasks. Type GO to start.
4. **Quick tasks (< 15 min)** -- /gsd, no planning needed.
5. **Append knowledge** -- after learning something new, append to .prism/knowledge/.

## PRISM Workflow

Type `/start` to begin -- it detects project state and guides you.

### Gate Flow
```
/plan → /ceo-review → /eng-review → implement → /review → /ship
```

- Think:   /brainstorm, /office-hours, /ceo-review, /eng-review
- Plan:    /plan -> GO
- Build:   /gsd (quick) or sub-agents (complex)
- Check:   /paranoid-review, /qa-check, /qa-only
- Ship:    /ship, /document-release
- Learn:   /retro
- Context: /start, /status, /compact, /adhoc

## Key Constraints

- Zero runtime dependencies (markdown + commands only)
- All skills local in .claude/skills/ -- no external installs
- Token budget: keep CLAUDE.md compact -- every token loads on EVERY request
- All .prism/ files are git-committable (no secrets, no binary)
- Templates in templates/ use {{PLACEHOLDER}} syntax filled by /init-prism

## Project Structure

```
CLAUDE.md              <- This file (compact project instructions)
PLAYBOOK.md            <- Full framework documentation (reference only)
GETTING-STARTED.md     <- User onboarding guide
README.md              <- GitHub landing page
skills/                <- 9 PRISM skill definitions (SKILL.md)
templates/             <- 6 CLAUDE.md templates for target projects
.prism/                <- PRISM's own project knowledge
.prism-template/       <- Template files for new project setup
.claude/commands/      <- 31 slash commands
.claude/skills/        <- 7 internalized execution skills
.claude/rules/         <- 10 rules (anti-hallucination, hero-mode, eng-methodology, progressive-disclosure, reuse-first, epic-classification, ux-psychology, refactoring-tiers, workflow-patterns, operational-edges)
.claude/hooks/         <- 3 hooks (session-recovery, self-review, track-changes+security)
.claude/settings.json  <- Claude Code settings
archive/               <- Deprecated files (setup-v2)
```

## Sub-Agent Protocol

Sub-agents end with one of: DONE | DONE_WITH_CONCERNS | BLOCKED | NEEDS_CONTEXT.
Task briefs go in .prism/tasks/TASK_NNN_xxx.md.
Run: `Read .prism/tasks/TASK_NNN_xxx.md and EXECUTE. Assume I am AFK.`

### Hero Mode (parallel agents)
Multiple agents on one branch with strict file ownership lanes.
See `.claude/rules/hero-mode.md` for protocol. Use `.prism/CLAIMS.md` for shared files.

## Token Optimization

- Sub-agents read only files specified in task brief, not entire project
- Use .claudecodeignore to exclude node_modules, data/, .git/, build/
- One SKILL.md at a time -- drop old before loading new

## Communication

- Always explain WHY for decisions
- If unclear, ASK -- don't assume
- Structured output for task briefs, reports, plans
- Full framework reference: see PLAYBOOK.md
