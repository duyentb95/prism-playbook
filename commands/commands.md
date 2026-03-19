# /init-prism

Initialize PRISM framework for this project.

**Usage:** `/init-prism`

Creates `.prism/` folder structure with all template files.
Reads any existing project files to populate CONTEXT_HUB.
Asks user for WHY, WHO, STANDARDS to fill in context.

---

# /brainstorm

Socratic brainstorming session. Explore ideas BEFORE committing to a plan.

**Usage:** `/brainstorm [rough idea or problem statement]`

1. Master-Agent asks targeted questions to refine the idea
2. Explores alternatives you might not have considered
3. Presents design in digestible sections for validation
4. Saves brainstorm output to `.prism/brainstorms/{topic}_{date}.md`
5. Does NOT create tasks — this is pure thinking

**When to use:** When you have a vague idea and want to think it through before planning.
**After brainstorming:** Use `/plan` to convert the approved design into executable tasks.

---

# /plan

Enter Plan Mode. Brainstorm → Design → Micro-task breakdown.

**Usage:** `/plan [description of what needs to be done]`

1. **Brainstorm** (Socratic): Master asks 2-4 clarifying questions about WHY/WHO/WHAT
2. **Design**: Presents approach in short sections for user to approve piece by piece
3. **Plan**: Breaks into micro-tasks (2-10 min each) with exact file paths + verification steps
4. Presents task board with model tiers, dependencies, parallel groups, cost estimate
5. WAITS for user to type `GO` or `CONFIRMED`
6. On confirm → writes tasks to `.prism/tasks/` and updates MASTER_PLAN

**Shortcut:** `/plan --skip-brainstorm` → skip questions, go straight to design (khi bạn đã biết rõ cần gì)

---

# /status

Check current project status.

**Usage:** `/status`

Reads MASTER_PLAN.md → shows task board with current statuses.
Recommends next action.

---

# /compact

Compact current session context for handoff.

**Usage:** `/compact`

Activates Context Compactor → writes STAGING.md → signals ready for fresh session.

---

# /review

Review completed sub-agent output.

**Usage:** `/review TASK_NNN`

Master-Agent reads task brief + output → checks against DoD → reports findings.

---

# /adhoc

Handle an ad-hoc request outside current sprint.

**Usage:** `/adhoc [description]`

Creates isolated task in `.prism/adhoc/`. Does not pollute MASTER_PLAN.
After completion, extracts reusable knowledge into `.prism/knowledge/`.

---

# /gsd

Quick-strike mode. Do it now, no planning overhead.

**Usage:** `/gsd [simple task description]`

For tasks < 15 minutes. Master-Agent executes directly, commits, reports.

---

# /pipeline

Design a production agent pipeline (Brain → Body pattern).

**Usage:** `/pipeline [what needs to run automatically]`

Master-Agent designs a multi-agent pipeline:
1. Identifies agents needed (Fetch, Detect, Post, Coordinator, Analysis)
2. Assigns model tier per agent (minimize cost)
3. Defines fail behavior and retry logic
4. Estimates daily/monthly cost
5. Creates standalone scripts ready for deployment

---

# /deploy

Export and prepare scripts for production deployment.

**Usage:** `/deploy [pipeline name]`

1. Collects all pipeline scripts
2. Creates requirements.txt / package.json
3. Creates Dockerfile + docker-compose.yml
4. Creates config.yaml with env var references
5. Creates deployment README with instructions for OpenClaw / Railway / VPS

---

# /cost

Show cost analysis for current sprint and running pipelines.

**Usage:** `/cost`

Reads MASTER_PLAN → calculates:
- Sprint cost by model tier
- Running pipeline daily/monthly cost
- Optimization suggestions (any task using too expensive a model?)

---

## PRISM Cognitive Mode Commands (inline — đọc từ CLAUDE.md)

> Các commands này dùng methodology đã embedded trong CLAUDE.md.
> Output tự động lưu vào `.prism/` knowledge system.
> Phù hợp cho quick check, không cần load thêm SKILL.md.

# /ceo-review

CEO / Founder mode. Hỏi "Mình đang build đúng thứ chưa?"

**Usage:** `/ceo-review [mô tả feature / product]`

