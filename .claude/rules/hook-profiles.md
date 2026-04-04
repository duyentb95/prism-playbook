# Hook Profiles

> Switch hook intensity by context. Rapid prototyping vs production hardening.

## Three Profiles

Set via environment variable: `PRISM_HOOK_PROFILE=minimal|standard|strict`

| Profile | When | What runs |
|---------|------|-----------|
| **minimal** | Rapid prototyping, spikes, throwaway code | Session recovery only. No self-review, no track-changes, no safety hooks. |
| **standard** | Normal development (default) | All hooks: session-recovery, track-changes+security, self-review. |
| **strict** | Production changes, security-sensitive, pre-release | All standard hooks + additional: post-edit build verification, multi-pass search enforcement. |

## How to Use

```bash
# In terminal before starting Claude Code:
export PRISM_HOOK_PROFILE=strict

# Or per-session:
PRISM_HOOK_PROFILE=minimal claude
```

## Hook Matrix

| Hook | minimal | standard | strict |
|------|---------|----------|--------|
| session-recovery.sh | ON | ON | ON |
| track-changes.sh (audit + security scan) | OFF | ON | ON |
| self-review.sh | OFF | ON | ON |
| check-careful.sh (destructive commands) | OFF | ON | ON |
| check-freeze.sh (edit boundary) | OFF | ON | ON |
| Post-edit build verify | OFF | OFF | ON |
| Force multi-pass search on renames | OFF | OFF | ON |

## Disabling Individual Hooks

```bash
# Disable specific hooks without changing profile:
export PRISM_DISABLED_HOOKS=self-review,track-changes

# Re-enable:
unset PRISM_DISABLED_HOOKS
```

## Implementation

Hooks should check the profile at the top:

```bash
# Skip if profile is minimal
_PROFILE="${PRISM_HOOK_PROFILE:-standard}"
case "$_PROFILE" in
  minimal) exit 0 ;;
esac

# Skip if this hook is individually disabled
case ",${PRISM_DISABLED_HOOKS:-}," in
  *,HOOK_NAME,*) exit 0 ;;
esac
```

## Default

If `PRISM_HOOK_PROFILE` is not set, default is **standard**.
