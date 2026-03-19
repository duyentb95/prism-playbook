# Eng Review: gstack Integration Sync

**Date:** 2026-03-20
**Commit:** fbfdfc3 (HEAD at review time)
**gstack version:** v0.8.5 (remote HEAD: bd834ae)

## Findings

### CRITICAL
1. **8 missing skills** — gstack added codex, investigate, office-hours, careful, freeze, unfreeze, guard, design-review since last sync
2. **Broken path** — bridge routes `/qa-design-review` → `qa-design-review/SKILL.md` but gstack renamed to `design-review/`
3. **Missing command files** — 7 new `.claude/commands/` files needed

### HIGH
4. **Bridge routing table** — missing 8 entries in Step 0, Step 1, Step 5
5. **Integration output table** — no .prism/ save paths for new skills

### MEDIUM
6. **Naming confusion** — `/design-review` (fix loop) vs `/plan-design-review` (report only)
7. **Submodule not initialized** — vendor/gstack/ empty, .gitmodules exists
8. **No sync process** — manual comparison required each time gstack updates

### LOW
9. **Safety skills** — /careful, /freeze, /guard are nice-to-have
10. **OpenAI disclosure** — /codex sends code externally, should be noted

## Implementation Plan

### Phase 1 (approved)
- Fix path: qa-design-review/ → design-review/ in bridge
- Add 8 entries to bridge routing + path + integration tables
- Create 7 new command files in .claude/commands/
- Update PRISM vs gstack comparison table

### Phase 2 (follow-up)
- Create sync check script
- Decide submodule strategy
- Update PLAYBOOK.md / README

## Trust Boundaries
- /codex sends code to OpenAI — semi-trusted, user-consented
- All other skills are local-only
- gstack submodule from trusted source (garrytan/gstack)

## Test Matrix
- 19 tests defined (5 static, 8 integration, 4 sync, 1 regression, 1 script)
- See full review conversation for details