Không implement. Challenge the problem. Tìm "10-star product" ẩn bên trong request.
Dùng TRƯỚC /plan. Lock product direction trước khi tốn token engineering.
Output → `.prism/designs/ceo-review_{topic}_{date}.md`

---

# /eng-review

Engineering Manager mode. Lock in technical design.

**Usage:** `/eng-review [feature đã approved]`

Output: architecture diagram, data flow, state machine, edge cases, test matrix, failure modes.
"Diagrams force hidden assumptions into the open."
Output → `.prism/designs/eng-review_{topic}_{date}.md`

---

# /paranoid-review

Paranoid Staff Engineer mode. Tìm bugs pass CI nhưng nổ production.

**Usage:** `/paranoid-review [files/output cần review]`

Checklist: race conditions, N+1, trust boundaries, security, stale data, missing error handling.

---

# /ship-it

Release Engineer mode. Không nói thêm. Ship.

**Usage:** `/ship-it`

Code: sync → test → push → PR. Docs: format → export → deliver.

---

# /document-release

Technical Writer mode. Cập nhật docs match với thứ vừa ship.

**Usage:** `/document-release`

1. Đọc git diff → biết gì đã thay đổi
2. Scan: README, ARCHITECTURE, CONTRIBUTING, API docs, CHANGELOG, .env.example
3. Kiểm tra từng doc còn accurate không
4. Cập nhật / tạo mới docs bị outdated
5. Update `.prism/knowledge/` (RULES, GOTCHAS, TECH_DECISIONS, DICTIONARY)
6. Commit docs riêng biệt

**Blocking:** API changed → API docs MUST update. Setup changed → README MUST update.

---

# /qa-check

QA Engineer mode. Verify bằng evidence.

**Usage:** `/qa-check [what to verify]`

Check output vs expected. Save evidence vào `.prism/qa-reports/`.

---

# /retro

Retro mode (PRISM). Cuối sprint / cuối tuần.

**Usage:** `/retro`

Metrics, wins, improvements, compare vs previous retro. Save `.prism/retros/`.

---

## gstack Native Commands (lazy-load — đọc SKILL.md khi invoke)

> **Token rule**: Mỗi command bên dưới có SKILL.md riêng (3K–15K tokens).
> Agent chỉ đọc SKILL.md khi user invoke command — KHÔNG pre-load.
> Max 1 gstack SKILL.md loaded tại bất kỳ thời điểm nào.
> Router: `skills/gstack-bridge/SKILL.md` → resolve path → load → execute.

### Planning Phase

# /plan-ceo-review

gstack CEO/founder brain. Full methodology: reframe problem → 10-star product → scope back → present options.
→ Lazy-load `gstack/plan-ceo-review/SKILL.md`

---

# /plan-eng-review

gstack Tech Lead rigor. Forced diagrams, architecture, data flow, failure modes, test matrix.
→ Lazy-load `gstack/plan-eng-review/SKILL.md`

---

# /plan-design-review

gstack Senior designer's eye. 80-item audit, letter grades, AI slop detection. Report only.
→ Lazy-load `gstack/plan-design-review/SKILL.md`

---

# /design-review

gstack Designer + frontend dev. Same audit as /plan-design-review, then fixes issues with atomic commits.
→ Lazy-load `gstack/design-review/SKILL.md`

---

# /design-consultation

gstack Design consultant. Create DESIGN.md from scratch with competitive research, font/color preview.
→ Lazy-load `gstack/design-consultation/SKILL.md`

---

### Execution Phase

# /review

gstack Pre-landing code review. SQL safety, race conditions, LLM trust boundaries, enum completeness.
Auto-fixes mechanical issues, asks about risky ones. Triages Greptile comments.
→ Lazy-load `gstack/review/SKILL.md` + `gstack/review/checklist.md`

---

# /ship

gstack Fully automated: merge main, run tests, review diff, bump version, changelog, commit, push, create PR.
→ Lazy-load `gstack/ship/SKILL.md` + `gstack/review/checklist.md`

---

# /doc-release

gstack Post-ship doc update. Cross-references git diff against README, ARCHITECTURE, CONTRIBUTING, CHANGELOG.
→ Lazy-load `gstack/document-release/SKILL.md`

---

### QA & Testing Phase

