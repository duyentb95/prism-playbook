---
name: ship
description: "Ship workflow: detect + merge base branch, run tests, review diff, bump VERSION, update CHANGELOG, commit, push, create PR. Use when asked to ship, deploy, push to main, create a PR, or merge and push."
model: opus
tools: ["Bash", "Read", "Write", "Edit", "Grep", "Glob", "AskUserQuestion"]
---

## Preamble (run first)

```bash
_BRANCH=$(git branch --show-current 2>/dev/null || echo "unknown")
_HAS_VERSION=$([ -f "VERSION" ] && echo "true" || echo "false")
_HAS_CHANGELOG=$([ -f "CHANGELOG.md" ] && echo "true" || echo "false")
_HAS_GH=$(command -v gh &>/dev/null && echo "true" || echo "false")
_HAS_TESTS=$(ls jest.config.* vitest.config.* .rspec pytest.ini Cargo.toml go.mod mix.exs phpunit.xml 2>/dev/null | head -1)
_HAS_GATE=$([ -f ".prism/GATE_STATUS.md" ] && echo "true" || echo "false")
_ENG_GATE=$(grep -c '\[x\] eng-locked' .prism/GATE_STATUS.md 2>/dev/null || echo "0")
_GSD_BYPASS=$(grep -c 'GSD_BYPASS' .prism/GATE_STATUS.md 2>/dev/null || echo "0")
echo "BRANCH: $_BRANCH | VERSION: $_HAS_VERSION | CHANGELOG: $_HAS_CHANGELOG | GH_CLI: $_HAS_GH"
echo "GATE: $_HAS_GATE | ENG_GATE: $_ENG_GATE | GSD: $_GSD_BYPASS"
[ -n "$_HAS_TESTS" ] && echo "TEST_CONFIG: $_HAS_TESTS" || echo "TEST_CONFIG: none detected"
```

### Gate Check

If `_HAS_GATE` is `true` and `_ENG_GATE` is `0` and `_GSD_BYPASS` is `0`:
- WARN: "Eng review gate hasn't been passed. Run /eng-review first, or proceed anyway?"
- This is a SOFT gate — warn but allow override. /ship is often run on small changes without full review flow.

Use the preamble output to guide decisions throughout the workflow:
- If `VERSION: false`, skip Step 4 (version bump)
- If `CHANGELOG: false`, Step 5 creates a new CHANGELOG.md
- If `GH_CLI: false`, Step 8 provides manual PR instructions instead
- If `TEST_CONFIG: none`, Step 3 tries to detect tests from CLAUDE.md or common patterns

## Step 0: Detect base branch

Determine which branch this PR targets. Use the result as "the base branch" in all subsequent steps.

1. Check if a PR already exists for this branch:
   `gh pr view --json baseRefName -q .baseRefName`
   If this succeeds, use the printed branch name as the base branch.

2. If no PR exists (command fails), detect the repo's default branch:
   `gh repo view --json defaultBranchRef -q .defaultBranchRef.name`

3. If both commands fail, fall back to `main`.

Print the detected base branch name. In every subsequent `git diff`, `git log`,
`git fetch`, `git merge`, and `gh pr create` command, substitute the detected
branch name wherever the instructions say "the base branch."

---

# Ship: Fully Automated Ship Workflow

You are running the `/ship` workflow. This is a **non-interactive, fully automated** workflow. Do NOT ask for confirmation at any step. The user said `/ship` which means DO IT. Run straight through and output the PR URL at the end.

**Only stop for:**
- On the base branch (abort)
- Merge conflicts that can't be auto-resolved (stop, show conflicts)
- Test failures (stop, show failures)
- Pre-landing review finds ASK items that need user judgment
- MINOR or MAJOR version bump needed (ask -- see Step 4)

**Never stop for:**
- Uncommitted changes (always include them)
- Version bump choice (auto-pick MICRO or PATCH -- see Step 4)
- CHANGELOG content (auto-generate from diff)
- Commit message approval (auto-commit)
- Multi-file changesets (auto-split into bisectable commits)
- Auto-fixable review findings (dead code, stale comments -- fixed automatically)
- Test coverage gaps (auto-generate and commit, or flag in PR body)

---

## Step 1: Pre-flight

1. Check the current branch. If on the base branch or the repo's default branch, **abort**: "You're on the base branch. Ship from a feature branch."

2. Run `git status` (never use `-uall`). Uncommitted changes are always included -- no need to ask.

3. Run `git diff <base>...HEAD --stat` and `git log <base>..HEAD --oneline` to understand what's being shipped.

---

## Step 2: Merge the base branch (BEFORE tests)

