# CLAUDE.md — PRISM Playbook (Data Pipeline)

## How to Work

1. **ASK before doing** — Don't jump to code. Ask: "What's the data source? What decisions does this analysis support?"
2. **Design before build** — Present: data sources → transformations → validations → output. Wait for approval.
3. **Plan before execute** — Break into micro-tasks (2-10 min each). Type GO to start.
4. **Small tasks → just do it** — Query fixes, schema tweaks: no planning needed (GSD mode).

## Project Context

**What**: [e.g., ETL pipeline / Analytics dashboard data / ML feature pipeline / Report generator]
**Why**: [What business decisions does this data support?]
**Who**: [Who consumes the output — analysts? executives? ML models? downstream services?]
**Stack**: [e.g., Python + pandas / dbt + Snowflake / Spark / Airflow]
**Sources**: [e.g., PostgreSQL, S3 CSV, REST APIs, Kafka]
**Output**: [e.g., Data warehouse tables / CSV reports / Dashboard feeds / ML features]
**Schedule**: [e.g., Hourly / Daily at 6am UTC / On-demand / Streaming]
**Testing**: [e.g., pytest / Great Expectations / dbt tests]

## Data Pipeline Standards

### Data Quality
- Validate input schema before processing — fail fast on unexpected formats
- Check for nulls, duplicates, and out-of-range values at each stage
- Log row counts at input → after each transform → output (detect data loss)
- Idempotent: running the same pipeline twice produces the same result

### Reliability
- Each step should be independently re-runnable
- If step 3 fails: don't re-run steps 1-2 (save intermediate results)
- Timeouts on all external data source connections
- Dead letter queue or error log for rows that fail validation

### Performance
- Don't load entire datasets into memory — use streaming or chunking for large data
- Partition by date/key for large tables
- Profile before optimizing — measure, don't guess

### Documentation
- Every column in output: name, type, description, source
- Data lineage: which source fields contribute to each output field
- SLA: when must this pipeline complete? What happens if it's late?

## Knowledge

- Read `.prism/knowledge/` before starting — patterns and traps from previous sessions.
- After learning something new, append to:
  - `RULES.md` — naming conventions, transformation patterns, SQL style
  - `GOTCHAS.md` — timezone issues, encoding problems, API rate limits
  - `TECH_DECISIONS.md` — why this orchestrator, why this data format

## Session Handoff

If conversation gets long: write state to `.prism/STAGING.md`, start fresh session.
