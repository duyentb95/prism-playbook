Multi-AI second opinion via OpenAI Codex CLI. Sends code to OpenAI for independent review.

Action: $ARGUMENTS

**⚠ SECURITY: This command sends project code to an external API (OpenAI).**
Before proceeding, you MUST:
1. Tell the user which files/diff will be sent to OpenAI
2. Ask for explicit confirmation: "This will send code to OpenAI's API. Proceed? [y/N]"
3. Only continue after user confirms

Route to gstack cognitive mode via gstack-bridge.
→ Lazy-load `gstack/codex/SKILL.md`

Modes: `review` (pass/fail gate), `challenge` (adversarial), or free-form question.