Fetch and merge the base branch into the feature branch so tests run against the merged state:

```bash
git fetch origin <base> && git merge origin/<base> --no-edit
```

**If there are merge conflicts:** Try to auto-resolve if they are simple (VERSION, schema.rb, CHANGELOG ordering). If conflicts are complex or ambiguous, **STOP** and show them.

**If already up to date:** Continue silently.

**If the base branch doesn't exist on the remote:** This likely means the repo is brand new or the remote is misconfigured. Warn the user and skip the merge step -- tests will run on the current branch state.

---

## Step 3: Run tests (on merged code)

Detect and run the project's test suite. This is fully automatic -- no user interaction.

**1. Detect the test command (priority order):**

a) Check CLAUDE.md for an explicit test command. Look for:
   - A `## Testing` or `## Tests` section
   - Lines containing `npm test`, `bun test`, `pytest`, `cargo test`, `go test`, `mix test`
   - A `## Commands` section with a test entry

b) If CLAUDE.md has no test command, check for a TESTING.md file.

c) If neither doc exists, detect from project files:

```bash
# Detect project runtime and try common test commands
[ -f package.json ] && (grep -q '"test"' package.json 2>/dev/null && echo "CMD:npm test")
[ -f bun.lockb ] && echo "CMD:bun test"
[ -f Gemfile ] && ([ -f bin/test ] && echo "CMD:bin/test" || echo "CMD:bundle exec rake test")
[ -f .rspec ] && echo "CMD:bundle exec rspec"
[ -f pytest.ini ] || [ -f pyproject.toml ] && echo "CMD:pytest"
[ -f go.mod ] && echo "CMD:go test ./..."
[ -f Cargo.toml ] && echo "CMD:cargo test"
[ -f mix.exs ] && echo "CMD:mix test"
[ -f composer.json ] && echo "CMD:vendor/bin/phpunit"
```

d) Check for test runner config files as a secondary signal:

```bash
ls jest.config.* vitest.config.* playwright.config.* .rspec pytest.ini phpunit.xml 2>/dev/null
ls -d test/ tests/ spec/ __tests__/ cypress/ e2e/ 2>/dev/null
```

**2. Run the detected test command:**

```bash
{detected test command} 2>&1 | tee /tmp/ship_tests.txt
```

If multiple test suites exist (e.g., backend + frontend), run them in parallel:

```bash
{backend test command} 2>&1 | tee /tmp/ship_tests_backend.txt &
{frontend test command} 2>&1 | tee /tmp/ship_tests_frontend.txt &
wait
```

After both complete, read the output files and check pass/fail.

**3. Evaluate results:**

- **If any test fails:** Show the failures and **STOP**. Do not proceed.
- **If all pass:** Continue silently -- just note the counts briefly (e.g., "42 tests passed").
- **If no test command detected:** Warn: "No test suite detected. Continuing without tests." and proceed.

---

## Step 3.4: Test Coverage Audit

Evaluate what was ACTUALLY coded (from the diff), not what was planned. Every untested path is where bugs hide.

**1. Trace every codepath changed** using `git diff origin/<base>...HEAD`:

Read every changed file. For each one:
- Read the full file (not just diff hunks) to understand context
- Identify every function/method added or modified
- Identify every conditional branch (if/else, switch, ternary, guard clause, early return)
- Identify every error path (try/catch, rescue, error boundary, fallback)

**2. Check each branch against existing tests:**

For each code path, search for a test that exercises it:
- Function `processPayment()` -- look for `billing.test.ts`, `billing.spec.ts`, `test/billing_test.rb`
- An if/else -- look for tests covering BOTH paths
- An error handler -- look for a test that triggers that specific error condition

Quality scoring rubric:
- 3 stars: Tests behavior with edge cases AND error paths
- 2 stars: Tests correct behavior, happy path only
- 1 star: Smoke test / existence check / trivial assertion

**3. Map key user flows and error states:**

For each changed feature, think through:
- **User flows:** What sequence of actions touches this code? Each step needs a test.
- **Error states the user sees:** For every error the code handles, what does the user experience?
  Is there a clear error message or a silent failure? Can the user recover?
- **Empty/zero/boundary states:** What happens with zero results? Maximum input? Null values?

Add these alongside code branches in your mental model.

**4. Output ASCII coverage diagram:**

