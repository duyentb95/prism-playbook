# Anti-Hallucination Rules

> Every claim must have verifiable evidence. No exceptions.

## Core Principle

If you cannot point to actual tool output proving a claim, **do not make that claim.**
"Likely", "probably", "should be" are hallucination markers. Replace with evidence or flag as unverified.

## Evidence Requirements

| Claim Type | Required Evidence |
|------------|-------------------|
| "X callers found" | Grep/Glob output showing actual callers |
| "This file exists" | Read or Glob confirming the path |
| "Tests pass" | Bash output of test runner |
| "No regressions" | Full test suite output |
| "Build succeeds" | Bash output of build command |
| "This is safe to change" | Grep showing all references checked |
| "N files affected" | git diff --stat or Glob output |
| "Performance improved" | Benchmark output before/after |
| "Bug is fixed" | Reproduction attempt showing fix works |
| "This pattern is used elsewhere" | Grep output showing concrete examples |

## Rules

1. **Tool failure = STOP.** If a command fails or returns unexpected output, report the error. Do NOT fabricate a plausible result.

2. **Cite, don't claim.** Instead of "this function is called in 3 places", show the Grep output. Instead of "tests pass", paste the test output.

3. **Verify file references.** Before referencing `file:line`, confirm the file exists and the line number is correct. Stale references from memory or prior edits are hallucinations.

4. **No phantom dependencies.** Before claiming a package/module/function exists, verify it. `import foo` means nothing if `foo` doesn't exist in the project.

5. **Metrics require math.** Any number you report (line count, coverage %, score) must have visible calculation. Show the work.

6. **Sub-agent claims need receipts.** If a sub-agent reports findings, the orchestrating agent must see actual tool call evidence — not just trust the summary.

7. **"Handled elsewhere" requires proof.** If you claim an edge case is handled in another file, Read that file and cite the specific lines. Otherwise flag as "unverified — may not be handled."

8. **Runtime claims need runtime evidence.** "This will work at runtime" requires actual execution (test, script, REPL). Code inspection alone is insufficient for runtime behavior.

## Self-Check Before Output

Before presenting any finding, report, or recommendation:

- [ ] Is there actual tool output supporting each claim?
- [ ] Did I show the evidence (not just assert it)?
- [ ] If a tool/command failed, did I report the failure honestly?
- [ ] Are all file:line references current (not stale from prior edits)?
- [ ] Did I distinguish "verified" from "assumed"?

## Escalation

If you cannot gather sufficient evidence to support your analysis:
- Say so explicitly: "I could not verify X because Y"
- Do NOT fill the gap with plausible-sounding fabrication
- Offer to investigate further or ask the user for context
