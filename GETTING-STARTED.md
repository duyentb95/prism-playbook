# Getting Started with PRISM

> Zero to productive in 15 minutes. No prior knowledge of "agents" or "skills" needed.
>
> *Từ zero đến productive trong 15 phút. Không cần biết trước về "agents" hay "skills".*

---

## 1. Install

```bash
git clone --recursive https://github.com/duyentb95/prism-playbook.git
cd prism-playbook
./setup
```

That's it. PRISM skills are now available globally in Claude Code.

<details>
<summary>What ./setup does (click to expand)</summary>

1. Checks prerequisites (Git, Claude Code)
2. Clones gstack (browser automation + cognitive modes) if needed
3. Copies 12 PRISM skills → `~/.claude/skills/`
4. Copies gstack → `~/.claude/skills/gstack/`
5. Copies 30 slash commands → `~/.claude/commands/`

</details>

---

## 2. Add to Your Project

```bash
./setup --project ~/my-project
```

Setup asks 5 quick questions about your project (~30 seconds), then creates:

- **`CLAUDE.md`** — instructions for Claude (how to think about your project)
- **`.prism/`** — shared knowledge folder (grows smarter over time), pre-filled with your answers
- **`.claude/commands/`** — 30 slash commands for the full PRISM workflow

---

## 3. Your First 5 Minutes

```bash
cd ~/my-project
claude
```

Type `/start` — PRISM detects your project state and guides you:

```
> /start

🧭 Welcome to My Cool App!
  Sprint: #1 — Project Setup (no tasks yet)

  What would you like to do?
  A) I have a new idea — let's brainstorm        → /brainstorm
  B) I know what to build — let's plan            → /plan
  C) Quick fix or small task — just do it          → /gsd
```

### Example: "I have an idea for a todo app"

Here's what a real session looks like:

```
YOU:  /start
      → Choose A (brainstorm)

YOU:  I want a todo app with smart prioritization

CLAUDE: [Asks 3-4 questions: WHO uses it? Mobile or web? What makes it "smart"?]

YOU:  For myself, web app, prioritize by deadline + energy level

CLAUDE: [Presents design: features, tech stack, architecture]
        "Ready to plan? Type /plan to break this into tasks."

YOU:  /plan

CLAUDE: [CEO Review: "Are we building the right thing?"]
        [Eng Review: architecture diagram, data flow, edge cases]
        [Task breakdown: 8 micro-tasks, cost estimate]
        "Type GO to start execution."

YOU:  GO

CLAUDE: [Executes tasks, creates sub-agent briefs for complex ones]
        "Done. 5/8 tasks completed. 3 task briefs ready for sub-agents."
```

**Total time: ~10 minutes from idea to working plan + first code.**

---

## 4. Three Workflows — Pick One

### 🆕 New Project / New Idea

```
/start → /brainstorm → /ceo-review → /eng-review → /plan → GO
```

Full thinking flow: explore → validate → design → plan → execute.

### 🔧 Feature / Sprint Task

```
/plan Build user authentication with JWT → GO
```

Skip brainstorming, go straight to design + execution.

### ⚡ Quick Fix (< 15 min)

```
/gsd Fix the login button not working on mobile
```

No planning. Just do it. Done.

---

## 5. Command Map

```
    THINK                PLAN              BUILD
 ┌──────────┐      ┌──────────┐      ┌──────────┐
 │/brainstorm│─────▶│  /plan   │─────▶│   GO     │
 │/ceo-review│      │          │      │  /gsd    │
 │/eng-review│      │          │      │          │
 └──────────┘      └──────────┘      └──────────┘
                                           │
                                           ▼
    LEARN               SHIP              CHECK
 ┌──────────┐      ┌──────────┐      ┌──────────┐
 │  /retro  │◀─────│ /ship-it │◀─────│/paranoid │
 │          │      │/doc-release│     │/qa-check │
 └──────────┘      └──────────┘      └──────────┘

 Navigation: /start (smart entry point) · /status (where am I?) · /compact (save & resume)
```

### All Commands at a Glance

