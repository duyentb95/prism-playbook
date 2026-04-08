---
name: autoplan
description: "Auto-review pipeline — runs CEO → eng review sequentially with auto-decisions using 6 decision principles. Surfaces only taste decisions at a final approval gate. One command, fully reviewed plan out. Use when asked to autoplan, auto review, run all reviews, or make the decisions for me."
model: sonnet
tools: ["Bash", "Read", "Write", "Edit", "Glob", "Grep", "AskUserQuestion"]
---

## Preamble (run first)

```bash
_BRANCH=$(git branch --show-current 2>/dev/null || echo "unknown")
_HAS_PLAN=$([ -f ".prism/MASTER_PLAN.md" ] && echo "true" || echo "false")
_HAS_GATE=$([ -f ".prism/GATE_STATUS.md" ] && echo "true" || echo "false")
_HAS_CEO=$([ -f ".claude/skills/ceo-review/SKILL.md" ] && echo "true" || echo "false")
_HAS_ENG=$([ -f ".claude/skills/eng-review/SKILL.md" ] && echo "true" || echo "false")
echo "BRANCH: $_BRANCH | PLAN: $_HAS_PLAN | GATE: $_HAS_GATE | CEO_SKILL: $_HAS_CEO | ENG_SKILL: $_HAS_ENG"
source .claude/scripts/prism-telemetry.sh 2>/dev/null && prism_tel_start "autoplan"
```

If `_HAS_CEO` or `_HAS_ENG` is false: BLOCKED — required skill files missing.

## AskUserQuestion Format

**ALWAYS follow this structure:**
1. **Re-ground:** Project, branch (`_BRANCH`), current phase. (1-2 sentences)
2. **Simplify:** Plain English a smart 16-year-old can follow.
3. **Recommend:** `RECOMMENDATION: Choose [X] because [reason]`
4. **Options:** `A) ... B) ... C) ...`

---

# /autoplan — Auto-Review Pipeline

One command. Rough plan in, fully reviewed plan out.

/autoplan reads the CEO and eng review skills from `.claude/skills/` and runs them
sequentially at full depth — same rigor, same sections, same methodology as running
each skill manually. The only difference: intermediate AskUserQuestion calls are
auto-decided using the 6 principles below. Taste decisions (where reasonable people
could disagree) are surfaced at a final approval gate.

---

## The 6 Decision Principles

These rules auto-answer every intermediate question:

1. **Choose completeness** — Ship the whole thing. Pick the approach that covers more edge cases.
2. **Boil lakes** — Fix everything in the blast radius (files modified by this plan + direct importers). Auto-approve expansions in blast radius AND < 1 day effort (< 5 files, no new infra).
3. **Pragmatic** — If two options fix the same thing, pick the cleaner one. 5 seconds choosing, not 5 minutes.
4. **DRY** — Duplicates existing functionality? Reject. Reuse what exists.
5. **Explicit over clever** — 10-line obvious fix > 200-line abstraction. Pick what a new contributor reads in 30 seconds.
6. **Bias toward action** — Merge > review cycles > stale deliberation. Flag concerns but don't block.

**Conflict resolution (context-dependent tiebreakers):**
- **CEO phase:** P1 (completeness) + P2 (boil lakes) dominate.
- **Eng phase:** P5 (explicit) + P3 (pragmatic) dominate.

---

## Decision Classification

**Mechanical** — one clearly right answer. Auto-decide silently.

**Taste** — reasonable people could disagree. Auto-decide with recommendation, but surface at the final gate. Three sources:
1. **Close approaches** — top two are both viable with different tradeoffs.
2. **Borderline scope** — in blast radius but 3-5 files, or ambiguous radius.
3. **Model disagreement** — subagent recommends differently with valid reasoning.

---

## Sequential Execution — MANDATORY

Phases MUST execute in strict order: CEO → Eng.
Each phase MUST complete fully before the next begins.
NEVER run phases in parallel — each builds on the previous.

---

## What "Auto-Decide" Means

Auto-decide replaces the USER'S judgment with the 6 principles. It does NOT replace
the ANALYSIS. Every section in the loaded skill files must still be executed at full
depth. The only thing that changes is who answers: you do, using the 6 principles.

**Two exceptions — never auto-decided:**
1. **Premises** (Phase 1) — require human judgment about what problem to solve.
2. **User Challenges** — when analysis shows the user's stated direction should change.

**You MUST still:**
- READ the actual code, diffs, and files each section references
- PRODUCE every output the section requires (diagrams, tables, registries)
- IDENTIFY every issue the section is designed to catch
- DECIDE each issue using the 6 principles
- LOG each decision in the audit trail

**You MUST NOT:**
- Compress a review section into a one-liner
- Write "no issues found" without showing what you examined
- Skip a section because "it doesn't apply" without stating what you checked

---

## Phase 0: Intake

### Step 1: Read context

- Read CLAUDE.md, MASTER_PLAN.md (if exists), git log -30, git diff --stat
- Detect UI scope: grep the plan for view/rendering terms (component, screen, form,
  button, modal, layout, dashboard). Require 2+ matches.

### Step 2: Load skill files from disk

Read each file using the Read tool:
- `.claude/skills/ceo-review/SKILL.md`
- `.claude/skills/eng-review/SKILL.md`

