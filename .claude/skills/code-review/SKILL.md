---
name: code-review
description: "Pre-landing PR review. Analyzes diff against the base branch for SQL safety, LLM trust boundary violations, conditional side effects, and other structural issues. Use when asked to review PR, code review, pre-landing review, or check my diff."
model: opus
tools: ["Bash", "Read", "Edit", "Write", "Grep", "Glob", "AskUserQuestion"]
---

## Preamble (run first)

```bash
_BRANCH=$(git branch --show-current 2>/dev/null || echo "unknown")
echo "BRANCH: $_BRANCH"
```

---

## Step 0: Detect base branch

Determine which branch this PR targets. Use the result as "the base branch" in all subsequent steps.

1. Check if a PR already exists for this branch:
   `gh pr view --json baseRefName -q .baseRefName`
   If this succeeds, use the printed branch name as the base branch.

2. If no PR exists (command fails), detect the repo's default branch:
   `gh repo view --json defaultBranchRef -q .defaultBranchRef.name`

3. If both commands fail, fall back to `main`.

Print the detected base branch name. In every subsequent `git diff`, `git log`,
`git fetch`, `git merge`, and `gh pr create` command, substitute the detected
branch name wherever the instructions say "the base branch."

---

# Pre-Landing PR Review

You are running the `/code-review` workflow. Analyze the current branch's diff against the base branch for structural issues that tests don't catch.

---

## Step 1: Check branch

1. Run `git branch --show-current` to get the current branch.
2. If on the base branch, output: **"Nothing to review — you're on the base branch or have no changes against it."** and stop.
3. Run `git fetch origin <base> --quiet && git diff origin/<base> --stat` to check if there's a diff. If no diff, output the same message and stop.

---

## Step 1.5: Scope Drift Detection

Before reviewing code quality, check: **did they build what was requested — nothing more, nothing less?**

1. Read `TODOS.md` (if it exists). Read PR description (`gh pr view --json body --jq .body 2>/dev/null || true`).
   Read commit messages (`git log origin/<base>..HEAD --oneline`).
   **If no PR exists:** rely on commit messages and TODOS.md for stated intent — this is the common case since /code-review runs before /ship creates the PR.
2. Identify the **stated intent** — what was this branch supposed to accomplish?
3. Run `git diff origin/<base> --stat` and compare the files changed against the stated intent.
4. Evaluate with skepticism:

   **SCOPE CREEP detection:**
   - Files changed that are unrelated to the stated intent
   - New features or refactors not mentioned in the plan
   - "While I was in there..." changes that expand blast radius

   **MISSING REQUIREMENTS detection:**
   - Requirements from TODOS.md/PR description not addressed in the diff
   - Test coverage gaps for stated requirements
   - Partial implementations (started but not finished)

5. Output (before the main review begins):
   ```
   Scope Check: [CLEAN / DRIFT DETECTED / REQUIREMENTS MISSING]
   Intent: <1-line summary of what was requested>
   Delivered: <1-line summary of what the diff actually does>
   [If drift: list each out-of-scope change]
   [If missing: list each unaddressed requirement]
   ```

6. This is **INFORMATIONAL** — does not block the review. Proceed to Step 2.

---

## Step 2: Read the checklist

Read `.claude/skills/code-review/checklist.md`.

**If the file cannot be read, STOP and report the error.** Do not proceed without the checklist.

---

## Step 3: Get the diff

Fetch the latest base branch to avoid false positives from stale local state:

```bash
git fetch origin <base> --quiet
```

Run `git diff origin/<base>` to get the full diff. This includes both committed and uncommitted changes against the latest base branch.

---

## Step 4: Two-pass review

Apply the checklist against the diff in two passes:

1. **Pass 1 (CRITICAL):** SQL & Data Safety, Race Conditions & Concurrency, LLM Output Trust Boundary, Enum & Value Completeness
2. **Pass 2 (INFORMATIONAL):** Conditional Side Effects, Magic Numbers & String Coupling, Dead Code & Consistency, LLM Prompt Issues, Test Gaps, View/Frontend

**Enum & Value Completeness requires reading code OUTSIDE the diff.** When the diff introduces a new enum value, status, tier, or type constant, use Grep to find all files that reference sibling values, then Read those files to check if the new value is handled. This is the one category where within-diff review is insufficient.

Follow the output format specified in the checklist. Respect the suppressions — do NOT flag items listed in the "DO NOT flag" section.

---

## Step 4.5: Design Review (conditional, diff-scoped)

Check if the diff touches frontend files:

```bash
git diff origin/<base> --name-only | grep -E '\.(tsx|jsx|css|scss|html|vue|svelte)$' && echo "FRONTEND_CHANGED=true" || echo "FRONTEND_CHANGED=false"
```

**If `FRONTEND_CHANGED=false`:** Skip design review silently. No output.

**If `FRONTEND_CHANGED=true`:**

1. **Check for DESIGN.md.** If `DESIGN.md` or `design-system.md` exists in the repo root, read it. All design findings are calibrated against it — patterns blessed in DESIGN.md are not flagged. If not found, use universal design principles.

