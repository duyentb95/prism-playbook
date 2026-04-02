# Technical Decisions

## 2026-03-17 — Bilingual docs (English + Vietnamese)
- **Context**: Framework originally had Vietnamese-only docs. Preparing for open-source.
- **Decision**: English as primary language, Vietnamese alongside for key concepts
- **Alternatives**: Vietnamese only (limits audience), English only (loses Vietnamese developer community)
- **Reasoning**: Professional open-source projects use English. Vietnamese community benefits from parallel translations.
- **Consequences**: All future docs must maintain both languages. README and GETTING-STARTED are bilingual.

## 2026-03-17 — gstack as git submodule (not copy, not fork)
- **Context**: Need gstack's 12 cognitive modes integrated into PRISM
- **Decision**: Use git submodule at `vendor/gstack/`
- **Alternatives**: Fork gstack (diverges from upstream), copy files (no updates), npm package (doesn't exist)
- **Reasoning**: Submodule tracks upstream exactly. `./setup --update` pulls latest. Users get both PRISM + gstack updates.
- **Consequences**: Users must use `--recursive` when cloning. Setup script handles missing submodule gracefully.

## 2026-03-17 — Match gstack SKILL.md format exactly
- **Context**: PRISM skills were simpler than gstack's production-quality format
- **Decision**: Adopt gstack's Preamble + AskUserQuestion + Step-by-step format for all PRISM skills
- **Alternatives**: Keep simple format (less consistent), create PRISM-specific format (fragmented ecosystem)
- **Reasoning**: Consistency. Users who learn one gstack skill can read any PRISM skill. Same mental model.
- **Consequences**: Every new PRISM skill must include version, Preamble, AskUserQuestion Format, and numbered Steps.

## 2026-03-17 — Lazy loading architecture for gstack integration
- **Context**: gstack total ~120K tokens across 12 SKILL.md files. Pre-loading all would exhaust context.
- **Decision**: 4-layer lazy loading via gstack-bridge. Only 1 SKILL.md loaded at a time.
- **Alternatives**: Pre-load all (120K+ tokens wasted), no gstack (lose cognitive modes)
- **Reasoning**: 84% token reduction. Peak ~22K vs 135K+ naive approach.
- **Consequences**: gstack-bridge must maintain accurate command → path mapping. Preamble runs once per session.

## 2026-03-17 — JSON persistence alongside Markdown reports
- **Context**: gstack uses JSON snapshots for /qa and /retro. PRISM used Markdown only. Gap in machine-queryable data.
- **Decision**: Add JSON snapshot output to qa-engineer, sprint-retro, and design-auditor alongside Markdown reports.
- **Alternatives**: JSON only (loses human readability), Markdown only (not machine-queryable), database (over-engineering)
- **Reasoning**: Dual output. Markdown for humans, JSON for trend analysis, CI gates, and cross-sprint comparison.
- **Consequences**: Skills that produce reports must output both .md and .json. JSON schema is documented in SKILL.md.

## 2026-03-17 — Session detection via 45-minute gap heuristic
- **Context**: Sprint retro lacked visibility into work patterns (session length, time of day, fragmentation).
- **Decision**: Add session detection to sprint-retro using 45-min gap between commits as session boundary.
- **Alternatives**: 30-min gap (too aggressive, splits focused work), 60-min gap (misses lunch breaks), manual tracking (friction)
- **Reasoning**: 45 minutes is a commonly-used threshold in productivity research for session boundaries. Matches Pomodoro-extended flows.
- **Consequences**: Requires 5+ commits per sprint for meaningful analysis. Included in both Markdown and JSON output.

## 2026-03-17 — Design auditor as PRISM-native skill
- **Context**: gstack had 80-item design audit + AI slop detection. PRISM had no design review capability.
- **Decision**: Create design-auditor skill with 80-item checklist (5 sections) + AI slop detection + JSON persistence.
- **Alternatives**: Rely solely on gstack /qa-design-review (requires gstack), skip design audit entirely (gap remains)
- **Reasoning**: Design quality is critical for web projects. Having a PRISM-native option means the audit works even without gstack installed. gstack delegation still available for browser-based visual testing.
- **Consequences**: New skill added to framework. Setup script updated to include in status/uninstall. Total skills: 11.

## 2026-04-02 — PRISM v4: Cross-pollinate from agstack + claude-hlq + claude-howto
- **Context**: Three external repos had best practices PRISM lacked: anti-hallucination, hero mode, adversarial review, session recovery, security scanning, etc.
- **Decision**: Adopt 32 patterns across 10 rules, 3 hooks, 9 skill upgrades, 4 template upgrades
- **Alternatives**: Build from scratch (slow, reinventing), fork one repo (misses others), cherry-pick selectively (incomplete)
- **Reasoning**: Cross-pollination gets best of all three. Merge-not-replace preserves existing project customizations.
- **Consequences**: PRISM baseline now: 10 rules + 3 hooks + 9 core .claude/skills. All target projects need upgrade via additive copy + surgical merge.

## 2026-04-02 — JSONL for AI-consumed audit trail (not plain text)
- **Context**: track-changes.sh originally output plain text (`timestamp | tool | file`). AI needed to parse this for session recovery and security audit.
- **Decision**: Switch to JSONL format (`{"ts":"...","tool":"...","file":"..."}`)
- **Alternatives**: Plain text (human-readable but hard to parse), SQLite (over-engineering), CSV (no nested fields)
- **Reasoning**: JSONL is append-only, one object per line, AI parses with `json.loads(line)`. Human-readable with `jq`. Same pattern as gstack learnings.jsonl.
- **Consequences**: `.prism/session-changes.jsonl` replaces `.prism/session-changes.log`. Security warnings inline as `"type":"security_warning"` field.

## 2026-03-17 — Browser-agent with dual-engine fallback (not gstack-only)
- **Context**: gstack browse binary requires Bun + build step. Many users won't have it. Browser testing was gstack-only.
- **Decision**: Create PRISM-native browser-agent skill with 3-tier engine detection: gstack browse → Playwright CLI → script generation.
- **Alternatives**: Only delegate to gstack (fails without gstack), bundle Playwright binary (too heavy), skip browser testing (gap remains)
- **Reasoning**: Dual-engine means browser testing always works. gstack browse when available (fastest, 100ms), Playwright CLI as middle ground, generated scripts as universal fallback. Engine detection is automatic via preamble.
- **Consequences**: browser-agent wraps gstack browse commands when available but is not dependent on gstack. gstack-bridge routes "browse" intents to browser-agent instead of directly to gstack /browse. Total skills: 12.
