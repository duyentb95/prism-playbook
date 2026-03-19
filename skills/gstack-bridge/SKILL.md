---
name: gstack-bridge
version: 1.0.0
description: |
  Routes PRISM workflow to gstack cognitive mode SKILL.md files. Lazy-loads on demand.
  Triggers: any gstack slash command (/review, /ship, /qa, /browse, /retro, /doc-release,
  /design-review, /design-fix, /design-system, /cookies, /gstack-upgrade),
  or intent matching (review my code, ship it, test the site, design check, weekly retro).
  Also handles browse binary discovery and gstack↔PRISM output integration.
allowed-tools:
  - Read
  - Write
  - Edit
  - Bash
  - Glob
  - Grep
  - AskUserQuestion
model: sonnet
---

## Preamble (run first)

```bash
_BRANCH=$(git branch --show-current 2>/dev/null || echo "unknown")
_ROOT=$(git rev-parse --show-toplevel 2>/dev/null || echo ".")
GSTACK=""
if [ -d "$_ROOT/.claude/skills/gstack" ]; then
  GSTACK="$_ROOT/.claude/skills/gstack"
elif [ -d "$HOME/.claude/skills/gstack" ]; then
  GSTACK="$HOME/.claude/skills/gstack"
fi
if [ -n "$GSTACK" ]; then
  echo "BRANCH: $_BRANCH | GSTACK_ROOT: $GSTACK"
else
  echo "BRANCH: $_BRANCH | GSTACK: NOT_FOUND — run ./setup from framework root"
fi
```

If `GSTACK` is `NOT_FOUND`: stop and tell user to install gstack first.

## AskUserQuestion Format

**ALWAYS follow this structure for every AskUserQuestion call:**
1. **Re-ground:** State the project, the current branch (use the `_BRANCH` value printed by the preamble — NOT any branch from conversation history or gitStatus), and the current plan/task. (1-2 sentences)
2. **Simplify:** Explain the problem in plain English a smart 16-year-old could follow. No raw function names, no internal jargon, no implementation details. Use concrete examples and analogies. Say what it DOES, not what it's called.
3. **Recommend:** `RECOMMENDATION: Choose [X] because [one-line reason]`
4. **Options:** Lettered options: `A) ... B) ... C) ...`

Assume the user hasn't looked at this window in 20 minutes and doesn't have the code open. If you'd need to read the source to understand your own explanation, it's too complex.

---

# gstack Bridge — Lazy Router for PRISM

gstack = 12 specialized execution modes (cognitive modes) for Claude Code by Garry Tan / YC.
Each mode has its own SKILL.md (3K-15K tokens).
This bridge routes to the correct one WITHOUT pre-loading any of them.

---

## Step 0: Determine Route

### When gstack vs PRISM Native

```
USER INTENT                              → ROUTE TO
────────────────────────────────────────────────────────
"brainstorm" / "ideate" / "PRD"          → PRISM /brainstorm (DO NOT route to gstack)
"plan this feature"                      → PRISM /plan (DO NOT route to gstack)
"compress context" / "save state"        → PRISM context-compactor
"what's the plan" / "project overview"   → PRISM knowledge-spine / /status
"browse" / "open page" / "screenshot"    → PRISM browser-agent (auto-detects engine)
"test the site" / "check the page"       → PRISM browser-agent (auto-detects engine)
"responsive test" / "check mobile"       → PRISM browser-agent (auto-detects engine)
"design audit" / "visual QA"             → PRISM design-auditor

"review plan as CEO" / "is this right?"  → gstack /plan-ceo-review
"lock the architecture"                  → gstack /plan-eng-review
"review my code before merge"            → gstack /review
"ship this branch"                       → gstack /ship
"full QA with browser" / "QA this"       → gstack /qa (deep diff-aware testing)
"how does the design look"               → gstack /plan-design-review
"fix the design issues"                  → gstack /design-review (audit + fix loop)
"create a design system"                 → gstack /design-consultation
"update the docs post-ship"              → gstack /document-release
"weekly retro" / "what did we ship"      → gstack /retro
"second opinion" / "adversarial review"  → gstack /codex (sends code to OpenAI)
"debug this" / "trace the bug"           → gstack /investigate (root-cause debugging)
"YC office hours" / "startup diagnostic" → gstack /office-hours
"be careful" / "destructive warning"     → gstack /careful
"lock edits to this dir"                 → gstack /freeze
"remove edit lock"                       → gstack /unfreeze
"maximum safety mode"                    → gstack /guard (freeze + careful combined)
```

**Browser routing logic:**
- "browse", "screenshot", "open page", "check the page" → PRISM browser-agent
  (uses gstack browse binary if available, Playwright fallback if not)
- "full QA", "diff-aware QA" → gstack /qa (requires gstack SKILL.md for full workflow)
- browser-agent handles engine detection internally — no need to check gstack first

### PRISM commands vs gstack commands — same concept, different depth