| Phase | Command | What it does | When to use |
|-------|---------|-------------|-------------|
| **Start** | `/start` | Smart entry — detects state, suggests next step | First thing every session |
| **Think** | `/brainstorm [idea]` | Socratic exploration, no commitment | Vague idea, need clarity |
| | `/ceo-review [topic]` | "Are we building the right thing?" | Before committing to a direction |
| | `/eng-review [topic]` | Architecture, data flow, edge cases | Before writing code |
| **Plan** | `/plan [task]` | Full flow: brainstorm → design → micro-tasks | Complex features |
| **Build** | `GO` | Approve plan, start execution | After reviewing a plan |
| | `/gsd [task]` | Do it now, no planning | Quick fixes, < 15 min |
| **Check** | `/paranoid-review` | Find production bugs before they find you | Before shipping |
| | `/qa-check` | Verify output with evidence | After shipping |
| **Ship** | `/ship-it` | Sync, test, commit, push — no talking | Code is ready |
| | `/document-release` | Update docs to match what shipped | After shipping code |
| **Learn** | `/retro` | Sprint retrospective — wins, improvements | End of sprint/week |
| **Context** | `/start` | Smart entry point | Beginning of session |
| | `/status` | Current sprint status | "Where was I?" |
| | `/compact` | Save state for session handoff | Session getting long |
| | `/adhoc [task]` | Handle out-of-scope request | Boss wants something unplanned |

---

## 6. Running Sub-Agents (for complex tasks)

When Claude creates task briefs, run each in a separate terminal:

```bash
# Terminal 2
claude
> Read .prism/tasks/TASK_002_database.md and EXECUTE. Assume I am AFK.

# Terminal 3 (parallel)
claude
> Read .prism/tasks/TASK_003_auth.md and EXECUTE. Assume I am AFK.
```

Each sub-agent reads its brief → executes → reports status (DONE / BLOCKED).

Back in your main terminal, review the results:
```
> Review TASK_002 and TASK_003
```

---

## 7. Common Scenarios

### "Quick bug fix"

```
> /gsd Fix CORS error on /api/todos endpoint
```

Done in 2 minutes. No planning overhead.

### "Session is too long, Claude is forgetting"

```
> /compact
```

Claude saves state to `.prism/STAGING.md`. Open a fresh session:

```bash
claude
> Read .prism/STAGING.md and resume
```

Continues exactly where you left off.

### "Boss wants something out of scope"

```
> /adhoc Boss wants CSV export but we're mid-sprint on auth
```

Handled in `.prism/adhoc/` — doesn't disrupt main work.

### "I don't code — I need reports/strategy"

PRISM works for any task:

```
> /plan Create Q1 market analysis report for the investment team
```

Claude asks audience, key metrics, format → designs outline → you approve → executes.

---

## 8. Tips

1. **Type `/start` when unsure** — it reads your project state and tells you what to do next.
2. **Always say WHY** — "Build dashboard" is weak. "Build dashboard so I can track trading bot PnL every morning" is strong.
3. **Review the plan before GO** — 2 minutes reviewing saves 30 minutes fixing.
4. **`/compact` when sessions get long** — keeps Claude sharp.
5. **Commit `.prism/`** — knowledge persists across sessions and team members.

---

## 9. Using with a Team

No special setup needed. Just commit `.prism/` to git:

```bash
git add .prism/ CLAUDE.md .claudecodeignore
git commit -m "Add PRISM playbook"
git push
```

Teammates pull → their Claude reads the same context. Knowledge compounds:

- **Developer A** discovers a gotcha → adds to `.prism/knowledge/GOTCHAS.md`
- **Developer B** pulls → their agent knows about the gotcha
- **Developer C** runs `/retro` → everyone sees sprint metrics

Convention: `git pull` before starting a session, commit `.prism/` changes when done.

---

## 10. Choosing a CLAUDE.md Template

The default `CLAUDE.md` is comprehensive. For specific project types, use a focused template:

| Template | Best for | Size |
|----------|---------|------|
| [Minimal](templates/claude-minimal.md) | Quick start, small projects | ~50 lines |
| [Web App](templates/claude-web-app.md) | Frontend + full-stack | ~100 lines |
| [API Backend](templates/claude-api-backend.md) | REST/GraphQL APIs | ~100 lines |
| [Data Pipeline](templates/claude-data-pipeline.md) | ETL, analytics | ~100 lines |
| [Non-Code](templates/claude-non-code.md) | Reports, strategy, docs | ~80 lines |

Copy the template over your CLAUDE.md:
```bash
cp templates/claude-minimal.md ~/my-project/CLAUDE.md
```

---

## 11. FAQ

**"Do I need the full CLAUDE.md? It's huge."**
No. Use `templates/claude-minimal.md` to start. Add sections as needed.

**"How much does it cost?"**
PRISM is free. You pay for Claude: Pro ($20/mo) or Max ($100/mo recommended).

**"Claude still jumps straight to code?"**
Check that `CLAUDE.md` exists at your project root. Claude reads it automatically.

**"Sub-agent is BLOCKED?"**
Read the task brief → HANDOVER section → see why. Add missing context, re-run.

**"gstack commands don't work?"**
Run `./setup --status` to check. If gstack is missing: `./setup --update`.

**"I don't know which command to use."**
Type `/start` — it detects your project state and recommends the right next step.

---

**Full command reference:** See [README.md](README.md)