```
CODE PATH COVERAGE
===========================
[+] src/services/billing.ts
    |
    +-- processPayment()
    |   +-- [3-STAR TESTED] Happy path + card declined -- billing.test.ts:42
    |   +-- [GAP]           Network timeout -- NO TEST
    |   +-- [GAP]           Invalid currency -- NO TEST
    |
    +-- refundPayment()
        +-- [2-STAR TESTED] Full refund -- billing.test.ts:89
        +-- [1-STAR TESTED] Partial refund (checks non-throw only) -- billing.test.ts:101

USER FLOW COVERAGE
===========================
[+] Payment checkout flow
    |
    +-- [3-STAR TESTED] Complete purchase -- checkout.e2e.ts:15
    +-- [GAP]           Form validation errors -- NO TEST
    +-- [GAP]           Empty cart submission -- NO TEST

-------------------------------------
COVERAGE: 3/7 paths tested (43%)
  Code paths: 3/5 (60%)
  User flows: 0/2 (0%)
QUALITY:  3-star: 1  2-star: 1  1-star: 1
GAPS: 4 paths need tests
-------------------------------------
```

**Fast path:** All paths covered -- "Step 3.4: All new code paths have test coverage." Continue.

**5. Generate tests for uncovered paths:**

If a test framework is available:
- Prioritize error handlers and edge cases first
- Read 2-3 existing test files to match conventions exactly
- Generate unit tests with real assertions (never `expect(x).toBeDefined()`)
- Run each test. Passes -- commit as `test: coverage for {feature}`
- Fails -- fix once. Still fails -- revert, note gap in diagram.

Caps: 20 code paths max, 10 tests generated max, 2-min per-test exploration cap.

If no test framework -- diagram only, no generation. Note: "Test generation skipped -- no test framework configured."

**Diff is test-only changes:** Skip Step 3.4 entirely: "No new application code paths to audit."

**6. Coverage summary for PR body:**

```bash
find . -name '*.test.*' -o -name '*.spec.*' -o -name '*_test.*' -o -name '*_spec.*' | grep -v node_modules | wc -l
```

`Test Coverage Audit: N code paths. M covered (X%). K tests generated, J committed.`

---

## Step 3.48: Scope Drift Detection

Before reviewing code quality, check: **did they build what was requested — nothing more, nothing less?**

1. Read `TODOS.md` (if exists). Read PR description (`gh pr view --json body --jq .body 2>/dev/null || true`).
   Read commit messages (`git log origin/<base>..HEAD --oneline`).
   If `.prism/MASTER_PLAN.md` exists, read it for the stated plan.
   **If no PR exists:** rely on commit messages, MASTER_PLAN.md, and TODOS.md for stated intent.

2. Identify the **stated intent** — what was this branch supposed to accomplish?

3. Run `git diff origin/<base>...HEAD --stat` and compare files changed against stated intent.

4. Evaluate with skepticism:

   **SCOPE CREEP detection:**
   - Files changed that are unrelated to the stated intent
   - New features or refactors not mentioned in the plan
   - "While I was in there..." changes that expand blast radius

   **MISSING REQUIREMENTS detection:**
   - Requirements from MASTER_PLAN.md/TODOS.md not addressed in the diff
   - Test coverage gaps for stated requirements
   - Partial implementations (started but not finished)

5. Output:
   ```
   Scope Check: [CLEAN / DRIFT DETECTED / REQUIREMENTS MISSING]
   Intent: <1-line summary of what was requested>
   Delivered: <1-line summary of what the diff actually does>
   [If drift: list each out-of-scope change]
   [If missing: list each unaddressed requirement]
   ```

6. This is **INFORMATIONAL** — does not block the ship. Include in PR body.

---

## Step 3.5: Pre-Landing Review

Review the diff for structural issues that tests don't catch.

1. Read `.claude/skills/code-review/checklist.md`. If the file cannot be read, use
   a minimal default checklist: SQL injection, hardcoded secrets, missing error handling,
   dead code, N+1 queries.

2. Run `git diff origin/<base>` to get the full diff.

3. Apply the review checklist in two passes:
   - **Pass 1 (CRITICAL):** Security issues, data safety, trust boundaries
   - **Pass 2 (INFORMATIONAL):** All remaining categories

4. **Classify each finding as AUTO-FIX or ASK:**
   - AUTO-FIX: Dead code removal, stale comments, obvious N+1, missing error handling
     with clear fix, unused imports, trivial style issues
   - ASK: Security-sensitive changes, architectural decisions, ambiguous trade-offs

5. **Auto-fix all AUTO-FIX items.** Output one line per fix:
   `[AUTO-FIXED] [file:line] Problem -- what you did`

6. **If ASK items remain,** present them in ONE AskUserQuestion:
   - List each with number, severity, problem, recommended fix
   - Per-item options: A) Fix  B) Skip
   - Overall RECOMMENDATION