| PRISM Command | gstack Command | Difference |
|---|---|---|
| `/ceo-review` | `/plan-ceo-review` | PRISM: inline, saves to .prism/. gstack: full SKILL.md with 10-star framework |
| `/eng-review` | `/plan-eng-review` | PRISM: inline phases. gstack: forced diagrams, test matrix, failure modes |
| `/paranoid-review` | `/review` | PRISM: checklist. gstack: SQL safety, Greptile triage, auto-fix |
| `/ship-it` | `/ship` | PRISM: inline checklist. gstack: full automation (merge, test, version bump, PR) |
| `/document-release` | `/doc-release` | PRISM: inline checklist. gstack: cross-references git diff vs every doc |
| `/qa-check` | `/qa` | PRISM: manual evidence. gstack: diff-aware browser testing, 3 tiers, fix loop |
| `/retro` | `/retro` (gstack) | PRISM: inline format. gstack: commit analysis, per-person breakdown |
| `/brainstorm` | `/office-hours` | PRISM: general brainstorm. gstack: YC Office Hours format, startup diagnostic |
| — | `/codex` | No PRISM equivalent. Multi-AI second opinion via OpenAI Codex CLI |
| — | `/investigate` | No PRISM equivalent. Systematic root-cause debugging |
| — | `/careful` | No PRISM equivalent. Destructive command warnings |
| — | `/freeze` / `/unfreeze` | No PRISM equivalent. Directory-scoped edit lock |
| — | `/guard` | No PRISM equivalent. Full safety mode (freeze + careful) |

**Rule of thumb:**
- Quick / inline check → use PRISM command (reads from CLAUDE.md, 0 extra tokens)
- Deep / specialized execution → use gstack command (lazy-loads SKILL.md)
- User says the gstack command name explicitly → always route to gstack

---

## Step 1: Resolve Path

Find gstack root using the `GSTACK` value from preamble.

All SKILL.md paths are relative to `$GSTACK/`:

| Command | SKILL.md Path | Extra Files |
|---------|---------------|-------------|
| `/plan-ceo-review` | `plan-ceo-review/SKILL.md` | — |
| `/plan-eng-review` | `plan-eng-review/SKILL.md` | — |
| `/plan-design-review` | `plan-design-review/SKILL.md` | — |
| `/design-review` | `design-review/SKILL.md` | — |
| `/design-consultation` | `design-consultation/SKILL.md` | — |
| `/codex` | `codex/SKILL.md` | — |
| `/investigate` | `investigate/SKILL.md` | — |
| `/office-hours` | `office-hours/SKILL.md` | — |
| `/careful` | `careful/SKILL.md` | — |
| `/freeze` | `freeze/SKILL.md` | — |
| `/unfreeze` | `unfreeze/SKILL.md` | — |
| `/guard` | `guard/SKILL.md` | — |
| `/review` | `review/SKILL.md` | `review/checklist.md`, `review/greptile-triage.md` |
| `/ship` | `ship/SKILL.md` | `review/checklist.md`, `review/greptile-triage.md` |
| `/qa` | `qa/SKILL.md` | `qa/references/issue-taxonomy.md` |
| `/qa-only` | `qa-only/SKILL.md` | `qa/references/issue-taxonomy.md` |
| `/browse` | `browse/SKILL.md` (root) | — |
| `/retro` | `retro/SKILL.md` | — |
| `/doc-release` | `document-release/SKILL.md` | — |
| `/setup-browser-cookies` | `setup-browser-cookies/SKILL.md` | — |
| `/gstack-upgrade` | `gstack-upgrade/SKILL.md` | — |

---

## Step 2: Lazy Load

```
1. Read the target SKILL.md from the path table above
2. If "Extra Files" column has entries → read those too
3. NEVER read more than 1 gstack SKILL.md at a time
4. NEVER pre-load gstack SKILL.md "just in case"
```

---

## Step 3: Run gstack Preamble

Execute the bash block at the top of the gstack SKILL.md (session tracking, update check, branch detection).

This preamble is identical across all gstack skills — **run once per session, skip on subsequent commands.**

Track with a mental flag: `_GSTACK_PREAMBLE_RAN = true`

---

## Step 4: Execute Workflow

Follow the gstack SKILL.md instructions exactly as written.

---

## Step 5: Integrate Output → .prism/

After any gstack command completes, save output to the PRISM knowledge system:

