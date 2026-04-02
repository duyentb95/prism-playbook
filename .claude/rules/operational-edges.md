# Operational Edge Cases

> Known limitations of AI-assisted development. Work around them, don't ignore them.

## 1. Post-Edit Verification — "Done" means VERIFIED, not just written

Writing a file is NOT completing a task. After every code change:

```
Edit/Write → Build check → Lint check → THEN mark done
```

**For each language, run verification:**

| Stack | Verify command |
|-------|---------------|
| TypeScript | `npx tsc --noEmit && npx eslint . --quiet` |
| Rust | `cargo check && cargo clippy -- -D warnings` |
| Python | `python -m py_compile <file> && ruff check <file>` |
| Go | `go build ./... && go vet ./...` |

**Rule:** If the project has a build/lint command, run it after EVERY batch of edits (not after every single file, but after completing a logical unit of work). If it fails, fix before moving on. Never report "done" with broken build.

**For skills that auto-fix (code-review, paranoid-review):** Run verification after all fixes are applied, not between each fix.

## 2. Context Budget Awareness — You forget after ~167K tokens

Context window compacts aggressively after ~167K tokens. Earlier messages get summarized or dropped. This means:

**Symptoms of context exhaustion:**
- Repeating questions already answered
- Forgetting file contents read 20+ messages ago
- Losing track of multi-step plans
- Contradicting earlier decisions

**Mitigations:**
- **Refactor in phases of ≤ 5 files.** Larger batches risk losing early context.
- **Delete dead code BEFORE refactoring.** Less code in context = more room for reasoning.
- **Write decisions to disk** (MASTER_PLAN, knowledge/, STAGING.md) — don't rely on memory.
- **Use /compact proactively** when conversation exceeds ~30 messages.
- **Sub-agents get fresh context.** For large tasks, delegate to sub-agents rather than doing everything in one session.

## 3. Large File Reading — 2000 line limit per Read

The Read tool returns max 2000 lines per call. Files longer than that get silently truncated.

**Rules:**
- Before modifying a large file, check its size: `wc -l <file>`
- If > 2000 lines: read in chunks using `offset` + `limit` parameters
- Never assume you've seen the whole file from a single Read
- When searching for something in a large file, use Grep first to find the line number, then Read with offset

**Anti-pattern:** Reading line 1-2000 of a 5000-line file, making changes, and breaking code at line 3500 that you never saw.

## 4. Search Result Truncation — Don't trust one search

Grep results are capped. If a search returns suspiciously few results:

**Multi-pass search protocol:**
1. **First pass:** Normal search with Grep
2. **If results seem incomplete:** Search by directory (narrow scope, get more results per search)
3. **For renames/refactors:** Search multiple patterns:
   - Exact string: `functionName`
   - String reference: `"functionName"` / `'functionName'`
   - Dynamic import: `import.*functionName`
   - Re-export: `export.*from.*module`
   - Comment reference: `// functionName` or `TODO.*functionName`
4. **Never trust one grep for a rename.** Run at least 3 patterns before concluding "all references found."

**Anti-pattern:** Renaming a function, grepping once, missing the dynamic `require()` that still uses the old name.

## 5. Multi-Agent Batching — Maximize parallel context

Each agent gets its own ~167K token context window. One agent doing 20 tasks wastes this.

**Batching strategy:**
- **Independent file changes:** Batch 5-8 files per agent, launch agents in parallel
- **Sequential dependencies:** Chain agents (Agent A output → Agent B input)
- **Review parallelism:** Launch testing + security + performance specialists simultaneously (code-review already does this)

**When to spawn sub-agents vs do it yourself:**
| Scenario | Approach |
|----------|----------|
| Quick fix (< 5 min) | Do it yourself (GSD) |
| 1-3 files, focused change | Do it yourself |
| 5+ files, independent changes | Hero Mode (parallel agents) |
| Complex task, many dependencies | Sub-agent with task brief |
| Long conversation (>30 messages) | /compact or spawn fresh agent |

## Summary Checklist

Before marking ANY task done:
- [ ] Build/lint passes (not just "file written")
- [ ] Large files read fully (not just first 2000 lines)
- [ ] Search results verified (multi-pass for renames)
- [ ] Context still fresh (compact if conversation is long)
- [ ] Decisions persisted to disk (not just in conversation)
