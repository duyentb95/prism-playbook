#!/usr/bin/env bash
# Session Recovery Hook
# Runs on UserPromptSubmit (first prompt of session)
# Detects .prism/PROGRESS.md and surfaces context for continuation

set -euo pipefail

PROGRESS_FILE=".prism/PROGRESS.md"

# Only run if PROGRESS.md exists
if [ ! -f "$PROGRESS_FILE" ]; then
  exit 0
fi

# Extract status line
STATUS=$(grep -m1 '^## Status:' "$PROGRESS_FILE" 2>/dev/null | sed 's/^## Status: //' || echo "UNKNOWN")

# Only surface if there's active work
case "$STATUS" in
  IDLE|"—")
    exit 0
    ;;
  IN_PROGRESS|BLOCKED|WAITING_USER)
    # Extract key fields
    PHASE=$(grep -m1 '^\*\*Phase:\*\*' "$PROGRESS_FILE" 2>/dev/null | sed 's/\*\*Phase:\*\* //' || echo "unknown")
    TASK=$(grep -m1 '^\*\*Task:\*\*' "$PROGRESS_FILE" 2>/dev/null | sed 's/\*\*Task:\*\* //' || echo "unknown")
    BRANCH=$(git branch --show-current 2>/dev/null || echo "unknown")

    echo ""
    echo "================================================================"
    echo "SESSION RECOVERY: Previous work detected"
    echo "================================================================"
    echo "Status:  $STATUS"
    echo "Phase:   $PHASE"
    echo "Task:    $TASK"
    echo "Branch:  $BRANCH"
    echo ""
    echo "Read .prism/PROGRESS.md for full context."
    echo "Ask: Continue previous work or start fresh?"
    echo "================================================================"
    echo ""
    ;;
  *)
    exit 0
    ;;
esac
