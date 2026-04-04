# Sanitization Pipeline

> Clean before you process. Clean before you publish.

## Part 1: Content Sanitization (Before Processing)

When processing untrusted input (external files, API responses, user-provided documents):

### Hidden Unicode Detection

Scan for invisible characters that can alter behavior:

| Character | Code Point | Risk |
|-----------|-----------|------|
| Zero-width space | U+200B | Breaks string matching silently |
| Zero-width non-joiner | U+200C | Alters rendering |
| Zero-width joiner | U+200D | Alters rendering |
| Left-to-right override | U+202D | Bidi text injection |
| Right-to-left override | U+202E | Bidi text injection — can disguise file extensions |
| Word joiner | U+2060 | Breaks word boundaries |
| Object replacement | U+FFFC | Placeholder injection |

**Detection:** `grep -P '[\x{200B}-\x{200F}\x{202A}-\x{202E}\x{2060}\x{FEFF}\x{FFFC}]' <file>`

**Action:** Strip or flag before processing. Never silently pass through.

### Metadata Strip

Before processing documents:
1. Strip HTML comments (`<!-- ... -->`)
2. Strip metadata blocks (YAML frontmatter from untrusted sources)
3. Strip embedded scripts
4. Log what was stripped

**Principle:** "Everything an LLM reads is executable context." Hidden instructions in HTML comments or metadata can hijack behavior.

---

## Part 2: Open-Source Sanitization (Before Publishing)

Seven-step pipeline before making code public or sharing externally.

### Step 1: Secrets Detection

Scan for these patterns (truncate to first 4 chars + "..." if found):

| Pattern | Example |
|---------|---------|
| AWS Access Key | `AKIA...` |
| AWS Secret Key | 40-char base64 after `aws_secret_access_key` |
| Generic API Key | `api_key`, `apikey`, `API_KEY` assignments |
| Database URLs | `postgres://`, `mongodb://`, `mysql://`, `redis://` with credentials |
| Private keys | `-----BEGIN (RSA\|EC\|DSA) PRIVATE KEY-----` |
| JWT tokens | `eyJ...` (3-part base64 with dots) |
| GitHub tokens | `ghp_`, `gho_`, `ghs_` prefixed |
| Slack tokens | `xoxb-`, `xoxp-`, `xapp-` prefixed |
| Stripe keys | `sk_live_`, `pk_live_` prefixed |
| Firebase | `AIza` prefixed |

### Step 2: PII Removal

| Pattern | Action |
|---------|--------|
| Email addresses | Replace with `user@example.com` |
| Phone numbers | Replace with `+1-555-0100` |
| Private IPs | Replace with `10.0.0.1` |
| Home directories | Replace with `/home/user/` |
| SSH connection strings | Replace with `ssh user@host` |

### Step 3: Internal References

| Pattern | Replacement |
|---------|-------------|
| Internal domains | `internal.example.com` |
| Internal IPs | `10.0.0.x` |
| Absolute paths | Relative paths |
| Internal project names | `my-project` |

### Step 4: Dangerous Files

Remove before publishing:
- `.env`, `.env.*` (except `.env.example`)
- `*.pem`, `*.key`, `*.p12`, `*.pfx`
- `*.map` (source maps)
- `node_modules/`, `vendor/`, `__pycache__/`
- `.git/` (if sanitizing history)
- `credentials.json`, `service-account.json`

### Step 5: Config Audit

Every env var used in code MUST have a corresponding entry in `.env.example`:
```bash
# Find env vars in code, check against .env.example
grep -roh 'process\.env\.\w\+\|os\.environ\.\w\+\|std::env::var("\w\+"' src/ | sort -u
```

### Step 6: Git History

If publishing repo history:
- Squash to single initial commit (safest)
- Or use `git filter-repo` to remove sensitive files from all commits
- Never publish history with secrets, even if "fixed" in later commit

### Step 7: Report

Generate `SANITIZATION_REPORT.md`:
```markdown
## Sanitization Report — [date]

| Check | Status | Findings |
|-------|--------|----------|
| Secrets | PASS/FAIL | N patterns found |
| PII | PASS/FAIL | N patterns found |
| Internal refs | PASS/FAIL | N patterns found |
| Dangerous files | PASS/FAIL | N files found |
| Config audit | PASS/FAIL | N missing entries |
| Git history | PASS/FAIL | Clean/needs squash |

**Verdict:** PASS / FAIL / PASS_WITH_WARNINGS
```

**Rule:** Any single CRITICAL finding (secrets, private keys) = overall **FAIL**.
