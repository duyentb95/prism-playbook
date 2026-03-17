# CLAUDE.md — PRISM Playbook (Minimal)

## How to Work

1. **ASK before doing** — Don't jump to code. Ask: "What are you trying to achieve?"
2. **Design before build** — Present the approach section by section. Wait for approval.
3. **Plan before execute** — Break complex tasks into micro-tasks. Type GO to start.
4. **Small tasks → just do it** — If < 15 minutes, no planning needed (GSD mode).

## Project Context

> Fill this in (2 minutes):

**What**: [What is this project?]
**Why**: [Why does it exist? What problem does it solve?]
**Who**: [Who uses it?]
**Stack**: [Languages, frameworks, tools]

## Knowledge

- Read `.prism/knowledge/` before starting — it contains patterns and traps from previous sessions.
- After learning something new, append to the appropriate file:
  - `RULES.md` — patterns ("always do X when Y")
  - `GOTCHAS.md` — traps ("don't do Z because...")
  - `TECH_DECISIONS.md` — architecture choices + reasoning

## Session Handoff

If the conversation gets long and Claude starts forgetting:
1. Write current state to `.prism/STAGING.md`
2. User opens fresh session: `Read .prism/STAGING.md and resume`
