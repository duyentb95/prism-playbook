# MASTER PLAN

> Managed by Master-Agent. Reviewed by Human.
> Updated after each task completion.

## Current Sprint

**Sprint**: #5 — Browser Automation
**Goal**: Create browser-agent skill with dual-engine support (gstack browse + Playwright fallback)
**Status**: ✅ Complete

## Task Board

| ID | Task | Model Tier | Status | Deps | Notes |
|----|------|-----------|--------|------|-------|
| TASK_501 | Create browser-agent skill | GSD | ✅ | None | Dual-engine: gstack browse + Playwright fallback + script gen |
| TASK_502 | Update gstack-bridge routing | GSD | ✅ | 501 | Browser intents → browser-agent first |
| TASK_503 | Update setup script for 12 skills | GSD | ✅ | 501 | browser-agent added to status + uninstall |

### Status Legend
- ⏳ Not started
- 🔄 In progress
- ✅ Done
- ❌ Blocked
- 🔁 Needs revision

## Previous Sprints

### Sprint #1 — Framework Polish & Test
**Status**: ✅ Complete

| ID | Task | Status | Notes |
|----|------|--------|-------|
| TASK_001 | Initialize .prism/ with real project context | ✅ | CONTEXT_HUB, DICTIONARY, MASTER_PLAN populated |
| TASK_002 | Upgrade all 5 skills to gstack standard | ✅ | Preamble + AskUserQuestion + versioned |
| TASK_003 | Push to GitHub duyentb95/prism-framework | ✅ | Bilingual README + GETTING-STARTED |
| TASK_004 | Create .prism/knowledge/ seed files | ✅ | RULES.md, GOTCHAS.md, TECH_DECISIONS.md |
| TASK_005 | Validate skills by testing commands | ✅ | All 5 preambles pass |

### Sprint #4 — Close gstack Gaps
**Status**: ✅ Complete

| ID | Task | Status | Notes |
|----|------|--------|-------|
| TASK_401 | Create design-auditor skill | ✅ | 80-item checklist, AI slop detection |
| TASK_402-403 | JSON persistence for qa-engineer + sprint-retro | ✅ | Dual output (MD + JSON) |
| TASK_404 | Session detection in sprint-retro | ✅ | 45-min gap heuristic |
| TASK_405 | Update setup for 11 skills | ✅ | Status + uninstall |

### Sprints #2-3 — Upgrade Skills to gstack Parity
**Status**: ✅ Complete

| Sprint | What | Result |
|--------|------|--------|
| #2 (Hardening) | Upgraded 5 existing skills | +621 lines, error handling, output schemas |
| #3 (New Skills) | Created qa-engineer, paranoid-review, ship-engineer, cost-tracker, sprint-retro | 5 new skills, 1,711 lines |

## Completed Tasks Log

| ID | Completed | Summary | Files Changed |
|----|-----------|---------|---------------|
| TASK_001 | 2026-03-17 | Populated .prism/ with real PRISM project context | .prism/CONTEXT_HUB.md, DICTIONARY.md, MASTER_PLAN.md |
| TASK_002 | 2026-03-17 | Upgraded all 5 SKILL.md to gstack professional standard | skills/*/SKILL.md (5 files) |
| TASK_003 | 2026-03-17 | Pushed to GitHub with bilingual docs | README.md, GETTING-STARTED.md |
| TASK_401 | 2026-03-17 | Created design-auditor skill (80-item checklist) | skills/design-auditor/SKILL.md |
| TASK_402 | 2026-03-17 | Added JSON persistence to qa-engineer | skills/qa-engineer/SKILL.md |
| TASK_403 | 2026-03-17 | Added JSON persistence to sprint-retro | skills/sprint-retro/SKILL.md |
| TASK_404 | 2026-03-17 | Added session detection to sprint-retro | skills/sprint-retro/SKILL.md |
| TASK_405 | 2026-03-17 | Updated setup script for all 11 skills | setup |
| TASK_501 | 2026-03-17 | Created browser-agent skill (dual-engine) | skills/browser-agent/SKILL.md |
| TASK_502 | 2026-03-17 | Updated gstack-bridge routing for browser | skills/gstack-bridge/SKILL.md |
| TASK_503 | 2026-03-17 | Updated setup script for 12 skills | setup |

## Blockers & Issues

| Issue | Severity | Owner | Status |
|-------|----------|-------|--------|
| vendor/gstack not in repo (gitmodule, no clone) | Low | Human | gstack installed globally via manual clone |

---
*Last updated: 2026-03-17*
