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
5. Sets up `.prism/` + `CLAUDE.md` in current directory

</details>

---

## 2. Add to Your Project

```bash
./setup --project ~/my-project
```

This creates two things in your project:

- **`CLAUDE.md`** — instructions for Claude (how to think about your project)
- **`.prism/`** — shared knowledge folder (grows smarter over time)

### Customize for your project (2 minutes)

Open `.prism/CONTEXT_HUB.md` and fill in:

```markdown
## WHY — Why does this project exist
Building a personal expense tracker because existing apps are too complex.

## WHO — Who uses the output
- Primary: Myself — daily use on mobile
- Secondary: Friends who want to try it

## STANDARDS — Technical standards
- Language: TypeScript + React Native
- Testing: Jest
- Style: ESLint + Prettier
```

Doesn't need to be perfect. Claude will ask for more if needed.

---

## 3. Start Using

```bash
cd ~/my-project
claude
```

Claude reads `CLAUDE.md` automatically. Just describe what you need:

```
> I need a REST API for a todo list. Node.js + Express + SQLite.
  CRUD endpoints + basic JWT auth.
```

Claude will:
1. **Ask** — "Is this for mobile, web, or both? Do you need pagination?"
2. **Design** — Database schema, API endpoints, auth flow (section by section, you approve)
3. **Plan** — Micro-tasks with model tiers and cost estimate
4. **Wait for `GO`** — Nothing executes until you approve

After you type `GO`:
- Small tasks → Claude does it directly
- Complex tasks → creates task briefs in `.prism/tasks/`
- You can run sub-agents in parallel (see below)

---

## 4. Running Sub-Agents (for complex tasks)

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

## 5. Everyday Commands

### Planning & Execution

| Command | When | Time |
|---------|------|------|
| `/plan [task]` | Complex task — design first, then execute | 3-5 min |
| `GO` | Approve the plan | — |
| `/gsd [task]` | Simple task — just do it now | 1-5 min |
| `/brainstorm [idea]` | Vague idea — explore before committing | 5-10 min |

### Quality & Ship

| Command | When | Time |
|---------|------|------|
| `/paranoid-review` | Before shipping — find production bugs | 3-5 min |
| `/qa-check` | After shipping — verify with evidence | 3-5 min |
| `/ship-it` | Ready to ship — sync, test, commit, push | 1-2 min |

### Context & Knowledge

| Command | When | Time |
|---------|------|------|
| `/compact` | Session is getting long, Claude starts forgetting | 1 min |
| `/retro` | End of sprint — what worked, what to improve | 5-10 min |

---

## 6. Common Scenarios

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

## 7. Tips

1. **Always say WHY** — "Build dashboard" is weak. "Build dashboard so I can track trading bot PnL every morning" is strong.
2. **Review the plan before GO** — 2 minutes reviewing saves 30 minutes fixing.
3. **`/compact` when sessions get long** — keeps Claude sharp.
4. **Commit `.prism/`** — knowledge persists across sessions and team members.
5. **`.claudecodeignore` is your friend** — keeps Claude from reading node_modules.

---

## 8. Using with a Team

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

## 9. Choosing a CLAUDE.md Template

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

## 10. FAQ

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

---

**Full command reference:** See [README.md](README.md)
