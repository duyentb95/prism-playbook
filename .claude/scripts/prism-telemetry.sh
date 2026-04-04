#!/usr/bin/env bash
# PRISM Telemetry — local-only skill analytics
# Usage:
#   source .claude/scripts/prism-telemetry.sh
#   prism_tel_start "skill-name"        # Call in preamble
#   prism_tel_complete "skill-name" "success|error|abort"  # Call at end
#
# Output: .prism/analytics/skill-usage.jsonl
# Format: {"ts":"...","skill":"...","event":"...","branch":"...","duration_s":N,"outcome":"..."}

_PRISM_TEL_DIR=".prism/analytics"
_PRISM_TEL_FILE="$_PRISM_TEL_DIR/skill-usage.jsonl"

prism_tel_start() {
  local skill="$1"
  local branch
  branch=$(git branch --show-current 2>/dev/null || echo "unknown")
  local ts
  ts=$(date -u '+%Y-%m-%dT%H:%M:%SZ')

  mkdir -p "$_PRISM_TEL_DIR"

  # Record start time for duration calculation
  export _PRISM_TEL_START=$(date +%s)
  export _PRISM_TEL_SKILL="$skill"

  # Log start event
  printf '{"ts":"%s","skill":"%s","event":"started","branch":"%s"}\n' \
    "$ts" "$skill" "$branch" >> "$_PRISM_TEL_FILE"
}

prism_tel_complete() {
  local skill="${1:-$_PRISM_TEL_SKILL}"
  local outcome="${2:-unknown}"
  local branch
  branch=$(git branch --show-current 2>/dev/null || echo "unknown")
  local ts
  ts=$(date -u '+%Y-%m-%dT%H:%M:%SZ')
  local duration=0

  if [ -n "$_PRISM_TEL_START" ]; then
    local end
    end=$(date +%s)
    duration=$((end - _PRISM_TEL_START))
  fi

  mkdir -p "$_PRISM_TEL_DIR"

  # Log complete event with duration
  printf '{"ts":"%s","skill":"%s","event":"completed","branch":"%s","outcome":"%s","duration_s":%d}\n' \
    "$ts" "$skill" "$branch" "$outcome" "$duration" >> "$_PRISM_TEL_FILE"
}

# Summary functions for /cost and /retro
prism_tel_summary() {
  if [ ! -f "$_PRISM_TEL_FILE" ]; then
    echo "NO_DATA"
    return
  fi

  python3 -c "
import json, sys
from collections import defaultdict, Counter
from datetime import datetime

entries = []
for line in open('$_PRISM_TEL_FILE'):
    line = line.strip()
    if not line: continue
    try:
        entries.append(json.loads(line))
    except: pass

completed = [e for e in entries if e.get('event') == 'completed']
if not completed:
    print('NO_COMPLETIONS')
    sys.exit(0)

# By skill
by_skill = defaultdict(lambda: {'runs': 0, 'total_s': 0, 'outcomes': Counter()})
for e in completed:
    s = by_skill[e['skill']]
    s['runs'] += 1
    s['total_s'] += e.get('duration_s', 0)
    s['outcomes'][e.get('outcome', 'unknown')] += 1

print('SKILL_USAGE:')
for skill, data in sorted(by_skill.items(), key=lambda x: -x[1]['runs']):
    avg = data['total_s'] // data['runs'] if data['runs'] > 0 else 0
    outcomes = ', '.join(f'{k}={v}' for k,v in data['outcomes'].items())
    print(f'  {skill}: {data[\"runs\"]} runs, avg {avg}s, total {data[\"total_s\"]}s [{outcomes}]')

# Totals
total_runs = len(completed)
total_time = sum(e.get('duration_s', 0) for e in completed)
print(f'TOTAL: {total_runs} runs, {total_time}s ({total_time//60}m)')

# By day (last 7 days)
by_day = Counter()
for e in completed:
    day = e['ts'][:10]
    by_day[day] += 1
print('DAILY (last 7):')
for day in sorted(by_day.keys())[-7:]:
    print(f'  {day}: {by_day[day]} runs')

# Skill promotion status (pass@1 = at least 1 success per skill)
print('SKILL_HEALTH:')
for skill, data in sorted(by_skill.items(), key=lambda x: -x[1]['runs']):
    successes = data['outcomes'].get('success', 0)
    total = data['runs']
    pass_rate = successes / total if total > 0 else 0
    # Consecutive successes (for promotion)
    recent = [e for e in completed if e['skill'] == skill][-10:]
    consecutive = 0
    for e in reversed(recent):
        if e.get('outcome') == 'success': consecutive += 1
        else: break
    # Promotion tier
    if consecutive >= 5 and pass_rate >= 0.9: tier = 'STABLE'
    elif consecutive >= 2 and pass_rate >= 0.7: tier = 'PROVEN'
    elif total >= 1: tier = 'BETA'
    else: tier = 'NEW'
    print(f'  {skill}: {tier} (pass@1={pass_rate:.0%}, streak={consecutive}, runs={total})')
" 2>/dev/null
}

# Skill promotion check (call to see if a skill is ready for promotion)
prism_tel_skill_tier() {
  local skill="$1"
  if [ ! -f "$_PRISM_TEL_FILE" ]; then
    echo "NEW"
    return
  fi
  python3 -c "
import json
entries = [json.loads(l) for l in open('$_PRISM_TEL_FILE') if l.strip()]
completed = [e for e in entries if e.get('event')=='completed' and e.get('skill')=='$skill']
if not completed: print('NEW'); exit()
recent = completed[-10:]
successes = sum(1 for e in recent if e.get('outcome')=='success')
total = len(completed)
pass_rate = successes / len(recent) if recent else 0
consecutive = 0
for e in reversed(recent):
    if e.get('outcome')=='success': consecutive += 1
    else: break
if consecutive >= 5 and pass_rate >= 0.9: print('STABLE')
elif consecutive >= 2 and pass_rate >= 0.7: print('PROVEN')
elif total >= 1: print('BETA')
else: print('NEW')
" 2>/dev/null
}
