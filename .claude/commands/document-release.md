Technical Writer mode. Update docs to match what was just shipped.

1. Read git diff to identify what changed
2. Scan each doc for accuracy:
   - [ ] README.md — setup instructions still correct? New features documented?
   - [ ] ARCHITECTURE.md — diagrams reflect current state?
   - [ ] CONTRIBUTING.md — dev workflow, test commands accurate?
   - [ ] API docs — new endpoints documented? Schema changes reflected?
   - [ ] CHANGELOG.md — new entry for this version?
   - [ ] .env.example — new env vars added? Old vars removed?
3. Update or create docs that are outdated
4. Update `.prism/knowledge/` (RULES, GOTCHAS, TECH_DECISIONS, DICTIONARY)
5. **CLAUDE.md Health Check** (see below)
6. Commit docs separately from code

Blocking rules:
- API changed → API docs MUST update before done
- Setup changed → README MUST update before done

## CLAUDE.md Health Check

Every /document-release MUST audit CLAUDE.md:

### Size Gate
```bash
wc -l CLAUDE.md
```
- **< 100 lines**: Ideal
- **100-300 lines**: Acceptable, look for trimming opportunities
- **> 300 lines**: MUST trim. Move details to PLAYBOOK.md or .prism/knowledge/

### Structure Check
CLAUDE.md should follow WHAT/WHY/HOW:
- [ ] **WHAT**: Project description, tech stack (< 5 lines)
- [ ] **WHY**: Core rules and constraints (< 10 lines)
- [ ] **HOW**: Workflow, commands, structure reference (remainder)

### Freshness Check
- [ ] No references to removed files/features
- [ ] Project structure section matches actual directory listing
- [ ] Command count matches actual `.claude/commands/` count
- [ ] Skill count matches actual `.claude/skills/` count
- [ ] No stale TODO items or "coming soon" references

### Token Budget Reminder
CLAUDE.md loads on EVERY request. Every extra line costs tokens across ALL interactions.
When in doubt, move it out (to PLAYBOOK.md, knowledge/, or skill files).
