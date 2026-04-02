# Gotchas & Lessons Learned

## 2026-03-17 — gstack symlinks not created by manual clone
- **Problem**: `git clone` gstack to `~/.claude/skills/gstack/` but gstack commands show as warnings in `./setup --status`
- **Root cause**: `./setup --status` checks for symlinks (e.g., `~/.claude/skills/plan-ceo-review` → `gstack/plan-ceo-review/`). Manual clone + `./setup` inside gstack may not create these.
- **Fix**: Not critical — gstack-bridge resolves paths directly via `gstack/plan-ceo-review/SKILL.md`. Symlinks are optional convenience.
- **Prevention**: Document that `./setup --status` warnings for gstack skills are cosmetic if gstack is installed and commands work.

## 2026-03-17 — git push rejected on fresh repo with existing remote
- **Problem**: `git push -u origin main` rejected because remote had existing commits (README from GitHub init)
- **Root cause**: GitHub creates an initial commit when you check "Add README" during repo creation
- **Fix**: `git pull origin main --rebase --allow-unrelated-histories` then push
- **Prevention**: Either create GitHub repo without README, or always pull-rebase before first push

## 2026-03-17 — PRISM skills lacked AskUserQuestion Format
- **Problem**: All 5 PRISM skills had no standardized question format. Sub-agents would ask poorly structured questions.
- **Root cause**: Original skills were written before studying gstack patterns
- **Fix**: Added AskUserQuestion Format section to all 5 skills (Re-ground → Simplify → Recommend → Options)
- **Prevention**: Always check gstack SKILL.md as reference when writing new skills

## 2026-04-02 — /investigate naming conflict between PRISM and business command
- **Problem**: bot/data project used `/investigate` for wallet insider trading analysis. PRISM uses `/investigate` for systematic debugging (RCHDTV). Both needed but same name.
- **Root cause**: Business commands created before PRISM had a debugging skill with the same name
- **Fix**: Renamed business command to `/investigate-wallet`, freed `/investigate` for PRISM debugging
- **Prevention**: When adding business-specific commands, avoid PRISM reserved names: investigate, review, ship, plan, compact, status, gsd, adhoc, deploy, cost, pipeline
- **Severity**: 🟡 Medium

## 2026-04-02 — Claude Code Read tool silently truncates at 2000 lines
- **Problem**: Reading a large file returns only first 2000 lines without warning. Edits based on partial reads can break code at unseen lines.
- **Root cause**: Read tool has hardcoded 2000-line limit per call
- **Fix**: Check `wc -l` before reading large files. Use offset+limit for chunked reads. Use Grep to find target lines first.
- **Prevention**: Added to `.claude/rules/operational-edges.md` as mandatory practice
- **Severity**: 🔴 Critical

## 2026-04-02 — Search results silently truncated, grep misses dynamic references
- **Problem**: Grep results are capped. Single grep for rename misses dynamic imports, string references, re-exports. Leads to broken references after refactoring.
- **Root cause**: Search result truncation + grep is literal pattern matching, doesn't understand code semantics
- **Fix**: Multi-pass search protocol: ≥3 patterns per rename (exact, string ref, dynamic import, re-export). If results seem incomplete, narrow scope by directory.
- **Prevention**: Added to `.claude/rules/operational-edges.md`
- **Severity**: 🔴 Critical