| gstack Output | Save To | Format |
|---|---|---|
| `/plan-ceo-review` | `.prism/designs/ceo-review_{topic}_{date}.md` | Product direction + options chosen |
| `/plan-eng-review` | `.prism/designs/eng-review_{topic}_{date}.md` | Architecture + diagrams + edge cases |
| `/review` findings | `.prism/knowledge/GOTCHAS.md` (append) | Bugs found + fixes applied |
| `/qa` report | `.prism/qa-reports/qa_{date}.md` | Issues + evidence + status |
| `/qa` critical bugs | `.prism/tasks/TASK_NNN_qa_fix.md` | Sub-agent task briefs |
| `/retro` analysis | `.prism/retros/retro_{sprint}_{date}.md` | Metrics + wins + improvements |
| `/retro` lessons | `.prism/knowledge/GOTCHAS.md` (append) | Extracted patterns |
| `/design-consultation` | `DESIGN.md` (project root) | Design system reference |
| `/plan-design-review` | `.prism/qa-reports/design-audit_{date}.md` | Letter grades + issues |
| `/design-review` | `.prism/qa-reports/design-review_{date}.md` | Audit + fixes applied |
| `/doc-release` | `.prism/knowledge/RULES.md` (append) | New patterns discovered |
| `/codex` | `.prism/reviews/codex_{date}.md` | Cross-model findings + pass/fail |
| `/investigate` | `.prism/knowledge/GOTCHAS.md` (append) | Root cause + fix |
| `/office-hours` | `.prism/designs/office-hours_{topic}_{date}.md` | Diagnostic + action items |
| `/careful` | — (no persistent output) | Runtime warnings only |
| `/freeze` / `/unfreeze` | — (no persistent output) | Session-scoped lock |
| `/guard` | — (no persistent output) | Session-scoped safety mode |

### Post-gstack Checklist

1. Save output to appropriate .prism/ location (see table above)
2. If output contains lessons learned → append to `.prism/knowledge/GOTCHAS.md`
3. If output changes project standards → update `.prism/CONTEXT_HUB.md`
4. If output reveals new terminology → update `.prism/DICTIONARY.md`
5. Update `.prism/MASTER_PLAN.md` task status if relevant
6. If output > 5K tokens → run context-compactor to create concise summary

---

## Browse Binary Discovery

Run once before any `/browse` or `/qa` command:

```bash
_ROOT=$(git rev-parse --show-toplevel 2>/dev/null || echo ".")
B=""
if [ -x "$_ROOT/.claude/skills/gstack/browse/dist/browse" ]; then
  B="$_ROOT/.claude/skills/gstack/browse/dist/browse"
elif [ -x "$HOME/.claude/skills/gstack/browse/dist/browse" ]; then
  B="$HOME/.claude/skills/gstack/browse/dist/browse"
fi
if [ -n "$B" ]; then
  echo "BROWSE_READY: $B"
else
  echo "NEEDS_BUILD: cd ${GSTACK:-~/.claude/skills/gstack} && bun install && bun run build"
fi
```

---

## Output Schema

### Route Decision Format (internal, before loading SKILL.md)
```
🔀 ROUTE — [user intent summary]
Match: [EXACT_COMMAND | INTENT_MATCH | PRISM_NATIVE | HANDOFF_SUGGESTION]
Target: [gstack command or PRISM skill]
SKILL.md: [path to load]
Extra files: [paths or "none"]
Est. tokens: ~[N]K
```

### gstack→PRISM Integration Format
After any gstack command completes:
```
📥 INTEGRATED — [gstack command]
Saved to: [.prism/ path]
Knowledge extracted: [yes — N entries | no new knowledge]
Standards updated: [yes — what changed | no]
MASTER_PLAN updated: [yes — task NNN status | no]
```

### Error Format (when gstack unavailable)
```
⚠️ GSTACK NOT AVAILABLE
Command: [what user requested]
Reason: [not installed | SKILL.md missing | browse binary not built]
Fallback: [PRISM-native alternative if exists]
Action needed: [exact command to fix — e.g., "Run: ./setup --vendor"]
```

---

## Token Budget Rules

```
HARD RULES:
  ✗ NEVER load more than 1 gstack SKILL.md at a time
  ✗ NEVER pre-load gstack SKILL.md "just in case"
  ✓ After finishing a gstack workflow → SKILL.md content is stale, can be forgotten
  ✓ If switching commands → old SKILL.md is replaced by new one
  ✓ Preamble bash block is identical across skills → run once per session
  ✓ For /review → /ship back-to-back: checklist.md stays loaded (shared dependency)

BUDGET TABLE:
  Layer 0 (always loaded):     CLAUDE.md ~3K + commands.md ~1.2K = ~4.2K
  Layer 1 (on routing):        gstack-bridge SKILL.md ~1K
  Layer 2 (on command invoke): Active gstack SKILL.md = 3K–15K
  Layer 3 (within workflow):   Extra files (checklist.md ~2K, issue-taxonomy ~1.5K)

  PEAK at any moment: ~4.2K + 1K + 15K + 2K = ~22K tokens
  Without lazy loading (naive): ~120K+ tokens (all gstack skills loaded)
```

---

## Quick Mode Shortcuts

For simple invocations that don't need the full SKILL.md:

```
/browse [url]           → Just run: $B navigate [url] && $B screenshot
/qa --quick             → Read SKILL.md but skip exhaustive tier, run Quick only
/review [specific file] → Read SKILL.md, scope to that file only
/retro --brief          → Skip per-person breakdown, just metrics + top 3
```