**Section skip list — when following a loaded skill, SKIP these sections:**
- Preamble (run first)
- AskUserQuestion Format
- Completion Status Protocol
- Gate Integration (autoplan handles gates at the end)

Follow ONLY the review-specific methodology, sections, and required outputs.

Output: "Here's what I'm working with: [plan summary]. UI scope: [yes/no].
Starting full review pipeline with auto-decisions."

---

## Phase 1: CEO Review (Strategy & Scope)

Follow ceo-review/SKILL.md — all sections, full depth.
Override: every AskUserQuestion → auto-decide using the 6 principles.

**Override rules:**
- Mode selection: SELECTIVE EXPANSION (default)
- Premises: accept reasonable ones (P6), challenge only clearly wrong ones
- **GATE: Present premises to user for confirmation** — this is the ONE question
  that is NOT auto-decided. Premises require human judgment.
- Alternatives: pick highest completeness (P1). If tied, pick simplest (P5).
  If top 2 are close → mark TASTE DECISION.
- Scope expansion: in blast radius + <1d effort → approve (P2). Outside → defer (P3).
  Duplicates → reject (P4). Borderline → mark TASTE DECISION.
- All review sections: run fully, auto-decide each issue, log every decision.

**Required outputs from Phase 1:**
- Premise challenge with specific premises named and evaluated
- "NOT in scope" section with deferred items
- "What already exists" mapping sub-problems to existing code
- Error & Rescue Registry (from Section 2)
- Failure Modes Registry
- Dream state delta
- Completion Summary (the full table from CEO skill)

**PHASE 1 COMPLETE.** Emit:
> **Phase 1 complete.** [N] issues found, [M] auto-decided, [K] taste decisions surfaced.
> Passing to Phase 2.

---

## Phase 2: Eng Review + Architecture

Follow eng-review/SKILL.md — all sections, full depth.
Override: every AskUserQuestion → auto-decide using the 6 principles.

**Override rules:**
- Scope challenge: never reduce scope of a complete plan (P2)
- Architecture: explicit over clever (P5)
- Test gaps: always add tests (P1)
- TODOS: collect all deferred scope expansions from Phase 1, auto-write

**Required outputs from Phase 2:**
- Scope challenge with actual code analysis
- Architecture ASCII diagram
- Test diagram mapping codepaths to coverage
- "NOT in scope" section
- "What already exists" section
- Failure modes registry with critical gap flags
- Completion Summary (the full table from Eng skill)

---

## Decision Audit Trail

After each auto-decision, append a row to the plan file:

```markdown
## Decision Audit Trail

| # | Phase | Decision | Classification | Principle | Rationale |
|---|-------|----------|---------------|-----------|-----------|
```

Write one row per decision incrementally (via Edit).

---

## Phase 3: Final Approval Gate

**STOP here and present to the user.**

```
## /autoplan Review Complete

### Plan Summary
[1-3 sentence summary]

### Decisions Made: [N] total ([M] auto-decided, [K] taste choices)

### Your Choices (taste decisions)
[For each taste decision:]
**Choice [N]: [title]** (from [phase])
I recommend [X] — [principle]. But [Y] is also viable:
  [1-sentence downstream impact if you pick Y]

### Auto-Decided: [M] decisions [see Decision Audit Trail in plan file]

### Review Scores
- CEO: [summary — mode, issues, gaps]
- Eng: [summary — architecture, test coverage, critical gaps]

### Deferred to .prism/knowledge/ or TODOS
[Items auto-deferred with reasons]
```

AskUserQuestion options:
- A) Approve as-is (accept all recommendations)
- B) Approve with overrides (specify which taste decisions to change)
- C) Interrogate (ask about any specific decision)
- D) Revise (the plan needs changes — re-run affected phase)
- E) Reject (start over)

---

## Gate Integration

On approval, update `.prism/GATE_STATUS.md`:

1. Replace `- [ ] plan-approved` with `- [x] plan-approved (<today's date>) — autoplan approved`
2. Replace `- [ ] ceo-locked` with `- [x] ceo-locked (<today's date>) — via /autoplan`
3. Replace `- [ ] eng-locked` with `- [x] eng-locked (<today's date>) — via /autoplan`

If GATE_STATUS.md doesn't exist, create it from `.prism-template/GATE_STATUS.md`.

This passes 3 gates in one command — the user can proceed directly to implementation.

---

## Important Rules

- **Never abort.** The user chose /autoplan. Respect that. Surface taste decisions, never redirect to interactive review.
- **Two gates.** The non-auto-decided questions are: (1) premise confirmation in Phase 1, and (2) User Challenges — when analysis shows user's stated direction should change. Everything else uses the 6 principles.
- **Log every decision.** No silent auto-decisions. Every choice gets a row in the audit trail.
- **Full depth means full depth.** Do not compress or skip sections. Read the code, produce the outputs, identify every issue. A one-sentence summary of a section is not "full depth."
- **Sequential order.** CEO → Eng. Each phase builds on the last.
- **Artifacts are deliverables.** Failure modes registry, ASCII diagrams, test plan — must exist when review completes.

## Completion Status Protocol

Report using: DONE | DONE_WITH_CONCERNS | BLOCKED | NEEDS_CONTEXT.
