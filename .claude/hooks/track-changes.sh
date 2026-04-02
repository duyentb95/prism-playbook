#!/usr/bin/env bash
# Track Changes + Security Scanner Hook
# Runs on PostToolUse for Edit/Write operations
# 1. Logs modified files to .prism/session-changes.log (audit trail)
# 2. Scans written content for hardcoded secrets (security)

set -euo pipefail

# Read tool input from stdin
INPUT=$(cat)

# Extract file path and content from JSON input
FILE_PATH=$(echo "$INPUT" | python3 -c "
import sys, json
try:
    data = json.load(sys.stdin)
    inp = data.get('tool_input', {})
    print(inp.get('file_path', inp.get('path', '')))
except:
    print('')
" 2>/dev/null || echo "")

if [ -z "$FILE_PATH" ]; then
  exit 0
fi

# Only track code files
case "$FILE_PATH" in
  *.ts|*.tsx|*.js|*.jsx|*.py|*.rb|*.rs|*.go|*.java|*.swift|*.kt|*.prisma|*.sql|*.md|*.env*|*.json|*.yaml|*.yml|*.toml)
    ;;
  *)
    exit 0
    ;;
esac

# Ensure .prism directory exists
mkdir -p .prism

# --- Part 1: Audit Trail ---
TIMESTAMP=$(date '+%Y-%m-%d %H:%M:%S')
TOOL_NAME=$(echo "$INPUT" | python3 -c "
import sys, json
try:
    data = json.load(sys.stdin)
    print(data.get('tool_name', 'unknown'))
except:
    print('unknown')
" 2>/dev/null || echo "unknown")

echo "$TIMESTAMP | $TOOL_NAME | $FILE_PATH" >> .prism/session-changes.log

# --- Part 2: Security Scanner ---
# Skip scanning for .md files (docs, not code)
case "$FILE_PATH" in
  *.md) exit 0 ;;
esac

# Only scan if file exists and is readable
if [ ! -f "$FILE_PATH" ]; then
  exit 0
fi

# Scan for hardcoded secrets patterns
SECRETS_FOUND=""

# AWS keys
if grep -qE 'AKIA[0-9A-Z]{16}' "$FILE_PATH" 2>/dev/null; then
  SECRETS_FOUND="${SECRETS_FOUND}\n  - AWS Access Key ID detected"
fi

# Generic password/secret assignments
if grep -qiE '(password|passwd|secret|api_key|apikey|api_secret|access_token|auth_token)\s*[:=]\s*["\x27][^"\x27]{8,}' "$FILE_PATH" 2>/dev/null; then
  SECRETS_FOUND="${SECRETS_FOUND}\n  - Possible hardcoded password/secret/API key"
fi

# Private keys
if grep -qE '-----BEGIN (RSA |EC |DSA )?PRIVATE KEY-----' "$FILE_PATH" 2>/dev/null; then
  SECRETS_FOUND="${SECRETS_FOUND}\n  - Private key embedded in file"
fi

# Connection strings with credentials
if grep -qiE '(mongodb|postgres|mysql|redis)://[^:]+:[^@]+@' "$FILE_PATH" 2>/dev/null; then
  SECRETS_FOUND="${SECRETS_FOUND}\n  - Database connection string with credentials"
fi

# JWT tokens (long base64 with dots)
if grep -qE 'eyJ[A-Za-z0-9_-]{20,}\.eyJ[A-Za-z0-9_-]{20,}\.' "$FILE_PATH" 2>/dev/null; then
  SECRETS_FOUND="${SECRETS_FOUND}\n  - JWT token detected"
fi

if [ -n "$SECRETS_FOUND" ]; then
  echo ""
  echo "================================================================"
  echo "SECURITY WARNING: Possible secrets in $FILE_PATH"
  echo "================================================================"
  printf "$SECRETS_FOUND\n"
  echo ""
  echo "If intentional (test fixtures, examples), ignore this warning."
  echo "Otherwise, move secrets to environment variables or .env files."
  echo "================================================================"
  echo ""
  # Log to security audit
  echo "$TIMESTAMP | SECURITY_WARNING | $FILE_PATH |$SECRETS_FOUND" >> .prism/session-changes.log
fi