2. **Read each changed frontend file** (full file, not just diff hunks). Frontend files are identified by the extensions above.

3. **Apply design review** against the changed files. For each item:
   - **[HIGH] mechanical CSS fix** (`outline: none`, `!important`, `font-size < 16px`): classify as AUTO-FIX
   - **[HIGH/MEDIUM] design judgment needed**: classify as ASK
   - **[LOW] intent-based detection**: present as "Possible — verify visually"

4. **Include findings** in the review output under a "Design Review" header. Design findings merge with code review findings into the same Fix-First flow.

---

## Step 4.7: Review Army — Specialist Dispatch

### Detect stack and diff size

```bash
STACK=""
[ -f Gemfile ] && STACK="${STACK}ruby "
[ -f package.json ] && STACK="${STACK}node "
[ -f requirements.txt ] || [ -f pyproject.toml ] && STACK="${STACK}python "
[ -f go.mod ] && STACK="${STACK}go "
[ -f Cargo.toml ] && STACK="${STACK}rust "
echo "STACK: ${STACK:-unknown}"
DIFF_LINES=$(git diff origin/<base> --stat | tail -1 | grep -oE '[0-9]+ insertion' | grep -oE '[0-9]+' || echo "0")
echo "DIFF_LINES: $DIFF_LINES"
```

### Detect scope signals

From the diff, detect which areas are affected:
- **SCOPE_AUTH**: diff touches auth/login/session/token/permission files
- **SCOPE_BACKEND**: diff touches server/API/model/service files
- **SCOPE_FRONTEND**: diff touches components/views/CSS/JS files
- **SCOPE_MIGRATIONS**: diff touches migration/schema files
- **SCOPE_API**: diff touches controller/route/endpoint files

### Select specialists

**Always-on (every review with 50+ changed lines):**
1. **Testing** — read `.claude/skills/code-review/specialists/testing.md`
2. **Maintainability** — read `.claude/skills/code-review/specialists/maintainability.md`

**If DIFF_LINES < 50:** Skip all specialists. Print: "Small diff — specialists skipped." Continue to Step 5.

**Conditional (dispatch if matching scope signal is true):**
3. **Security** — if SCOPE_AUTH or (SCOPE_BACKEND and DIFF_LINES > 100). Read `specialists/security.md`
4. **Performance** — if SCOPE_BACKEND or SCOPE_FRONTEND. Read `specialists/performance.md`
5. **Data Migration** — if SCOPE_MIGRATIONS. Read `specialists/data-migration.md`
6. **API Contract** — if SCOPE_API. Read `specialists/api-contract.md`

Print: "Dispatching N specialists: [names]. Skipped: [names]."

### Dispatch specialists in parallel

For each selected specialist, launch an independent subagent via the Agent tool.
**Launch ALL selected specialists in a single message** so they run in parallel.

**Each specialist subagent prompt:**

"You are a specialist code reviewer. Run `git diff origin/<base>` to get the full diff.
Apply the checklist below against the diff.

For each finding, output a JSON object on its own line:
{"severity":"CRITICAL|INFORMATIONAL","confidence":N,"path":"file","line":N,"category":"category","summary":"description","fix":"recommended fix","specialist":"name"}

If no findings: output `NO FINDINGS` and nothing else.
Stack context: {STACK}

CHECKLIST:
{checklist content}"

- Use `subagent_type: "general-purpose"`
- Do NOT use `run_in_background` — all must complete before merge
- If any specialist fails, continue with results from successful ones

### Collect and merge findings

After all specialists complete:

1. Parse each specialist's output — skip "NO FINDINGS", parse JSON lines
2. **Deduplicate by fingerprint** (`path:line:category`). When duplicated:
   - Keep highest confidence, tag "MULTI-SPECIALIST CONFIRMED"
   - Boost confidence by +1 (cap at 10)
3. **Confidence gates**: 7+ show normally, 5-6 show with caveat, 3-4 suppress to appendix, 1-2 suppress entirely
4. **PR Quality Score**: `max(0, 10 - (critical * 2 + informational * 0.5))`

Output:
```
SPECIALIST REVIEW: N findings (X critical, Y informational) from Z specialists

[SEVERITY] (confidence: N/10, specialist: name) path:line — summary
  Fix: recommended fix
  [If MULTI-SPECIALIST CONFIRMED: note]

PR Quality Score: X/10
```

### Red Team dispatch (conditional)

**Activate only if** DIFF_LINES > 200 OR any specialist produced a CRITICAL finding.

Dispatch one more subagent with:
- The red-team checklist from `specialists/red-team.md`
- Summary of merged specialist findings
- The git diff command

Prompt: "You are a red team reviewer. N specialists already found these issues: {summary}.
Your job is to find what they MISSED. Focus on cross-cutting concerns, integration
boundaries, and failure modes that specialist checklists don't cover."

Merge Red Team findings into the list before Step 5.

---

## Step 4.9: Self-Regulation Metrics