# /qa

gstack Test → Fix → Verify loop. Diff-aware (auto-detects changed pages). Three tiers: Quick/Standard/Exhaustive.
→ Lazy-load `gstack/qa/SKILL.md`

---

# /qa-only

gstack Report-only QA. Same methodology as /qa but never fixes anything.
→ Lazy-load `gstack/qa-only/SKILL.md`

---

# /browse

gstack Headless Chromium browser. Navigate, click, fill forms, screenshot, check console. ~100ms per command.
→ Lazy-load `gstack/browse/SKILL.md`

---

# /setup-browser-cookies

Import real browser cookies (Chrome, Arc, Brave, Edge) into headless session. For testing auth pages.
→ Lazy-load `gstack/setup-browser-cookies/SKILL.md`

---

### Operations Phase

# /retro (gstack)

gstack Weekly engineering retrospective. Commit analysis, session detection, team breakdown, shipping velocity.
→ Lazy-load `gstack/retro/SKILL.md`

**Note:** `/retro` resolves to PRISM retro (inline). Use `/retro --gstack` or explicitly ask for "gstack retro" for the full gstack version.

---

# /gstack-upgrade

Upgrade gstack to latest version.
→ Lazy-load `gstack/gstack-upgrade/SKILL.md`

---

### Multi-AI & Debugging

# /codex

gstack Multi-AI second opinion. Review, challenge, or ask OpenAI Codex CLI about your code. **Note: sends code to OpenAI.**
→ Lazy-load `gstack/codex/SKILL.md`

---

# /investigate

gstack Systematic root-cause debugging. Trace errors, find why things fail, identify root cause.
→ Lazy-load `gstack/investigate/SKILL.md`

---

### Safety & Scope Control

# /careful

gstack Destructive command warnings. Warns before any risky/irreversible operation.
→ Lazy-load `gstack/careful/SKILL.md`

---

# /freeze

gstack Directory-scoped edit lock. Restrict edits to a specific module/directory.
→ Lazy-load `gstack/freeze/SKILL.md`

---

# /unfreeze

gstack Remove edit restrictions set by /freeze.
→ Lazy-load `gstack/unfreeze/SKILL.md`

---

# /guard

gstack Maximum safety mode. Combines /freeze (edit restrictions) + /careful (destructive warnings).
→ Lazy-load `gstack/guard/SKILL.md`

---

### Brainstorming

# /office-hours

gstack YC Office Hours — startup diagnostic and builder brainstorm. Different from PRISM /brainstorm: uses YC framework.
→ Lazy-load `gstack/office-hours/SKILL.md`

---

## PRISM vs gstack — Khi nào dùng cái nào?

| Nhu cầu | PRISM Command | gstack Command | Chọn nào? |
|---------|--------------|----------------|-----------|
| Quick CEO challenge | `/ceo-review` | `/plan-ceo-review` | PRISM cho quick, gstack cho deep |
| Architecture lock | `/eng-review` | `/plan-eng-review` | PRISM cho quick, gstack cho forced diagrams |
| Code review | `/paranoid-review` | `/review` | gstack: auto-fix + Greptile triage |
| Ship code | `/ship-it` | `/ship` | gstack: full automation (version bump, PR) |
| Update docs | `/document-release` | `/doc-release` | gstack: cross-ref git diff |
| QA testing | `/qa-check` | `/qa` | gstack: browser automation + diff-aware |
| Sprint retro | `/retro` | `/retro --gstack` | gstack: commit analysis + metrics |
| Design audit (report) | — | `/plan-design-review` | gstack only |
| Design audit (fix) | — | `/design-review` | gstack only (was /qa-design-review) |
| Design system | — | `/design-consultation` | gstack only |
| Browser automation | — | `/browse` | gstack only |
| Second opinion | — | `/codex` | gstack only (sends code to OpenAI) |
| Root-cause debugging | — | `/investigate` | gstack only |
| Startup brainstorm | `/brainstorm` | `/office-hours` | PRISM: general. gstack: YC framework |
| Destructive warnings | — | `/careful` | gstack only |
| Edit lock | — | `/freeze` / `/unfreeze` | gstack only |
| Full safety mode | — | `/guard` | gstack only (freeze + careful) |

