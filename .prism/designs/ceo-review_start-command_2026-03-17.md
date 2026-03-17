# CEO Review — /start Command & Onboarding Redesign

**Date**: 2026-03-17
**Status**: ✅ Implemented (Option B + C hybrid)

## Problem
30 slash commands overwhelm new users. Non-tech users don't know where to begin. GETTING-STARTED.md lacked concrete examples and visual command hierarchy.

## Decision
- Option B: Rewrite GETTING-STARTED.md with "Your First 5 Minutes" scenario, command map diagram, and all-commands table
- Option C: Create `/start` command — smart GPS that detects project state and routes to right workflow
- Skip `/example` — static text adds noise, doesn't solve the navigation problem

## What Changed
1. **GETTING-STARTED.md** — added "Your First 5 Minutes" walkthrough, ASCII command map, comprehensive command table
2. **`/start` command** — 6-path routing: no PRISM → has staging → no tasks → blocked → pending → all done
3. FAQ updated with "/start" as answer to "which command?"

## /start Routing Paths
1. No PRISM → suggest setup
2. Has STAGING.md → resume session
3. No tasks → offer brainstorm/plan/gsd
4. Blocked tasks → unblock/skip/re-plan
5. Pending tasks → continue/review/ship
6. All done → review/ship/retro/next sprint