### Health Score (Code Quality Gate)

Calculate a Health Score for the PR based on findings so far:

```
Base: 100 points
Deductions:
  CRITICAL finding:       -25 each
  INFORMATIONAL finding:  -5 each
  Scope drift detected:   -10
  Missing requirements:   -15 each

Weighted categories (when applicable):
  Security issues:     x1.5 multiplier on deduction
  Data safety issues:  x1.5 multiplier on deduction
```

**Output:**
```
Health Score: XX/100
[CRITICAL: N × -25 = -N] [INFORMATIONAL: N × -5 = -N] [Adjustments: ...]
```

**Gate:** Health Score < 50 → flag as HIGH RISK in review output (does not block, but prominently warned).

### WTF-Likelihood (Self-Regulation)

Track fix quality during the Fix-First phase. Starts at **0%**.

| Event | Adjustment |
|-------|------------|
| User rejects a fix (says "no", "skip", "revert") | +15% |
| Fix touches >3 files | +5% |
| Fix touches files NOT in the original diff | +20% |
| User accepts fix without comment | -5% (min 0%) |

**Thresholds:**
- **≥ 25%:** PAUSE. Use AskUserQuestion: "My fix accuracy is dropping (WTF-Likelihood: N%). Should I continue fixing, or would you prefer to handle the remaining items manually?"
- **≥ 40%:** STOP all auto-fixes. Present remaining issues as report only. Do not attempt further fixes.

**Track inline:** After each fix attempt, update the running score silently. Only surface to user when threshold is hit.

---

## Step 5: Fix-First Review

**Every finding gets action — not just critical ones.**

Output a summary header: `Pre-Landing Review: N issues (X critical, Y informational) | Health Score: XX/100`

### Step 5a: Classify each finding

For each finding, classify as AUTO-FIX or ASK per the Fix-First Heuristic in
checklist.md. Critical findings lean toward ASK; informational findings lean
toward AUTO-FIX.

### Step 5b: Auto-fix all AUTO-FIX items

Apply each fix directly. For each one, output a one-line summary:
`[AUTO-FIXED] [file:line] Problem → what you did`

### Step 5c: Batch-ask about ASK items

If there are ASK items remaining, present them in ONE AskUserQuestion:

- List each item with a number, the severity label, the problem, and a recommended fix
- For each item, provide options: A) Fix as recommended, B) Skip
- Include an overall RECOMMENDATION

Example format:
```
I auto-fixed 5 issues. 2 need your input:

1. [CRITICAL] app/models/post.rb:42 — Race condition in status transition
   Fix: Add `WHERE status = 'draft'` to the UPDATE
   → A) Fix  B) Skip

2. [INFORMATIONAL] app/services/generator.rb:88 — LLM output not type-checked before DB write
   Fix: Add JSON schema validation
   → A) Fix  B) Skip

RECOMMENDATION: Fix both — #1 is a real race condition, #2 prevents silent data corruption.
```

If 3 or fewer ASK items, you may use individual AskUserQuestion calls instead of batching.

### Step 5d: Apply user-approved fixes

Apply fixes for items where the user chose "Fix." Output what was fixed.

If no ASK items exist (everything was AUTO-FIX), skip the question entirely.

### Verification of claims

Before producing the final review output:
- If you claim "this pattern is safe" → cite the specific line proving safety
- If you claim "this is handled elsewhere" → read and cite the handling code
- If you claim "tests cover this" → name the test file and method
- Never say "likely handled" or "probably tested" — verify or flag as unknown

**Rationalization prevention:** "This looks fine" is not a finding. Either cite evidence it IS fine, or flag it as unverified.

---

## Step 5.5: TODOS cross-reference

Read `TODOS.md` in the repository root (if it exists). Cross-reference the PR against open TODOs:

- **Does this PR close any open TODOs?** If yes, note which items in your output: "This PR addresses TODO: <title>"
- **Does this PR create work that should become a TODO?** If yes, flag it as an informational finding.
- **Are there related TODOs that provide context for this review?** If yes, reference them when discussing related findings.

If TODOS.md doesn't exist, skip this step silently.

---

## Step 5.6: Documentation staleness check

Cross-reference the diff against documentation files. For each `.md` file in the repo root (README.md, ARCHITECTURE.md, CONTRIBUTING.md, CLAUDE.md, etc.):

1. Check if code changes in the diff affect features, components, or workflows described in that doc file.
2. If the doc file was NOT updated in this branch but the code it describes WAS changed, flag it as an INFORMATIONAL finding:
   "Documentation may be stale: [file] describes [feature/component] but code changed in this branch."

This is informational only — never critical.

If no documentation files exist, skip this step silently.

---

## Important Rules

- **Read the FULL diff before commenting.** Do not flag issues already addressed in the diff.
- **Fix-first, not read-only.** AUTO-FIX items are applied directly. ASK items are only applied after user approval. Never commit, push, or create PRs — that's /ship's job.
- **Be terse.** One line problem, one line fix. No preamble.
- **Only flag real problems.** Skip anything that's fine.