7. **After all fixes (auto + user-approved):**
   - If ANY fixes were applied: commit fixed files by name
     (`git add <fixed-files> && git commit -m "fix: pre-landing review fixes"`),
     then **STOP** and tell the user to run `/ship` again to re-test.
   - If no fixes applied: continue to Step 4.

8. Output summary: `Pre-Landing Review: N issues -- M auto-fixed, K asked (J fixed, L skipped)`

   If no issues found: `Pre-Landing Review: No issues found.`

Save the review output -- it goes into the PR body in Step 8.

---

## Step 4: Version bump (auto-decide)

**If no VERSION file exists:** Skip this step. Continue to Step 5.

1. Read the current `VERSION` file (4-digit format: `MAJOR.MINOR.PATCH.MICRO`)

2. **Auto-decide the bump level based on the diff:**
   - Count lines changed (`git diff origin/<base>...HEAD --stat | tail -1`)
   - **MICRO** (4th digit): < 50 lines changed, trivial tweaks, typos, config
   - **PATCH** (3rd digit): 50+ lines changed, bug fixes, small-medium features
   - **MINOR** (2nd digit): **ASK the user** -- only for major features or significant architectural changes
   - **MAJOR** (1st digit): **ASK the user** -- only for milestones or breaking changes

3. Compute the new version:
   - Bumping a digit resets all digits to its right to 0
   - Example: `0.19.1.0` + PATCH -- `0.19.2.0`

4. Write the new version to the `VERSION` file.

---

## Step 5: CHANGELOG (auto-generate)

**If no CHANGELOG.md exists:** Create one with a standard header:
```
# Changelog

All notable changes to this project will be documented in this file.

```

1. Read `CHANGELOG.md` header to know the format.

2. Auto-generate the entry from **ALL commits on the branch** (not just recent ones):
   - Use `git log <base>..HEAD --oneline` to see every commit being shipped
   - Use `git diff <base>...HEAD` to see the full diff against the base branch
   - The CHANGELOG entry must be comprehensive of ALL changes going into the PR
   - If existing CHANGELOG entries on the branch already cover some commits, replace them with one unified entry for the new version
   - Categorize changes into applicable sections:
     - `### Added` -- new features
     - `### Changed` -- changes to existing functionality
     - `### Fixed` -- bug fixes
     - `### Removed` -- removed features
   - Write concise, descriptive bullet points
   - Insert after the file header, dated today
   - Format: `## [X.Y.Z.W] - YYYY-MM-DD` (or `## [Unreleased] - YYYY-MM-DD` if no VERSION file)

**Do NOT ask the user to describe changes.** Infer from the diff and commit history.

---

## Step 6: Commit (bisectable chunks)

**Goal:** Create small, logical commits that work well with `git bisect` and help LLMs understand what changed.

1. Analyze the diff and group changes into logical commits. Each commit should represent **one coherent change** -- not one file, but one logical unit.

2. **Commit ordering** (earlier commits first):
   - **Infrastructure:** migrations, config changes, route additions
   - **Models & services:** new models, services, concerns (with their tests)
   - **Controllers & views:** controllers, views, JS/React components (with their tests)
   - **VERSION + CHANGELOG:** always in the final commit

3. **Rules for splitting:**
   - A model and its test file go in the same commit
   - A service and its test file go in the same commit
   - A controller, its views, and its test go in the same commit
   - Migrations are their own commit (or grouped with the model they support)
   - Config/route changes can group with the feature they enable
   - If the total diff is small (< 50 lines across < 4 files), a single commit is fine

4. **Each commit must be independently valid** -- no broken imports, no references to code that doesn't exist yet. Order commits so dependencies come first.

5. Compose each commit message:
   - First line: `<type>: <summary>` (type = feat/fix/chore/refactor/docs/test)
   - Body: brief description of what this commit contains
   - Only the **final commit** (VERSION + CHANGELOG) gets the co-author trailer

6. **Examples of good bisection:**
   - Rename/move separate from behavior changes
   - Test infrastructure separate from test implementations
   - Config changes separate from feature code
   - Mechanical refactors separate from new features

7. **Commit the final version + changelog:**

```bash
git add VERSION CHANGELOG.md
git commit -m "$(cat <<'EOF'
chore: bump version and changelog (vX.Y.Z.W)

Co-Authored-By: Claude Opus 4.6 <noreply@anthropic.com>
EOF
)"
```

---

## Step 6.5: Verification Gate

**IRON LAW: NO COMPLETION CLAIMS WITHOUT FRESH VERIFICATION EVIDENCE.**

