#!/usr/bin/env bash
# Self-Review Hook — runs on Stop (session end)
# Reviews changed files against rotating criteria
# Inspired by agstack's self-review pattern

set -euo pipefail

# Find files changed in this session (uncommitted + last commit)
CHANGED_FILES=$(git diff --name-only HEAD 2>/dev/null; git diff --name-only --cached 2>/dev/null; git diff --name-only HEAD~1 HEAD 2>/dev/null) || true
CHANGED_FILES=$(echo "$CHANGED_FILES" | sort -u | grep -v '^$' || true)

if [ -z "$CHANGED_FILES" ]; then
  exit 0
fi

FILE_COUNT=$(echo "$CHANGED_FILES" | wc -l | tr -d ' ')

# Rotating review angle based on day-of-week
DAY=$(date +%u)  # 1=Monday, 7=Sunday
case $((DAY % 5)) in
  0) ANGLE="CLEANUP: dead code, unused imports, commented-out blocks" ;;
  1) ANGLE="ERROR HANDLING: missing catches, silent failures, error propagation" ;;
  2) ANGLE="TYPE SAFETY: any casts, missing null checks, implicit conversions" ;;
  3) ANGLE="STRUCTURE: file organization, function length, single responsibility" ;;
  4) ANGLE="NAMING: unclear variable names, abbreviations, inconsistent conventions" ;;
esac

echo ""
echo "================================================================"
echo "SELF-REVIEW: $FILE_COUNT files changed this session"
echo "================================================================"
echo "Review angle: $ANGLE"
echo ""
echo "Changed files:"
echo "$CHANGED_FILES" | head -20 | sed 's/^/  - /'
if [ "$FILE_COUNT" -gt 20 ]; then
  echo "  ... and $((FILE_COUNT - 20)) more"
fi
echo ""
echo "Before ending: review these files through the lens above."
echo "================================================================"
echo ""
