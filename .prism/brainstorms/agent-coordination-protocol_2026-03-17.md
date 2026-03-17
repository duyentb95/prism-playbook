# Brainstorm: PRISM as Agent Coordination Protocol (ACP)

**Date**: 2026-03-17
**Status**: Idea captured — to be explored after playbook launch
**Priority**: Future (Phase 2+)

---

## Core Insight

The AI Agent market has many tools for BUILDING agents (LangChain, CrewAI, AutoGen, Claude Agent SDK, OpenAI Agents SDK) and RUNNING agents (Devin, Cursor, Claude Code). Nobody has standardized how agents COORDINATE on a shared project.

PRISM already defines 7 protocols for agent coordination — they just live inside SKILL.md files tied to Claude Code. If extracted into language-agnostic specifications, they become a genuine standard.

## The 7 Protocols PRISM Already Has

| # | Protocol | Current Home | What It Defines |
|---|----------|-------------|-----------------|
| 1 | Capability Declaration | SKILL.md format | How agents declare what they can do |
| 2 | Task Assignment | master-agent task brief | How to route tasks to right agent + model tier |
| 3 | Handover | sub-agent handover section | How agents pass work to each other (status, summary, files, knowledge) |
| 4 | Knowledge Sharing | knowledge-spine | How agents share institutional memory (RULES, GOTCHAS, TECH_DECISIONS) |
| 5 | Quality Gate | paranoid-review + qa-engineer | How agents review each other's output (2-pass, health scoring) |
| 6 | State Management | MASTER_PLAN + CONTEXT_HUB | How to track project state and agent status |
| 7 | Cost Routing | cost-tracker + model tiers | How to optimize cost across agent tiers |

## Market Gap

```
BUILD 1 agent         → Solved (LangChain, CrewAI, Agent SDKs)
RUN 1 agent           → Solved (Devin, Cursor, Claude Code)
COORDINATE N agents   → ❌ UNSOLVED ← PRISM fits here
```

## Competitive Analogy

```
Docker     → standardized containers
REST       → standardized web APIs
Kubernetes → standardized container orchestration
PRISM      → standardizes agent coordination
```

## Proposed Roadmap

### Phase 1: Extract Protocol Specs (2-3 weeks)

```
spec/
├── capability-declaration.md    # From SKILL.md format
├── task-assignment.md           # From master-agent task brief
├── handover-protocol.md         # From sub-agent handover
├── knowledge-protocol.md        # From knowledge-spine
├── quality-gate.md              # From paranoid-review + qa-engineer
├── state-management.md          # From MASTER_PLAN + CONTEXT_HUB
└── cost-routing.md              # From cost-tracker
```

Each spec: problem statement, protocol definition (language-agnostic), JSON Schema, reference implementation, examples.

### Phase 2: Python SDK (4-6 weeks)

```python
# prism-sdk — Agent Coordination SDK
from prism import MasterAgent, WorkerAgent, KnowledgeBase

knowledge = KnowledgeBase.from_directory(".prism/knowledge/")
master = MasterAgent(model="opus", knowledge=knowledge, cost_budget=5.00)

plan = master.plan("Build login page with OAuth")
for task in plan.tasks:
    worker = WorkerAgent(model=task.tier)
    handover = worker.execute(task)
    review = master.review(handover)
    knowledge.append(handover.lessons_learned)
```

SDK structure:
```
prism-sdk/
├── prism/
│   ├── protocol/         # Task, Handover, Knowledge, Quality, Cost
│   ├── agents/           # MasterAgent, WorkerAgent, ReviewerAgent
│   ├── state/            # ProjectState, KnowledgeBase, ContextHub
│   └── integrations/     # Claude, OpenAI, LangChain, CrewAI adapters
├── examples/
└── pyproject.toml
```

### Phase 3: Integrations + Community

- GitHub Issues ↔ PRISM tasks (bi-directional sync)
- VS Code extension (visual task board)
- CLI: `prism status`, `prism plan`, `prism assign`
- "PRISM-compatible" badge for agent tools

## Risk Assessment

| Risk | Probability | Mitigation |
|------|------------|------------|
| Anthropic builds this into Claude Code | Medium-High | PRISM protocol is model-agnostic |
| CrewAI/LangChain adds similar protocols | Medium | First-mover advantage, ship spec first |
| Market doesn't care about coordination | Low | Multi-agent is THE trend 2025-2026 |
| Too academic, nobody uses it | Medium | Ship working SDK, not just spec papers |

## Validation Plan

Before full investment:
1. Write 1 spec document + 1 working Python example
2. Post on GitHub / HN / Reddit
3. Measure community response (stars, forks, discussions)
4. If positive → invest in full SDK
5. If not → keep as Claude Code playbook (still valuable)

## Key Positioning

```
BEFORE: "PRISM = prompt templates for Claude Code" (zero moat)
AFTER:  "PRISM = Agent Coordination Standard" (network effects moat)
```

---

*This brainstorm to be revisited after prism-playbook launch is validated.*
