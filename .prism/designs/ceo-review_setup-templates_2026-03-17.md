# CEO Review — Setup Template & Project Interview

**Date**: 2026-03-17
**Status**: ✅ Implemented (Option B)

## Problem
`./setup --project` copied `.prism/` verbatim from prism-playbook — 6 files contained PRISM's own content instead of being project-relevant.

## Decision
Option B: Interview + Generate — 5 questions in setup script, auto-generate .prism/ files.

## What Changed
1. Added `interview_project()` function to setup script (5 questions)
2. `.prism/` files generated from user answers, not copied from prism-playbook
3. Knowledge files (RULES.md, GOTCHAS.md, TECH_DECISIONS.md) start empty with section headers
4. Skip-friendly: Enter defaults to placeholder text
5. Added `.prism-template/` as reference templates

## Interview Questions
1. Project name (default: directory name)
2. What does it do? (1 sentence)
3. Who uses it?
4. Tech stack?
5. Domain-specific terms (term:definition format)