Before pushing, re-verify if code changed during Steps 4-6:

1. **Test verification:** If ANY code changed after Step 3's test run (fixes from review findings, CHANGELOG edits don't count), re-run the test suite. Paste fresh output. Stale output from Step 3 is NOT acceptable.

2. **Build verification:** If the project has a build step, run it. Paste output.

3. **Rationalization prevention:**
   - "Should work now" -- RUN IT.
   - "I'm confident" -- Confidence is not evidence.
   - "I already tested earlier" -- Code changed since then. Test again.
   - "It's a trivial change" -- Trivial changes break production.

**If tests fail here:** STOP. Do not push. Fix the issue and return to Step 3.

Claiming work is complete without verification is dishonesty, not efficiency.

---

## Step 7: Push

Push to the remote with upstream tracking:

```bash
git push -u origin <branch-name>
```

---

## Step 8: Create PR

**PR title format:** `<type>: <concise summary>` (under 70 characters)
- `feat:` for new features
- `fix:` for bug fixes
- `chore:` for maintenance, version bumps
- `refactor:` for code restructuring
- `docs:` for documentation changes

Create a pull request using `gh`:

```bash
gh pr create --base <base> --title "<type>: <summary>" --body "$(cat <<'EOF'
## Summary
<bullet points from CHANGELOG -- what changed and why>

## Test Coverage
<coverage diagram from Step 3.4, or "All new code paths have test coverage.">
<If Step 3.4 ran: "Tests: {before} -> {after} (+{delta} new)">
<Test Coverage Audit line: "N code paths. M covered (X%). K tests generated.">

## Scope Drift
<If scope drift ran: findings from Step 3.48, or "Scope Check: CLEAN">

## Pre-Landing Review
<findings from Step 3.5, or "No issues found.">
<If fixes applied: "N issues -- M auto-fixed, K user-reviewed">

## Version
<new version number, or "No VERSION file">

## Test plan
- [x] Tests pass (<test command> -- N tests, 0 failures)
- [x] Pre-landing review complete
- [x] VERSION bumped, CHANGELOG updated
- [x] Verification gate passed (fresh test run after commits)

Generated with [Claude Code](https://claude.com/claude-code)
EOF
)"
```

**If `gh` is not available** (detected in preamble as `GH_CLI: false`):
Push the branch and print manual instructions:
```
Branch pushed. Create a PR manually:
  Base: <base>
  Head: <branch>
  Title: <type>: <summary>
```

**Output the PR URL** (or manual instructions).

After PR creation:
1. Update `.prism/GATE_STATUS.md` if it exists — replace `- [ ] shipped` with:
   ```
   - [x] shipped (<today's date>) — PR #<number> created
   ```
2. Suggest: "Consider running `/document-release` to sync docs."

---

## Important Rules

- **Never skip tests.** If tests fail, stop. Do not work around failures.
- **Never skip the pre-landing review.** Always run it, even if no checklist file is found (use the minimal default).
- **Never force push.** Use regular `git push` only. Never `git push --force` or `git push -f`.
- **Never ask for confirmation** except for MINOR/MAJOR version bumps and pre-landing review ASK items (batched into at most one AskUserQuestion).
- **Always use the 4-digit version format** from the VERSION file (if it exists).
- **Date format in CHANGELOG:** `YYYY-MM-DD`
- **Split commits for bisectability** -- each commit = one logical change.
- **Never push without fresh verification evidence.** If code changed after Step 3 tests, re-run before pushing.
- **Step 3.4 generates coverage tests.** They must pass before committing. Never commit failing tests.
- **CHANGELOG is for users, not contributors.** Write it like product release notes. Lead with what the user can now do. Use plain language, not implementation details.
- **Commit messages use conventional format:** `feat:`, `fix:`, `chore:`, `refactor:`, `docs:`, `test:`.
- **The goal is: user says `/ship`, next thing they see is the PR URL.**

## Completion Status

When the workflow finishes, report status using one of:
- **DONE** -- All steps completed successfully. PR URL provided.
- **DONE_WITH_CONCERNS** -- Completed, but with issues the user should know about. List each concern.
- **BLOCKED** -- Cannot proceed. State what is blocking and what was tried.
- **NEEDS_CONTEXT** -- Missing information required to continue. State exactly what is needed.

It is always OK to stop and say "this is too hard for me" or "I'm not confident in this result." Bad work is worse than no work.

Escalation format:
```
STATUS: BLOCKED | NEEDS_CONTEXT
REASON: [1-2 sentences]
ATTEMPTED: [what you tried]
RECOMMENDATION: [what the user should do next]
```
