# PRISM — AI Team Playbook

> **P**lan → **R**eview → **I**mplement → **S**hip → **M**onitor
>
> Make Claude Code 2-3x more productive. Stop guessing, start structuring.
>
> *Giúp Claude Code productive gấp 2-3x. Ngừng đoán, bắt đầu có cấu trúc.*

---

## What is PRISM?

A set of conventions, templates, and pre-built skills that make Claude Code work like a professional AI team — not just a chatbot that writes code.

**Not a library. Not a platform. A playbook.** Install it, use it, forget it's there.

```
WITHOUT PRISM:
  You → "Build me an API" → Claude writes 500 lines → wrong → fix → fix → lost context

WITH PRISM:
  You → "Build me an API" → Claude asks WHY → designs → you approve → executes correctly
  Knowledge saved → next session picks up where you left off
```

---

## Install (2 minutes)

```bash
git clone --recursive https://github.com/duyentb95/prism-playbook.git
cd prism-playbook
./setup
```

Done. Open any project with `claude` — PRISM skills are available globally.

**Add to an existing project:**
```bash
./setup --project ~/my-project
```

This copies `CLAUDE.md` + `.prism/` into your project. Commit them to git — teammates get the context automatically.

---

## Use It

```bash
cd ~/my-project
claude

# Describe what you need — Claude asks first, then plans, then executes
> I need a REST API with auth and CRUD for a todo app

# Or use specific commands:
> /plan Build user authentication with JWT
> /paranoid-review
> /ship-it
> /qa-check
```

### Core Commands

| Command | What it does | Time |
|---------|-------------|------|
| `/plan [task]` | Break into micro-tasks, design first | 3-5 min |
| `GO` | Approve plan, start execution | — |
| `/gsd [small task]` | Just do it, no planning | 1-5 min |
| `/paranoid-review` | Find production bugs before they find you | 3-5 min |
| `/ship-it` | Sync, test, commit, push, PR | 1-2 min |
| `/qa-check` | Verify output with evidence | 3-5 min |
| `/retro` | What went well, what to improve | 5-10 min |
| `/compact` | Session too long? Save state, start fresh | 1 min |

### When You Want Deeper Analysis (via gstack)

| Command | Mode |
|---------|------|
| `/plan-ceo-review` | "Am I building the right thing?" |
| `/plan-eng-review` | Architecture, diagrams, edge cases |
| `/review` | Pre-merge code review with auto-fix |
| `/ship` | Full ship automation (version bump, PR) |
| `/qa` | Diff-aware browser testing |
| `/browse [url]` | Headless browser (~100ms) |

---

## What You Get

### 1. CLAUDE.md — Project Instructions for Claude

Tells Claude how to think about your project. Copied into your project root.

Pick a template that fits:
- **[Web App](templates/claude-web-app.md)** — Next.js, React, Vue, Svelte
- **[API Backend](templates/claude-api-backend.md)** — Python, Node, Go, Rust
- **[Data Pipeline](templates/claude-data-pipeline.md)** — ETL, analytics, notebooks
- **[Non-Code](templates/claude-non-code.md)** — Reports, strategy, documentation
- **[Minimal](templates/claude-minimal.md)** — Smallest useful starting point

### 2. .prism/ — Shared Knowledge

A folder in your project that grows smarter over time:

```
.prism/
├── CONTEXT_HUB.md       # WHY this project exists, WHO it's for, STANDARDS
├── MASTER_PLAN.md       # Task board — what's done, what's next
├── DICTIONARY.md        # Project terminology — Claude never guesses meaning
├── knowledge/
│   ├── RULES.md         # Patterns discovered ("always do X when Y")
│   ├── GOTCHAS.md       # Traps encountered ("don't do Z because...")
│   └── TECH_DECISIONS.md # Architecture choices + reasoning
├── tasks/               # Sub-agent task briefs
└── qa-reports/          # QA results, review findings
```

**Commit `.prism/` to git.** Teammates pull → their Claude has all the context. No re-explaining.

### 3. 12 Pre-Built Skills

Installed globally to `~/.claude/skills/`. Available in every project.

| Skill | Role | Model |
|-------|------|-------|
| master-agent | Plans, decomposes, delegates, reviews | Opus |
| sub-agent | Focused executor, reads brief → delivers | Sonnet |
| paranoid-review | Finds production bugs (2-pass review) | Opus |
| qa-engineer | Health scoring, evidence-based verification | Sonnet |
| ship-engineer | Sync, test, commit, push, PR | Sonnet |
| design-auditor | 80-item UI/UX checklist + AI slop detection | Sonnet |
| browser-agent | Browser automation (gstack browse + Playwright fallback) | Sonnet |
| sprint-retro | Metrics, wins, improvements, action items | Sonnet |
| cost-tracker | Token estimates, model tier optimization | Haiku |
| knowledge-spine | Captures rules, gotchas, decisions | Sonnet |
| context-compactor | Session handoff (STAGING.md) | Sonnet |
| gstack-bridge | Routes to gstack cognitive modes (lazy-load) | Sonnet |

---

## How It Works

```
You describe what you need
    │
    ▼
Claude ASKS first (doesn't jump to code)
    │ "Who is this for? What's the priority? Any constraints?"
    │
    ▼
Claude presents a DESIGN (section by section, you approve)
    │
    ▼
Claude creates a PLAN (micro-tasks, model tiers, cost estimate)
    │ ← You review → type GO
    │
    ├── Small task? → Claude does it directly (GSD mode)
    │
    ├── Complex? → Sub-agents execute in parallel
    │   ├── Agent A: TASK_001 → done
    │   └── Agent B: TASK_002 → done
    │
    ▼
Review → QA → Ship → Knowledge saved for next time
```

---

## Team Use (optional — works great solo too)

When multiple people use PRISM on the same repo:

```bash
# Your workflow
claude                            # Claude reads CLAUDE.md + .prism/
# ... do work ...
git add .prism/ && git commit     # Save knowledge to git

# Teammate's workflow
git pull                          # Gets your .prism/ updates
claude                            # Their Claude has all your context
```

`.prism/knowledge/` grows over time. Rules, gotchas, decisions — shared team brain via git.

---

## Why This Playbook?

| Problem | How PRISM solves it |
|---------|-------------------|
| Claude jumps straight to code | Asks first, designs, then you approve |
| Context lost in long chats | `/compact` → STAGING.md → fresh session resumes |
| Knowledge lost between sessions | `.prism/knowledge/` persists via git |
| Wasted tokens on irrelevant files | `.claudecodeignore` + isolated sub-agent sessions |
| Inconsistent output quality | CONTEXT_HUB + templates + RULES.md |
| No visibility into what AI is doing | MASTER_PLAN + structured handovers |

---

## Requirements

| Required | Install |
|----------|---------|
| **Claude Code** | `npm install -g @anthropic-ai/claude-code` |
| **Claude account** | [claude.ai](https://claude.ai) (Pro $20/mo or Max $100/mo) |
| **Git** | [git-scm.com](https://git-scm.com) |

| Optional | Why |
|----------|-----|
| Bun | For gstack `/browse` browser automation |
| tmux | Multiple agent terminals side-by-side |

---

## Management

```bash
./setup --status     # What's installed
./setup --update     # Update gstack to latest
./setup --uninstall  # Remove global installs
```

---

**Full guide:** [GETTING-STARTED.md](GETTING-STARTED.md) | **License:** MIT
