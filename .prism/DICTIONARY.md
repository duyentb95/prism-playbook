# PROJECT DICTIONARY

> Defines project-specific terminology.
> Purpose: AI never guesses meaning.
> Updated by: Master-Agent + Human

## PRISM Terms

| Term | Definition | Context |
|------|-----------|---------|
| `PRISM` | Plan → Review → Implement → Ship → Monitor | Core playbook lifecycle |
| `Master-Agent` | The orchestrator that plans, decomposes, delegates, reviews | Opus-tier, runs in main session |
| `Sub-Agent` | Focused executor that reads a task brief and delivers | Sonnet-tier, runs in separate session |
| `GSD` | Get Shit Done — do it yourself if task < 15 min | Quick strike mode, no sub-agent needed |
| `DoD` | Definition of Done — specific, verifiable completion criteria | Every task must have one |
| `Brief for Master` | Handover report from sub-agent → master-agent | End of every sub-agent session |
| `Context Compacting` | Extracting essential state into STAGING.md for session handoff | When conversation gets too long |
| `Knowledge Spine` | .prism/knowledge/ files that persist lessons across sessions | RULES.md, GOTCHAS.md, TECH_DECISIONS.md |
| `Cognitive Mode` | A specialized thinking mode (CEO, Eng, QA, Ship, etc.) | From gstack / Garry Tan philosophy |
| `Lazy Loading` | Only read a SKILL.md when its command is invoked | Token optimization — never pre-load |

## gstack Terms

| Term | Definition | Context |
|------|-----------|---------|
| `gstack` | Garry Tan's cognitive mode skills for Claude Code | 12 SKILL.md files, YC-inspired |
| `Preamble` | Bash block at top of every SKILL.md (session tracking, branch detection) | Identical across all gstack skills |
| `AskUserQuestion Format` | Standardized 4-part question: Re-ground → Simplify → Recommend → Options | Used in every PRISM + gstack skill |
| `Ref system` | `@e1, @e2, @c1` — element addressing in headless browser | gstack /browse |
| `Fix-First` | Auto-fix obvious issues, ask about ambiguous ones | gstack /review pattern |
| `Diff-aware` | Analyze git diff to determine which pages/routes are affected | gstack /qa mode |
| `10-star product` | The ideal version of a feature if effort were unlimited | CEO review framework |

## File Abbreviations

| Abbr | Full Path | Purpose |
|------|-----------|---------|
| CONTEXT_HUB | `.prism/CONTEXT_HUB.md` | WHY, WHO, STANDARDS |
| MASTER_PLAN | `.prism/MASTER_PLAN.md` | Task board + sprint status |
| STAGING | `.prism/STAGING.md` | Session snapshot for handoff |
| RULES | `.prism/knowledge/RULES.md` | Extracted patterns |
| GOTCHAS | `.prism/knowledge/GOTCHAS.md` | Traps & lessons learned |
| TECH_DECISIONS | `.prism/knowledge/TECH_DECISIONS.md` | Architecture Decision Records |

---
*Append new terms as they arise. Never rewrite entire file.*
