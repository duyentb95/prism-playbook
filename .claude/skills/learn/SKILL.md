---
name: learn
description: "Manage project learnings. Review, search, prune, and export what PRISM has learned across sessions. Use when asked to show learnings, what have we learned, prune stale learnings, export learnings, or add a learning."
model: sonnet
tools: ["Bash", "Read", "Write", "Edit", "AskUserQuestion", "Glob", "Grep"]
---

## Preamble (run first)

```bash
_BRANCH=$(git branch --show-current 2>/dev/null || echo "unknown")
_LEARN_FILE=".prism/learnings.jsonl"
_LEARN_COUNT=0
if [ -f "$_LEARN_FILE" ]; then
  _LEARN_COUNT=$(wc -l < "$_LEARN_FILE" | tr -d ' ')
fi
_HAS_KNOWLEDGE=$([ -d ".prism/knowledge" ] && echo "true" || echo "false")
echo "BRANCH: $_BRANCH | LEARNINGS: $_LEARN_COUNT | KNOWLEDGE_DIR: $_HAS_KNOWLEDGE"
```

---

# Project Learnings Manager

Structured learnings stored in `.prism/learnings.jsonl`. Each line is a JSON object:

```json
{"ts":"2026-04-01T12:00:00Z","skill":"review","type":"pitfall","key":"n-plus-one-in-serializers","insight":"ActiveRecord serializers trigger N+1 queries without .includes","confidence":8,"source":"observed","files":["app/serializers/post_serializer.rb"]}
```

**Fields:**
- `ts` — ISO timestamp
- `skill` — which skill discovered this (review, ship, investigate, etc.)
- `type` — `pattern` | `pitfall` | `preference` | `architecture` | `operational`
- `key` — short kebab-case identifier (2-5 words)
- `insight` — one-sentence description
- `confidence` — 1-10 (10 = verified by evidence, 5 = observed once)
- `source` — `observed` | `user-stated` | `review-finding` | `debug-discovery`
- `files` — optional array of related file paths

**Dedup rule:** latest entry per `key+type` wins. Append-only — never edit existing lines.

**Relationship to `.prism/knowledge/`:** Learnings are structured and searchable.
Knowledge files (RULES.md, GOTCHAS.md, TECH_DECISIONS.md) are prose for human reading.
Use `/learn export` to sync learnings into knowledge files.

---

## Detect command

Parse the user's input:

- `/learn` (no arguments) → **Show recent**
- `/learn search <query>` → **Search**
- `/learn prune` → **Prune**
- `/learn export` → **Export**
- `/learn stats` → **Stats**
- `/learn add` → **Manual add**

---

## Show recent (default)

Read `.prism/learnings.jsonl` and show the most recent 20 learnings, grouped by type.

```bash
if [ -f .prism/learnings.jsonl ]; then
  tail -50 .prism/learnings.jsonl
else
  echo "NO_LEARNINGS"
fi
```

Parse the output, deduplicate by key+type (latest wins), and present grouped:

```
PROJECT LEARNINGS — [N] entries ([M] unique)

PATTERNS:
  [key] — [insight] (confidence: N/10, from /[skill])

PITFALLS:
  [key] — [insight] (confidence: N/10, from /[skill])

OPERATIONAL:
  [key] — [insight] (confidence: N/10, from /[skill])
```

If no learnings: "No learnings recorded yet. As you use /review, /ship, /investigate,
learnings will be captured automatically. Or use `/learn add` to add one manually."

---

## Search

Read `.prism/learnings.jsonl`, filter entries where `key` or `insight` contains the query string (case-insensitive). Present matching entries.

If no matches: "No learnings matching '[query]'."

---

## Prune

Check learnings for staleness and contradictions.

1. Read all entries from `.prism/learnings.jsonl`
2. Deduplicate by key+type (latest wins)
3. **File existence check:** If learning has `files` field, check with Glob. Flag if files deleted.
4. **Contradiction check:** Same key with different insights. Flag.
5. **Age check:** Learnings older than 90 days with confidence < 5. Flag as potentially stale.

Present each flagged entry via AskUserQuestion:
- A) Remove this learning
- B) Keep it
- C) Update it

For removals: read the file, remove matching lines, write back.
For updates: append a new entry with corrected insight (latest wins).

---

## Export

Export learnings as markdown for `.prism/knowledge/`.

Read and deduplicate all learnings. Format as:

```markdown
## Learnings Export ([date])

### Patterns
- **[key]**: [insight] (confidence: N/10, from /[skill])

### Pitfalls
- **[key]**: [insight] (confidence: N/10, from /[skill])

### Architecture
- **[key]**: [insight] (confidence: N/10)

### Operational
- **[key]**: [insight] (confidence: N/10)
```

AskUserQuestion:
- A) Append to `.prism/knowledge/RULES.md` (patterns) and `GOTCHAS.md` (pitfalls)
- B) Save as `.prism/knowledge/learnings-export-[date].md`
- C) Just show — don't save

---

## Stats

```bash
if [ -f .prism/learnings.jsonl ]; then
  TOTAL=$(wc -l < .prism/learnings.jsonl | tr -d ' ')
  echo "TOTAL_ENTRIES: $TOTAL"
  echo "BY_TYPE:"
  cat .prism/learnings.jsonl | grep -oP '"type":"[^"]*"' | sort | uniq -c | sort -rn
  echo "BY_SKILL:"
  cat .prism/learnings.jsonl | grep -oP '"skill":"[^"]*"' | sort | uniq -c | sort -rn
  echo "BY_SOURCE:"
  cat .prism/learnings.jsonl | grep -oP '"source":"[^"]*"' | sort | uniq -c | sort -rn
  OLDEST=$(head -1 .prism/learnings.jsonl | grep -oP '"ts":"[^"]*"' | head -1)
  NEWEST=$(tail -1 .prism/learnings.jsonl | grep -oP '"ts":"[^"]*"' | head -1)
  echo "OLDEST: $OLDEST"
  echo "NEWEST: $NEWEST"
else
  echo "NO_LEARNINGS"
fi
```

Present as a readable table.

---

## Manual add

Gather via AskUserQuestion:
1. **Type**: pattern / pitfall / preference / architecture / operational
2. **Key**: 2-5 words, kebab-case
3. **Insight**: one sentence
4. **Confidence**: 1-10
5. **Related files**: optional

Then append to `.prism/learnings.jsonl`:

```bash
mkdir -p .prism
echo '{"ts":"'$(date -u +%Y-%m-%dT%H:%M:%SZ)'","skill":"learn","type":"TYPE","key":"KEY","insight":"INSIGHT","confidence":N,"source":"user-stated","files":["FILE"]}' >> .prism/learnings.jsonl
```

---

## Operational Self-Improvement (for other skills)

Other PRISM skills can log learnings by appending to `.prism/learnings.jsonl`.
Example from /investigate after discovering a project quirk:

```bash
echo '{"ts":"'$(date -u +%Y-%m-%dT%H:%M:%SZ)'","skill":"investigate","type":"pitfall","key":"bun-test-timeout","insight":"bun test needs --timeout 30000 for integration tests","confidence":8,"source":"debug-discovery"}' >> .prism/learnings.jsonl
```

Skills that should log learnings: review, ship, investigate, retro, paranoid-review.
A good test: would knowing this save 5+ minutes in a future session?

---

## Completion Status Protocol

Report using: DONE | DONE_WITH_CONCERNS | BLOCKED | NEEDS_CONTEXT.
